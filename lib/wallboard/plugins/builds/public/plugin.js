angular.module('wb').directive('grid', function($timeout) {
    return {
        scope: true,
        link: function(scope, elem, attrs) {
            $(window).resize(function(){
                scope.$apply(function(){
                    scope.columns = Math.min(Math.floor($(window).width() / 300), 12);
                    scope.rows = Math.floor($(window).height() / 180);
                    scope.elems = Math.floor(scope.rows * scope.columns - 1);
                });
            });

            $timeout(function() {
                $(window).resize();
            });
        }
    };
});
