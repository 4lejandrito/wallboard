require 'pathname'
require 'securerandom'
require 'events'

module Wallboard
    class PluginManager
        include Events::Emitter

        attr_accessor :enabled, :available

        def initialize(folder)
            @folder = folder
            Dir.glob(folder + "/*/plugin.rb").each{|f| require_relative f}
            self.available = Dir.glob(@folder + '/*').map do |f|
                name = Pathname.new(f).basename.to_s
                clazz = Plugin.name
                begin
                    clazz = Object.const_get(name.capitalize())::Main.name
                rescue NameError
                end
                {:name => name, :class => clazz}
            end
            self.enabled = []
        end

        def create(name)
            template = getTemplate(name)
            if (template)
                plugin = template[:class].split('::').inject(Object) {|o,c| o.const_get c}.new(SecureRandom.uuid, name)
                self.enabled << plugin

                plugin.on :message do |data|
                    emit(:message, {:plugin => plugin.id, :data => data})
                end

                emit(:message, self)

                plugin
            end
        end

        def get(id)
            self.enabled.select { |p| p.id == id}[0] or self.enabled.select { |p| p.name == id}[0]
        end

        def delete(id)
            plugin = self.enabled.delete(self.enabled.select { |p| p.id == id}[0])
            emit(:message, self)
            plugin
        end

        def update(plugins)
            plugins.each {|p| get(p['id']).layout = p['layout']}
            emit(:message, self)
        end

        private

        def getTemplate(name)
          self.available.select { |p| p[:name] == name}[0]
        end
    end
end
