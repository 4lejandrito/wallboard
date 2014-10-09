require 'multi_json'

module Wallboard
    class WSHandler

        def initialize(pm, ws)
            @pm = pm
            @ws = ws;
        end

        def handle
            @pm.enabled.each do |plugin|
                plugin.onmessage do |msg|
                    @ws.send(::MultiJson.dump({:plugin => plugin.id, :data => msg}))
                end
            end
            @ws.on(:message) do |msg|
                message = ::MultiJson.load msg.data
                @pm.get(message["plugin"]).message(message["data"])
            end
            @ws.on(:close) do |event| end

            @ws.rack_response
        end
    end
end
