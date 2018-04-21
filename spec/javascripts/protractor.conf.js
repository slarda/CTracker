// An example configuration file.
require('coffee-script');

exports.config = {
    // The address of a running selenium server.
    seleniumAddress: 'http://localhost:4444/wd/hub',

    // Capabilities to be passed to the webdriver instance.
    capabilities: {
        'browserName': 'chrome'
    },

    // Spec patterns are relative to the current working directly when
    // protractor is called.
    specs: ['authentication.coffee', 'protractor_specs/**/*.js', 'protractor_specs/**/*.coffee'],

    baseUrl: 'http://localhost:4000',

    // Options to be passed to Jasmine-node.
    jasmineNodeOpts: {
        showColors: true,
        defaultTimeoutInterval: 30000
    },

    // 'by' is reserved in coffee script
    // http://stackoverflow.com/questions/24098434/protractor-tests-in-coffeescript-producing-syntaxerror-unexpected-by
    onPrepare: function() {
        global.By = global.by;
    }

};
