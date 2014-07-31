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
            self.enabled << self.available.select { |p| p[:name] == name}[0][:class].split('::').inject(Object) {|o,c| o.const_get c}.new(name)        
        end
        
        def get(name)
            self.enabled.select { |p| p.name == name}[0]
        end
    end
    
end