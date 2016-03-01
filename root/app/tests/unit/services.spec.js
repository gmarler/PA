describe('PA Services Tests', function() {
  var HostService;
  var $httpBackend;
  var url;

  beforeEach(module('PA'));

  beforeEach(inject(function($injector) {
    HostService = $injector.get('HostService');
    $httpBackend = $injector.get('$httpBackend');
  }));

  afterEach(function() {
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest();
  });

  it('HostService should have getHosts Method Defined', function() {
    expect(HostService.getHosts).toBeDefined();
  });

  it('HostService getHosts should make a GET request', function() {
    url = 'http://PAserver.example.com:5000/host';

    $httpBackend.when('GET', url).respond(
      [
        {"id": 1, "name": "nydevsol10", "time_zone": "America/New_York"},
        {"id": 2, "name": "sundev51", "time_zone": "America/New_York"},
        {"id": 3, "name": "p315", "time_zone": "Europe/London"},
        {"id": 4, "name": "solperf1", "time_zone": "America/New_York"}
      ]
    );

    $httpBackend.expectGET(url);
    HostService.getHosts();
    $httpBackend.flush();
  });

  // TODO: Test a call to /host which fails, to make sure the service copes with it correctly.

});