(function() {
  'use strict';

  angular.module('pa', [
    'pa.host',
    'pa.subsystems',
    'ui.bootstrap'
  ]);

})();

//  .config(function($stateProvider, $urlRouterProvider) {
//    $stateProvider
//      .state('pa', {
//        url:      '',
//        abstract: true
//        // templateUrl: 'subsystems/subsystems.tmpl.html',
//        // controller: 'MainCtrl'
//      })
//    ;
//
//    $urlRouterProvider.otherwise('/');
//  })
//  .controller('MainCtrl', function ($scope) {
//    $scope.hosts = [
//      {"id": 1, "name": "nydevsol10", "time_zone": "America/New_York"},
//      {"id": 2, "name": "sundev51", "time_zone": "America/New_York"},
//      {"id": 3, "name": "p315", "time_zone": "Europe/London"},
//      {"id": 4, "name": "solperf1", "time_zone": "America/New_York"}
//    ];
//
//    $scope.subsystems = [
//      {"name": "CPU"}
//    ];
//});