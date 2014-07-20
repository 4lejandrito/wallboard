angular.module('wb').controller('builds', function($scope, $http) {
    $scope.Math = Math;
    $scope.jobs = [];
    /*$http.get("https://api.travis-ci.org/jobs", {headers: { Accept: "application/vnd.travis-ci.2+json" }}).success(function(result) {
        console.log(result.jobs);
    });*/
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
    
    for (var i = 0; i < 10; i++) $scope.addBuild();    
});