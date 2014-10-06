module Wallboard
    class Plugin
        attr_accessor :name, :id, :config, :layout

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {}
        end

        def onmessage(&blk); @onmessage = blk; end

        def message(message)
            @onmessage.call(message) if defined? @onmessage
        end

        def get
            return {}
        end
    end
end
