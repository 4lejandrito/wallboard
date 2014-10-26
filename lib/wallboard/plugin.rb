require "events"
require 'rufus-scheduler'
#require 'mongoid'
require 'mongo_mapper'

module Wallboard
    class Plugin

         MongoMapper.setup({
             'test' => {'uri' => 'mongodb://localhost:27017/wb-test'},
             'development' => {'uri' => 'mongodb://localhost:27017/wb-dev'},
             'production' => {'uri' => ENV['MONGODB_URI']}
         }, 'development')

        #include Mongoid::Document
        include MongoMapper::Document
        include Events::Emitter

        key :name, String
        key :config, Hash, default: {}
        key :layout, Hash, default: {}
        #field :name, type: String
        #field :id, as: :_id, type: String
        #field :config, type: Hash, default: {}
        #field :layout, type: Hash, default: {}

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
