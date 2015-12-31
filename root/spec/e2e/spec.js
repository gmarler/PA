describe('initial test', function() {

  beforeEach(function() {
    browser.get('/');
  });

  it('should have title', function() {
    expect(browser.getTitle()).toEqual('Initial Protractor Test');
  });
});