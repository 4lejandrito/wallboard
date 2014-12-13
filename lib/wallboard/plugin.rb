require "events"
require 'rufus-scheduler'
require 'mongo_mapper'
require 'securerandom'

module Wallboard
    class Plugin

        MongoMapper.setup({
            'test' => {'uri' => 'mongodb://wb:wb@ds061200.mongolab.com:61200/wb'},
            'development' => {'uri' => 'mongodb://wb:wb@ds061200.mongolab.com:61200/wb'},
            'production' => {'uri' => ENV['MONGODB_URI']}
        }, ENV['RACK_ENV'])

        include MongoMapper::Document
        include Events::Emitter

        key :name, String
        key :settings, Hash, default: {}
        key :layout, Hash, default: {}

        def initialize(*args)
            super
            self.id = SecureRandom.uuid
        end

        def start
            schedule(Rufus::Scheduler.singleton)
        end

        def settings=(settings)
            @settings = settings
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
