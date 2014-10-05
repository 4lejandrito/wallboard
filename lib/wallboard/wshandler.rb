require 'multi_json'

module Wallboard
    class WSHandler

        def initialize(plugin, ws)
            plugin.onmessage do |msg|
                ws.send(::MultiJson.dump msg)
            end
            ws.onopen do
                ws.send(::MultiJson.dump plugin.get())
            end
            ws.onmessage do |msg|
                plugin.message(::MultiJson.load msg)
            end
        end
    end
end
