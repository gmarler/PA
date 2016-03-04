(function() {
  'use strict';

  angular
    .module('pa')
    .directive('memstatD3', memstatD3);

  function memstatD3() {
    var directive = {
      restrict:  'AE',
      // templateUrl: 'app/host/host.tmpl.html',
      replace:   true,
      link:      link
    };

    return directive;

    function link(scope,element,attrs) {
      scope.selectedHostName = "Select Hostname";
      scope.selectedHostTimeZone = "N / A";
      scope.selectedHostId = undefined;

      scope.hostSelected = function (hostobj) {
        scope.selectedHostName = hostobj.name;
        scope.selectedHostTimeZone = hostobj.time_zone;
        scope.selectedHostId = hostobj.id;
      };
    }
  }

})();