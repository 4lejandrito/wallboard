angular.module('wb').service('message', function($http) {
    this.start = function($scope, done) {
        $scope.get().success(function(message) {
            $scope.message = message;
            done();
        });

        $scope.$watch('message', function() {
            $scope.send($scope.message);
        }, true);
    }
});
