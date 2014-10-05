angular.module('wb').service('builds', function($http) {
    this.start = function($scope, done) {
        $scope.Math = Math;

        $scope.get().success(function(builds) {
            $scope.jobs = builds;
            done();
        });
        
        $scope.onMessage = function(builds) {
            $scope.jobs = builds;
        };

        $scope.addBuild = function() {
            $scope.jobs.push(
                {
                    name: 'Ask Widgets',
                    status: Math.floor(Math.random() * 3),                
                    commit: 'Everything fucked up',
                    authors: [
                        {name: 'Alejandro Tardin', email: 'alejandro@tardin.com'},
                        {name: 'Pau Folque', email: 'paufolque@gmail.com'}                    
                    ]
                }
            );
        }
    }
}).directive('grid', function($interval) {
    return {
        scope: true,
        link: function(scope, elem, attrs) {            
            $interval(function(){
                scope.columns = Math.min(Math.floor($(elem).width() / 300), 12);
                scope.rows = Math.floor($(elem).height() / 180); 
                scope.elems = Math.floor(scope.rows * scope.columns - 1);                
            }, 200);          
        }
    };
});