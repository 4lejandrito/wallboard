require 'wallboard/plugin'

module Heroes
    class Main < Wallboard::Plugin
        def get
            [
                {:name => 'Alejandro Tardin', :email => 'alejandro.tardin@wds.co', :commits => 89},
                {:name =>'Pau Folque', :email => 'pau.folque@wds.co', :commits => 88},
                {:name => 'Kingsley Bickle', :email => 'kingsley.bickle@wds.co', :commits => 87}
            ]
        end
    end
end
