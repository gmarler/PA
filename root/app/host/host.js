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
        replace:     false
      };
    }
  )
  ;

})();