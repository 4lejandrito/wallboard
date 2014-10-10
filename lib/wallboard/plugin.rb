require "events"

module Wallboard
    class Plugin
        include Events::Emitter
        attr_accessor :name, :id, :config, :layout

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {}
        end

        def send(data)
            emit(:message, data)
            @data = data
        end

        def get
            @data or {}
        end

        def message(data)
            send(data)
        end
    end
end
