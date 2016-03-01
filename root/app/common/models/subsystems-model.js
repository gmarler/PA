(function() {
  'use strict';

  angular.module('pa.models.subsystems', [])

  .service('SubsystemsModel', function ($http) {
    var model = this,
        subsystems,
        URLS = {
          FETCH: 'data/subsystems.json'
        };

    function extract(result) {
      return result.data;
    }

    model.getSubsystems = function () {
      return $http.get(URLS.FETCH).then(extract);
    }
  })
  ;

})();