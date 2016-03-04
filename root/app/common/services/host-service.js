(function() {
  'use strict';

  angular
    .module('pa.services.host')
    .factory('HostService', HostService);

  HostService.$inject = [ '$http' ];

  function HostService($http) {
    var hosts,
        URLS = {
          FETCH:   'data/hosts.json',
          MEMSTAT: 'data/memstat.json'
        };

    var service = {
      hosts:        hosts,
      URLS:         URLs,

      extract:      extract,
      cacheHosts:   cacheHosts,
      getHosts:     getHosts
    };

    return service;

    // FUNCTION DEFINITIONS
    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    function getHosts() {
      return $http.get(URLS.FETCH).then(cacheHosts);
    }

    function getMemstat() {
      return $http.get(URLS.MEMSTAT)
        .then(getMemstatComplete(response))
        .catch(getMemstatFailed);

      function getMemstatComplete(response) {
        return response.data.results;
      }

      function getMemstatFailed(error) {
        console.log("ERROR: XHR Failed for getMemstat." + error.data);
      }
    }

  }

})();