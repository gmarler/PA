angular.module('pa.models.subsystems', [

])
  .service('SubsystemsModel', function () {
    var model = this,
      subsystems = [
        {"id": 1, "name": "CPU"},
        {"id": 2, "name": "MEMORY" },
        {"id": 3, "name": "FILESYSTEM" },
        {"id": 4, "name": "NETWORK" },
        {"id": 5, "name": "KERNEL STACKS" }
      ];

    model.getSubsystems = function () {
      return subsystems;
    }
  })
;