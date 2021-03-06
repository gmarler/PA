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

  this.getHostInfo = function() {
    return element(by.css('div[host-info]'));
  };

  this.getHostInfoBrand = function() {
    return element(by.css('div[host-info] > nav[role="navigation"] > div.navbar-header > a.navbar-brand'));
  };

  // this.getFirstHostname = function() {
  //   //return element(by.repeater('host in vm.hosts').row(0).column('host.name'));
  //
  //   var result = element.all(by.repeater('host in vm.hosts')).all(by.tagName('a'));
  //   // console.log(result);
  //
  //   result.then(function(welm) {
  //     welm.getText().then(function(txt) {
  //       console.log(txt);
  //     })
  //   });
  //
  //   return result;
  // };

  this.getDropdownSelectedHost = function() {
    var e = element(by.id('host-selected'));

    return e.getText();
  };

  this.getSelectedHostTimeZone = function() {
    var e = element(by.id('host_time_zone'));

    return e.getText();
  };

};

describe('PA HomePage', function() {
  var pahomepage    = new PAHomepage();
  var ExpectedTitle = "Performance Analytics for Solaris";

  pahomepage.get();

  it('should have the expected title', function() {
    expect(pahomepage.getTitle().getInnerHtml()).toEqual(ExpectedTitle);
    expect(pahomepage.getTitle().getAttribute("text")).toEqual(ExpectedTitle);
  });

  it('should have HostInfo navbar', function() {
    expect(pahomepage.getHostInfo().toBeDefined);
  });

  it('should have proper navbar branding title', function() {
    expect(pahomepage.getHostInfoBrand().getAttribute("text").toBeDefined);
  });

  // it('should have a list of hosts in dropdown menu', function() {
  //   // expect(pahomepage.getFirstHostname()).toEqual('nydevsol10');
  //   expect(pahomepage.getFirstHostname().getText()).toContain('nydevsol11');
  // });

  it('should start with unselected host from dropdown menu', function() {
    var selected = pahomepage.getDropdownSelectedHost();

    expect(selected).toContain("Select Hostname");
  });

  it('should start with unselected time zone', function() {
    var selected = pahomepage.getSelectedHostTimeZone();

    expect(selected).toContain("N / A");
  });

  it('should display proper host and time zone upon selection', function() {
    
  });

});