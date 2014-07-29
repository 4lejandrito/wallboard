angular.module('wb', ['ui.gravatar'])

.service('server', function($http) {
    this.plugins = function() {        
        return $http.get('plugins');
    }    
})
.controller('wb', function($scope, server) {
    server.plugins().success(function(plugins) {                
        $scope.plugins = plugins.available;
        $scope.widgets = plugins.enabled;
    });          
}).controller('widget', function($scope, $http, $injector) {        
    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });
    
    $scope.get = function(url, data) {
        return $http.get('http://localhost:9292/' + $scope.widget.name + (url ? '/' + url : ''), data);
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
}).directive('gridster', function($interval) {
    return {
        scope: true,
        link: function(scope, elem, attrs) {            
            $(elem).gridster({
                widget_margins: [10, 10], 
                widget_base_dimensions: [30, 30],					
                resize: {
                    enabled: true
                },
                autogrow_cols: false
            }).data('gridster');         
        }
    };
});       