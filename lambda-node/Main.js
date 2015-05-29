var aws = require('aws-sdk');

aws.config.update({region: 'us-west-2'});

var costWatch = require('./CostWatch');

costWatch.handler({}, {
    done: function(err) {
        console.log(err);
    }
});
