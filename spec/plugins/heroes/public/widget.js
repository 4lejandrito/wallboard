angular.module('wb').service('heroes', function($http) {
    this.start = function($scope, done) {
        $scope.heroes = [{name: 'Alejandro Tardin', commits: 89}, {name: 'Pau Folque', commits: 88}, {name: 'Kingsley Bickle', commits: 87}];
        done();
    }
});