module Wallboard
    class Plugin
        attr_accessor :name

        def initialize(name)
            @name = name
            @config = {}
            @w = 10
            @h = 6
        end
    end
end