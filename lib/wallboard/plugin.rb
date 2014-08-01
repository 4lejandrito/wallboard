require 'securerandom'

module Wallboard
    class Plugin
        attr_accessor :name, :id

        def initialize(name)
            @id = SecureRandom.uuid
            @name = name
            @config = {}
            @w = 10
            @h = 6
        end
    end
end