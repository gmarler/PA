exports.config = {
  // chromeOnly: true,
  framework: 'jasmine',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  specs: ['root/spec/e2e/spec.js']
  //jasmineNodeOpts: {
  //  showColors: true, // use colors in the command line report
  //  defaultTimeoutInterval: 30000
  //},
  //baseUrl: 'http://localhost:8080/'
};