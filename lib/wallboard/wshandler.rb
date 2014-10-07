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
            @ws.onmessage do |msg|
                message = ::MultiJson.load msg
                @pm.get(message["plugin"]).message(message["data"])
            end
        end
    end
end
