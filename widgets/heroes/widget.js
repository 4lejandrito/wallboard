angular.module('wb').controller('heroes', function($scope, $http) {
    $scope.heroes = [{name: 'Alejandro Tardin', commits: 89}, {name: 'Pau Folque', commits: 88}, {name: 'Kingsley Bickle', commits: 87}];
});