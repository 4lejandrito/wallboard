require 'pathname'
require 'events'

module Wallboard
    class PluginManager
        include Events::Emitter

        attr_reader :available, :enabled

        def initialize(folder)
            @folder = folder
            Dir.glob(@folder + "/*/plugin.rb").each{|f| require_relative f}
            @available = Dir.glob(@folder + '/*').map do |f|
                name = Pathname.new(f).basename.to_s
                clazz = Plugin.name
                begin
                    clazz = Object.const_get(name.capitalize())::Main.name
                rescue NameError
                end
                {:name => name, :class => clazz}
            end
        end

        def enabled
            @enabled ||= Wallboard::Plugin.all.each do |plugin|
                plugin.on :message do |data|
                    emit(:message, {:plugin => plugin.id, :data => data})
                end
            end
        end

        def create(name)
            template = getTemplate(name) or not_found(name)

            plugin = template[:class].split('::').inject(Object) {|o,c| o.const_get c}.create(name: name)
            self.enabled << plugin

            plugin.on :message do |data|
                emit(:message, {:plugin => plugin.id, :data => data})
            end

            emit(:message, self)

            plugin
        end

        def get(id)
            self.enabled.select { |p| p.id == id}[0] or self.enabled.select { |p| p.name == id}[0] or not_found(id)
        end

        def delete(id)
            plugin = self.enabled.delete(self.get(id))
            emit(:message, self)
            plugin.delete
            plugin
        end

        def update(plugins)
            plugins.each {|p| get(p['id']).layout = p['layout']}
            emit(:message, self)
        end

        def to_json(*args)
            {:available => self.available, :enabled => self.enabled}.to_json
        end

        private

        def getTemplate(name)
          self.available.select { |p| p[:name] == name}[0]
        end

        def not_found(id)
            raise "Plugin #{id} not found"
        end
    end
end
