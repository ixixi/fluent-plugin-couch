module Fluent
    class CouchOutput < BufferedOutput
        include SetTagKeyMixin
        config_set_default :include_tag_key, false

        include SetTimeKeyMixin
        config_set_default :include_time_key, true

        Fluent::Plugin.register_output('couch', self)

        config_param :database, :string

        config_param :host, :string, :default => 'localhost'
        config_param :port, :string, :default => '5984'

        config_param :refresh_view_index , :string, :default => nil
        
        config_param :user, :string, :default => nil
        config_param :password, :string, :default => nil

        def initialize
            super
            Encoding.default_internal = 'UTF-8'
            require 'msgpack'
            require 'couchrest'
        end

        def configure(conf)
            super
        end

        def start
            super
            if @user && @password
                @db = CouchRest.database!("http://#{@user}:#{@password}@#{@host}:#{@port}/#{@database}")
            else
                @db = CouchRest.database!("http://#{@host}:#{@port}/#{@database}")
            end
            @views = []
            if @refresh_view_index
                begin
                    @db.get("_design/#{@refresh_view_index}")['views'].each do |view_name,func|
                        @views.push([@refresh_view_index,view_name])
                    end
                rescue
                    puts 'design document not found!'
                end
            end
        end

        def shutdown
            super
        end

        def format(tag, time, record)
            record.to_msgpack
        end

        def write(chunk)
            records = []
            chunk.msgpack_each {|record| records << record }
            @db.bulk_save(records)
            update_view_index()
        end

        def update_view_index()
            @views.each do |design,view|
                @db.view("#{design}/#{view}",{"limit"=>"0"})
            end
        end

    end
end
