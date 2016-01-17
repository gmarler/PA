angular.module('PA', [
  ])
  .directive("hostinfo", function () {
    return {
      restrict:  "A",
      templateUrl:  "hostinfo.html",
      link: function (scope, element, attrs) {
        scope.selectedHostName     = "Select Hostname";
        scope.selectedHostTimeZone = "N / A";
        scope.selectedHostId       = undefined;

        scope.hostSelected = function (hostobj) {
          scope.selectedHostName     = hostobj.name;
          scope.selectedHostTimeZone = hostobj.time_zone;
          scope.selectedHostId       = hostobj.id;
        }
      }
    };
  })
  .factory('Hosts', function () {
    console.log("Creating Hosts Factory");
    var Hosts = [
      {"id": 1, "name": "nydevsol10", "time_zone": "America/New_York"},
      {"id": 2, "name": "sundev51", "time_zone": "America/New_York"},
      {"id": 3, "name": "p315", "time_zone": "Europe/London"},
      {"id": 4, "name": "solperf1", "time_zone": "America/New_York"}
    ];

    return Hosts;
  })
  .factory('Subsystems', function () {
    var Subsystems = [
      {"name": "CPU"}
    ];

    return Subsystems;
  })
  .factory('HostService', ['$http', function ($http) {
    var urlBase = 'http://nydevsol10.dev.bloomberg.com:5000';
    var HostService = {};
    HostService.getHosts = function () {
      return $http.get(urlBase + '/host');
    };

    return HostService;
  }])
  .controller('HostCtrl', ['$scope', 'HostService', function ($scope, HostService) {
    // $scope.hosts = HostService;
    console.log("Ran the Host Controller");

    HostService.getHosts()
      .success(function (hosts) {
        $scope.hosts = _.map(hosts, function( value, key) {
          var host  = {};
          host["name"] = key;
          _.each(value, function( value, key ) {
            host[key] = value;
          });
          return host;
        });
      })
      .error(function (error) {
        $scope.status = 'Unable to load subject data: ' + error.message;
        console.log('Unable to load subject data: ' + error.message);
      });

  }])
;