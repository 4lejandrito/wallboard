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
                begin
                    plugin.message(::MultiJson.load msg)
                rescue MultiJson::ParseError => exception
                    plugin.message(msg)
                end
            end
        end
    end
end
