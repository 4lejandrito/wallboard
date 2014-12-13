angular.module('wb').service('server', function($http, $location, $q, $rootScope) {

    this.plugins = function() {
        return $http.get('/api/plugin');
    }

    this.update = function(items) {
        return $http.put('/api/plugin', items);
    }

    this.create = function(name) {
        return $http.post('/api/plugin?name=' + name);
    }

    this.delete = function(item) {
        return $http.delete('/api/plugin/' + (item.id || item.name));
    }

    this.get = function(plugin, data) {
        return $http.get('/api/plugin/' + plugin);
    }

    this.send = function(plugin, data) {
        return $http.post('/api/plugin/' + plugin, data);
    }

    this.settings = function(plugin, settings) {
        return $http.post('/api/plugin/' + plugin + '/settings', settings);
    }

    this.start = function() {
        var def = $q.defer(), self = this, path = window.location.pathname,
            ws = new WebSocket('ws://' + $location.host() + ':' + $location.port() + '/api');

        ws.onopen = function() {
            self.plugins().success(def.resolve);
        }

        ws.onmessage = function(data) {
            var message = JSON.parse(data.data);
            if (message.plugin)
                $rootScope.$emit(message.plugin, message.data);
            else
                $rootScope.$emit('wallboard', message);
        }

        return def.promise;
    }
});
