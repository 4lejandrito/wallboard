module Wallboard
    class Plugin
        attr_accessor :name, :id, :config, :layout

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {}
            @data = {}
        end

        def onmessage(&blk); @onmessage = blk; end

        def send(data)
            @onmessage.call(data) if defined? @onmessage
            data
        end

        def get
            @data
        end

        def message(data)
            send(@data = data)
        end
    end
end
