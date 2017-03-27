require "fluent/plugin/output"

module Fluent::Plugin
    class CouchOutput < Output
        attr_reader :db # for tests

        DEFAULT_BUFFER_TYPE = "memory"

        helpers :compat_parameters, :inject

        config_set_default :include_tag_key, false
        config_set_default :include_time_key, true

        Fluent::Plugin.register_output('couch', self)

        config_param :database, :string

        config_param :host, :string, :default => 'localhost'
        config_param :port, :string, :default => '5984'
        config_param :protocol, :string, :default => 'http'

        config_param :refresh_view_index , :string, :default => nil

        config_param :user, :string, :default => nil
        config_param :password, :string, :default => nil, :secret => true

        config_param :update_docs, :bool, :default => false
        config_param :doc_key_field, :string, :default => nil
        config_param :doc_key_jsonpath, :string, :default => nil

        config_section :buffer do
            config_set_default :@type, DEFAULT_BUFFER_TYPE
            config_set_default :chunk_keys, ['tag']
        end

        def initialize
            super

            require 'msgpack'
            require 'jsonpath'
            Encoding.default_internal = 'UTF-8'
            require 'couchrest'
            Encoding.default_internal = 'ASCII-8BIT'
        end

        def configure(conf)
            compat_parameters_convert(conf, :buffer, :inject)
            super
            account = "#{@user}:#{@password}@" if @user && @password
            @db = CouchRest.database!("#{@protocol}://#{account}#{@host}:#{@port}/#{@database}")
        end

        def start
            super
            @views = []
            if @refresh_view_index
                begin
                    @db.get("_design/#{@refresh_view_index}")['views'].each do |view_name,func|
                        @views.push([@refresh_view_index,view_name])
                    end
                    rescue
                    $log.error 'design document not found!'
                end
            end
        end

        def shutdown
            super
        end

        def format(tag, time, record)
            record = inject_values_to_record(tag, time, record)
            record.to_msgpack
        end

        def formatted_to_msgpack_binary
            true
        end

        def write(chunk)
            records = []
            doc_key_field, doc_key_jsonpath = expand_placeholders(chunk.metadata)
            chunk.msgpack_each {|record|

                id = record[doc_key_field]
                id = JsonPath.new(doc_key_jsonpath).first(record) if id.nil? && !doc_key_jsonpath.nil?
                record['_id'] = id unless id.nil?
                records << record
            }
            unless @update_docs
                @db.bulk_save(records)
                else
                update_docs(records)
            end
            update_view_index
        end

        def update_docs(records)
            if records.length > 0
                records.each{|record|
                    doc = nil
                    begin
                        doc = @db.get(record['_id'])
                        rescue
                    end
                    record['_rev']=doc['_rev'] unless doc.nil?
                    $log.debug record
                    @db.save_doc(record)
                }
            end
        end

        def update_view_index()
            @views.each do |design,view|
                @db.view("#{design}/#{view}",{"limit"=>"0"})
            end
        end

        private

        def expand_placeholders(metadata)
            field = jsonpath = nil
            field = extract_placeholders(@doc_key_field, metadata) if @doc_key_field
            jsonpath = extract_placeholders(@doc_key_jsonpath, metadata) if @doc_key_jsonpath
            return field, jsonpath
        end
    end
end
