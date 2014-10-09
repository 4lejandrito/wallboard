require 'wallboard/plugin'

module Heroes
    class Main < Wallboard::Plugin
        def get
            [{:name => 'Alejandro Tardin', :commits => 89}, {:name =>'Pau Folque', :commits => 88}, {:name => 'Kingsley Bickle', :commits => 87}]
        end
    end
end
