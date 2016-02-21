angular.module('pa.host', [
  'pa.models.host'
])
  .config(function($stateProvider) {
    $stateProvider
      .state('pa.host', {
        url: '/',
        views: {
          'host@': {
            controller: 'HostCtrl as hostCtrl',
            templateUrl: 'host/host.tmpl.html'
          }
        }
      })
  })
  .controller('HostCtrl', function ($stateParams, HostModel ) {
    var hostCtrl = this;

    //hostCtrl.currentHostID       = $stateParams.host.id;
    //hostCtrl.currentHostName     = $stateParams.host.name;
    //hostCtrl.currentHostTimeZone = $stateParams.host.time_zone;

    HostModel.getHosts()
      .then(function(result) {
        hostCtrl.hosts = result;
        console.log(hostCtrl.hosts)
      });
  })
;