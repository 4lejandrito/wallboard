angular.module('wb').controller('plugin', function($scope, $http, $injector) {        
    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });
    
    $scope.get = function(url, data) {
        return $http.get('/plugin/' + $scope.plugin.id + (url ? '/' + url : ''), data);
    }
    
    try {
        var child = $injector.get($scope.plugin.name);
        if (child.start && $scope.plugin.config) {
            $scope.$emit('loading', true);    
            child.start($scope, function() {
                $scope.$emit('loading', false);    
            });
        }
    } catch(err) {
        throw err;
    }
});