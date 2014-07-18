angular.module('wb').controller('builds', function($scope, $http) {
    $scope.Math = Math;
    $scope.jobs = [];
    /*$http.get("https://api.travis-ci.org/jobs", {headers: { Accept: "application/vnd.travis-ci.2+json" }}).success(function(result) {
        $scope.jobs = result.jobs;
        $scope.get('data');
    });*/
    $scope.addBuild = function() {
        $scope.jobs.push({name: 'Ask Widgets', commit: 'PF/ATG Everything fucked up'});
    }
    
    $scope.addBuild();
    $scope.addBuild();
    $scope.addBuild();
});