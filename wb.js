angular.module('wb', ['ui.gravatar'])

.controller('wb', function($scope, $timeout) {
    $scope.widgets = [{name: 'builds', w: 19, h: 8, config: {username: 'mdo'}}, {name: 'heroes', w: 8, h: 5, config: {}}];

    $timeout(function() {    
        $(".gridster > ul").gridster({
            widget_margins: [10, 10], 
            widget_base_dimensions: [30, 30],					
            resize: {
                enabled: true
            },
            autogrow_cols: false
        }).data('gridster');  
        $scope.loaded = true;
    }, 500);
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
});       