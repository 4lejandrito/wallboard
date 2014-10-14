require 'multi_json'
require 'faye/websocket'

module Wallboard
    class WSHandler

        def initialize(pm)
            Faye::WebSocket.load_adapter('thin')

            @pm = pm
            @clients = []
            @pm.on :message do |data|
                @clients.each {|client| client.send(::MultiJson.dump(data))}
            end
        end

        def handle(request)
            if Faye::WebSocket.websocket?(request.env)
              ws = Faye::WebSocket.new(request.env)

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
end
