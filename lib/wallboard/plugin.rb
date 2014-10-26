require "events"
require 'rufus-scheduler'
require 'mongo_mapper'

module Wallboard
    class Plugin

         MongoMapper.setup({
             'test' => {'uri' => 'mongodb://localhost:27017/wb-test'},
             'development' => {'uri' => 'mongodb://localhost:27017/wb-dev'},
             'production' => {'uri' => ENV['MONGODB_URI']}
         }, ENV['RACK_ENV'])

        include MongoMapper::Document
        include Events::Emitter

        key :name, String
        key :config, Hash, default: {}
        key :layout, Hash, default: {}

        def initialize(*args)
            super
            schedule(Rufus::Scheduler.singleton)
        end

        def publish(data)
            emit(:message, data)
            @data = data
        end

        def get
            @data or {}
        end

        def message(data)
            publish(data)
        end

        def schedule(scheduler)
        end
    end
end
