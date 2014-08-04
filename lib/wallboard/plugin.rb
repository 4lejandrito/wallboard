module Wallboard
    class Plugin
        attr_accessor :name, :id

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {:w => 10, :h => 6}
        end
    end
end