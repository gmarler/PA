(function() {
  'use strict';

  angular
    .module('pa.services.host', ['ngMessages'])
    .factory('HostService', HostService);

  HostService.$inject = [ '$http', '$location', '$log', '$q' ];

  function HostService($http, $location, $log, $q) {
    var data_pullable,
        hosts,
        memstats,
        PAServer,
    // If the web server port is 80, then it's likely PROD, and thus the
    // PA Server port should also be PROD.
    // Otherwise, we're either pointed at the WebStorm DEV web server,
    // or the Catalyst DEV web server, both of which will need the DEV
    // PA Server that resides on port 5000.
        port      = $location.port() == 80 ? 80 : 5000,
        hostname,
        hostID,
        hostTimeZone,
        subsystem,
        date      = moment().format('YYYY-MM-DD');

    var service = {
      data_pullable:   false,
      hosts:           hosts,
      PAServer:        PAServer,
      port:            port,
      hostname:        hostname,
      hostID:          hostID,
      hostTimeZone:    hostTimeZone,
      subsystem:       subsystem,
      date:            date,

      setPAServer:                  setPAServer,
      getPAServer:                  getPAServer,
      setHostname:                  setHostname,
      getHostname:                  getHostname,
      setHostID:                    setHostID,
      getHostID:                    getHostID,
      setHostTimeZone:              setHostTimeZone,
      getHostTimeZone:              getHostTimeZone,
      setDate:                      setDate,
      extract:                      extract,
      cacheHosts:                   cacheHosts,
      getHosts:                     getHosts,
      getMemstat:                   getMemstat,
      getHostDateSubsystemMetric:   getHostDateSubsystemMetric
    };

    return service;

    // FUNCTION DEFINITIONS

    function setPAServer(server) {
      $log.debug("Updating PA Server to: " + server);
      PAServer = server;
    }

    function getPAServer() {
      return PAServer;
    }

    function setHostname(newHostname) {
      hostname = newHostname;
    }

    function getHostname() {
      return hostname;
    }

    function setHostID(hostid) {
      hostID = hostid;
    }

    function getHostID() {
      return hostID;
    }

    function setHostTimeZone(timezone) {
      hostTimeZone = timezone;
    }

    function getHostTimeZone() {
      return hostTimeZone;
    }

    function setDate(newdate) {
      date = moment(newdate).format('YYYY-MM-DD');
      data_pullable = true;
      return date;
    }

    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    function getHosts() {
      $log.debug("CALLING HostService.getHosts()");
      var hostsURL = buildHostsURL();

      return $http.get(hostsURL)
        .then(getHostsComplete)
        .catch(getHostsFailed);

      function getHostsComplete(response) {
        hosts = extract(response);
        $log.info("HostService.getHosts() returns:");
        $log.info($log.infohosts);
        return hosts;
      }

      function getHostsFailed(error) {
        $log.error("ERROR: XHR Failed for getHosts." + error.statusText);
        return $q.reject(error);
      }
    }

    function getMemstat() {
      var myURL = buildMemstatURL();
      console.log("URL: " + myURL);

      return $http.get(myURL)
                  .then(getMemstatComplete)
                  .catch(getMemstatFailed);

      function getMemstatComplete(response) {
        memstats = extract(response);
        // console.log(memstats);
        return memstats;
      }

      function getMemstatFailed(error) {
        $log.debug("ERROR: XHR Failed for getMemstat." + error.data);
      }
    }

    function buildHostsURL() {
      var URL = 'http://' + PAServer + ':' + port + '/hosts';
      $log.debug("buildHostsURL built: " + URL);
      return URL;
    }

    function buildMemstatURL() {
      return 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
             subsystem + '/date/' + date;
    }

    function getHostDateSubsystemMetric(callback, subsystem, metric) {
      // Build REST request to fetch data for this particular subsystem and metric

      // If any of the items are undefined, then don't perform the request, just return an empty
      // array
      if ((PAServer === undefined) || (port === undefined) || (hostname === undefined) ||
          (date === undefined) || (subsystem === undefined) ||
          (metric === undefined)) {
        $log.debug("NOT PULLING ANY DATA");
        return [];
      }

      var myURL = 'http://' + PAServer + ':' + port + '/host/' + hostname +
                  '/date/' + date + '/subsystem/' + subsystem +
                  '/metric/' + metric;
      $log.debug("getHostDateSubsystemMetric URL: " + myURL);

      // Perform request
      return $http.get(myURL)
        .then(getHostDateSubsystemMetricComplete)
        .catch(getHostDateSubsystemMetricFailed);

      function getHostDateSubsystemMetricComplete(response) {
        memstats = extract(response);
        // Now we set the timestamps, which are in UTC, to the time zone the host resides in for
        // display in D3
        // var hostTZ = getHostTimeZone();

        //_.each(memstats,function(element) {
        //  console.log(element.timestamp);
        //  // console.log(moment(element.timestamp).tz(hostTZ));
        //  // Multiply by 1000 to convert from epoch seconds (in UTC) to epoch millisecs
        //  // element.timestamp = moment(element.timestamp * 1000).tz(hostTZ);
        //});
        // Now we pass the results into the callback
        callback(memstats);
        // return memstats;
      }

      function getHostDateSubsystemMetricFailed(error) {
        $log.error("ERROR: XHR Failed for getHostDateSubsystemMetricFailed." + error.data);
        return $q.reject(error);
      }
    }

  }

})();