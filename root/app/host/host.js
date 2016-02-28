(function() {
  'use strict';

  angular.module('pa.host', [
    'pa.models.host'
  ])

  .controller('HostCtrl', function (HostModel) {
    var hostCtrl = this;

    HostModel.getHosts()
      .then(function(result) {
        hostCtrl.hosts = result;
        console.log(hostCtrl.hosts)
      });
  })

  .directive('hostInfo', function() {
      return {
        restrict: 'AE',
        templateUrl: 'app/host/host.tmpl.html',
        replace:     true
      };
    }
  )
  ;

})();