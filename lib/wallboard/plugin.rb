module Wallboard
    class Plugin
        attr_accessor :name, :id, :config

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {}
        end
    end
end