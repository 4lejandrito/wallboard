require 'multi_json'

module Wallboard
    class WSHandler

        def initialize(pm)
            @pm = pm
            @clients = []
            @pm.on :message do |data|
                @clients.each {|client| client.send(::MultiJson.dump(data))}
            end
        end

        def handle(ws)
            ws.on(:open) do |msg|
                @clients << ws
            end
            ws.on(:message) do |msg|
                message = ::MultiJson.load msg.data
                @pm.get(message["plugin"]).message(message["data"])
            end
            ws.on(:close) do |event|
                @clients.delete(ws)
            end
            ws.rack_response
        end
    end
end
