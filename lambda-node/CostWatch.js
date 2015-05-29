var aws = require('aws-sdk');
var async = require('async');
var moment = require('moment');

var ec2 = new aws.EC2({apiVersion: '2014-10-01'});

var defaultTimeToLive = moment.duration(4, 'hours');

exports.handler = function (event, context) {

  function shouldStop(instance) {
    var timeToLive = moment.duration(defaultTimeToLive.asMilliseconds());
    instance.Tags.forEach(function (tag) {
      if (tag.Key == 'permanent') {
        return false;
      } else if (tag.Key == "ttl-hours") {
        timeToLive = moment.duration(tag.Value, 'hours');
      }
    });

    var upTime = new Date().getTime() - instance.LaunchTime.getTime();

    if (upTime < timeToLive.asMilliseconds()) {
      timeToLive.subtract(upTime);
      console.log("Instance (" + instance.InstanceId + ") has " + timeToLive.humanize() + " remaining.");
      return false;
    }
    return true;
  }

  async.waterfall([
      function fetchEC2Instances(next) {
        var ec2Params = {
          Filters: [
            {Name: 'instance-state-name', Values: ['running']}
          ]
        };

        ec2.describeInstances(ec2Params, function (err, data) {
          next(null, err, data)
        });
      },
      function filterInstances(err, data, next) {
        var stopList = [];

        data.Reservations.forEach(function (res) {
          res.Instances.forEach(function (instance) {
            if (shouldStop(instance)) {
              stopList.push(instance.InstanceId);
            }
          });
        });
        next(null, stopList);
      },
      function stopInstances(stopList, next) {
        if (stopList.length > 0) {
          ec2.stopInstances({InstanceIds: stopList}, function (err, data) {
            if (err) {
              nex(err);
            }
            else {
              console.log(data);
              next(null);
            }
          });
        }
        else {
          console.log("No instances need to be stopped");
          next(null);
        }
      }
    ],
    function (err) {
      if (err) {
        console.error('Failed to clean EC2 instances: ', err);
      } else {
        console.log('Successfully cleaned all unused EC2 instances.');
      }
      context.done(err);
    });
};
