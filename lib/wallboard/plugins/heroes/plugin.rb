require 'wallboard/plugin'

module Heroes
    class Main < Wallboard::Plugin
        def get
            [
                {:name => 'Alejandro Tardin', :email => 'alejandro.tardin@wds.co', :commits => 89},
                {:name => 'Pau Folque', :email => 'pau.folque@wds.co', :commits => 88},
                {:name => 'Kingsley Bickle', :email => 'kingsley.bickle@wds.co', :commits => 87},
                {:name => 'Phil Riley', :email => 'phil.riley@wds.co', :commits => 85},
                {:name => 'Adina Petrean', :email => 'adina.petrean@wds.co', :commits => 77},
                {:name => 'Fran Mendoza', :email => 'fran.mendoza@wds.co', :commits => 75},
                {:name => 'Matt Alner', :email => 'matthew.alner@wds.co', :commits => 74}
            ]
        end
    end
end
