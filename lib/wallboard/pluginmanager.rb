require 'pathname'

module Wallboard
    class PluginManager
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
            template = self.geta(name)
            if (template)
                plugin = template[:class].split('::').inject(Object) {|o,c| o.const_get c}.new(name)
                self.enabled << plugin
                plugin
            end
        end
        
        def geta(name)
            self.available.select { |p| p[:name] == name}[0]
        end
        
        def get(name)
            self.enabled.select { |p| p.name == name}[0]
        end
    end
    
end