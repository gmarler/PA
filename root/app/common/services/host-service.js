(function() {
  'use strict';

  angular
    .module('pa.services.host', [])
    .factory('HostService', HostService);

  HostService.$inject = [ '$http' ];

  function HostService($http) {
    var hosts,
        PAServer,
        memstats,
        port      = "5000",
        hostname  = "n322",
        subsystem = "memstat",
        date      = "2016-03-14",
        URLS = {
          FETCH:   'data/hosts.json',
          // MEMSTAT: 'data/memstat.json'
          MEMSTAT: 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
                    subsystem + '/date/' + date
        };

    var service = {
      hosts:          hosts,
      URLS:           URLS,
      PAServer:       PAServer,
      hostname:       hostname,
      subsystem:      subsystem,
      date:           date,

      setPAServer:    setPAServer,
      getPAServer:    getPAServer,
      extract:        extract,
      cacheHosts:     cacheHosts,
      getHosts:       getHosts,
      getMemstat:     getMemstat
    };

    return service;

    // FUNCTION DEFINITIONS

    function setPAServer(server) {
      console.log("Updating PA Server to: " + server)
      PAServer = server;
    }

    function getPAServer() {
      return PAServer;
    }

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
      var myURL = buildMemstatURL();
      console.log("URL: " + myURL);

      // return $http.get(URLS.MEMSTAT)
      return $http.get(myURL)
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

    function buildMemstatURL() {
      return 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
             subsystem + '/date/' + date;
    }

  }

})();