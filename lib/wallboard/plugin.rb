module Wallboard
    class Plugin
        attr_accessor :name, :id, :config

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {:w => 10, :h => 6, :x => 0, :y => 0}
        end
    end
end