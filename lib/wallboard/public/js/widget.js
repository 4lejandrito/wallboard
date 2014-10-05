angular.module('wb').controller('widget', function($scope, $http, $injector) {        
    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });
    
    $scope.get = function(url, data) {
        return $http.get('/plugin/' + $scope.widget.id + (url ? '/' + url : ''), data);
    }
    
    try {
        var child = $injector.get($scope.widget.name);
        if (child.start && $scope.widget.config) {
            $scope.$emit('loading', true);    
            child.start($scope, function() {
                $scope.$emit('loading', false);    
            });
        }
    } catch(err) {
        throw err;
    }
});