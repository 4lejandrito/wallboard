require "events"
require 'rufus-scheduler'

module Wallboard
    class Plugin
        include Events::Emitter
        attr_accessor :name, :id, :config, :layout

        def initialize(id, name)
            @id = id
            @name = name
            @config = {}
            @layout = {}

            schedule(Rufus::Scheduler.singleton)
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

        def schedule(scheduler)
        end
    end
end
