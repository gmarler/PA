angular.module('subsystems', [
  'pa.models.subsystems'
])
  .config(function($stateProvider) {
    $stateProvider
      .state('subsystems', {
        url: '/',
        views: {
          'subsystems@': {
            controller: 'SubsystemsCtrl',
            templateUrl: 'subsystems/subsystems.tmpl.html'
          }
        }
      })
  })
  .controller('SubsystemsCtrl', function SubsystemsCtrl($scope) {

  })
;