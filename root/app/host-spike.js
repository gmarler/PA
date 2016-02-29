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
  .factory('HostService', ['$http', function ($http) {
    var urlBase = 'http://nydevsol10.dev.bloomberg.com:5000';
    var HostService = {};
    HostService.getHosts = function () {
      return $http.get(urlBase + '/host');
    };

    return HostService;
  }])
  .factory('SubsystemsService', [ function() {
    var SubsystemsService = {};

    var Subsystems = [
      {"name": "CPU"},
      {"name": "Memory"},
      {"name": "Filesystems"},
      {"name": "Network"}
    ];

    SubsystemsService.getSubsystems = function () {
      return Subsystems;
    };

    return SubsystemsService;
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
  .directive("subsystems", function () {
    return {
      restrict: "A",
      require: ['hostinfo'],
      templateUrl: "subsystems.html",
      link: function (scope, element, attrs, ctrls) {

      }
    };
  })
  .controller('SubsystemsCtrl', ['$scope', 'SubsystemsService', function($scope, SubsystemsService) {
    console.log("Ran the Subsystems Controller");
    $scope.selectedSubsystem = undefined;

    $scope.subsystems = SubsystemsService.getSubsystems();

    $scope.selectSubsystem = function(subsystemobj) {
      $scope.selectedSubsystem = subsystemobj;
    };
  }])
;