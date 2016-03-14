(function() {
  'use strict';

  angular
    .module('pa.services.host', [])
    .factory('HostService', HostService);

  HostService.$inject = [ '$http' ];

  function HostService($http) {
    var hosts,
        memstats,
        URLS = {
          FETCH:   'data/hosts.json',
          MEMSTAT: 'data/memstat.json'
          // MEMSTAT: 'http://$server:$port/host/$hostname/subsystem/$subsystem/date/$date'
        };

    var service = {
      hosts:        hosts,
      URLS:         URLS,

      extract:      extract,
      cacheHosts:   cacheHosts,
      getHosts:     getHosts,
      getMemstat:   getMemstat
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
                  .then(getMemstatComplete)
                  .catch(getMemstatFailed);

      function getMemstatComplete(response) {
        memstats = extract(response);
        // console.log(memstats);
        return memstats;
      }

      function getMemstatFailed(error) {
        console.log("ERROR: XHR Failed for getMemstat." + error.data);
      }
    }

  }

})();