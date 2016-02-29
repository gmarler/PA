(function() {
  'use strict';

  angular.module('pa.host', [
    'pa.models.host'
  ])

  .controller('HostController', function (HostModel) {
    var vm = this;

    HostModel.getHosts()
      .then(function(result) {
        vm.hosts = result;
        console.log(vm.hosts)
      });
  })

  .directive('hostInfo', function() {
      return {
        restrict: 'AE',
        templateUrl: 'app/host/host.tmpl.html',
        replace:     false,
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
    }
  )
  ;

})();