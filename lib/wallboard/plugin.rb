require "events"
require 'rufus-scheduler'
require 'mongo_mapper'
require 'securerandom'

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
            self.id = SecureRandom.uuid
            schedule(Rufus::Scheduler.singleton)
        end

        def config=(config)
            @config = config
            save!
        end

        def layout=(layout)
            @layout = layout
            save!
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
