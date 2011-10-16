module Couch
    require 'net/http'
    class Server
        def initialize(host, port, options = nil)
            @host = host
            @port = port
            @options = options
        end

        def delete(uri)
            request(Net::HTTP::Delete.new(uri))
        end

        def get(uri)
            request(Net::HTTP::Get.new(uri))
        end

        def put(uri, json)
            req = Net::HTTP::Put.new(uri)
            req["content-type"] = "application/json"
            req.body = json
            request(req)
        end

        def post(uri, json)
            req = Net::HTTP::Post.new(uri)
            req["content-type"] = "application/json"
            req.body = json
            request(req)
        end

        def request(req)
            res = Net::HTTP.start(@host, @port) { |http|http.request(req) }
            res
        end

    end
end

module Fluent
    class CouchOutput < BufferedOutput
        Fluent::Plugin.register_output('couch', self)

        def initialize
            super
            require 'msgpack'
        end

        def configure(conf)
            super
            @database_name = '/'+conf['database'] if conf.has_key?('database')
            raise ConfigError, "'database' parameter is required on couch output" if @database_name.nil?
            @host = conf['host'] || 'localhost'
            @port = conf['port'] || '5984'
        end

        def start
            super
            @couch = Couch::Server.new(@host, @port)
            @couch.put(@database_name, "")
        end

        def shutdown
            super
        end

        def format(tag, time, record)
            record.to_msgpack
        end

        def write(chunk)
            records = []
            chunk.open { |io|
                begin
                    MessagePack::Unpacker.new(io).each { |record| records << record }
                rescue EOFError
                    # EOFError always occured when reached end of chunk.
                end
            }
            #TODO: bulk insert
            for record in records
                @couch.post(@database_name,record.to_json)
            end
        end
    end
end
