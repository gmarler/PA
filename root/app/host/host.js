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

    hostCtrl.hosts               = HostModel.getHosts();
    console.log(hostCtrl.hosts);
  })
;