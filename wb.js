angular.module('wb', ['ui.gravatar'])

.controller('wb', function($scope, $timeout) {
    $scope.widgets = [{name: 'builds', w: 19, h: 8}, {name: 'heroes', w: 8, h: 5}];

    $timeout(function() {    
        $(".gridster > ul").gridster({
            widget_margins: [10, 10], 
            widget_base_dimensions: [30, 30],					
            resize: {
                enabled: true
            }
        }).data('gridster');  
        $scope.loaded = true;
    }, 0);
}).controller('widget', function($scope, $http) {
    $scope.get = function(url, data) {
        return $http.get('widgets/' + $scope.widget.name + '/' + url, data);
    }
});       