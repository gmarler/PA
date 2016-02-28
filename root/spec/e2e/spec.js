describe('initial test', function() {

  beforeEach(function() {
    browser.get('/');
  });

  it('should have title', function() {
    expect(browser.getTitle()).toEqual('Performance Analytics for Solaris');
  });
});

// Use Page Object Pattern
var PAHomepage = function() {
  this.get = function() {
    browser.get('/');
  };

  this.getTitle = function() {
    return element(by.css('title'));
  };
};

describe('PA HomePage', function() {
  it('should have the expected title', function() {
    var ExpectedTitle = "Performance Analytics for Solaris";

    var pahomepage = new PAHomepage();

    pahomepage.get();

    expect(pahomepage.getTitle().getInnerHtml()).toEqual(ExpectedTitle);
    expect(pahomepage.getTitle().getAttribute("text")).toEqual(ExpectedTitle);
  });
});