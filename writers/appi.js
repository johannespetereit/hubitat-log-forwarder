const fs = require('fs');
const path_util = require('path');
const debug = require('./debug.js');
const appInsights = require('applicationinsights');
appInsights.setup(process.env.APPI_KEY);
appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "Hubitat";
appInsights.defaultClient.addTelemetryProcessor(setCloudRole);
appInsights.start();
console.log('appi key = ' + process.env.APPI_KEY)

var config = require('./../config.json');
console.log(config.hub.hub_host)

module.exports = {
    write: function (data, writer) {
        var telemetry = appInsights.defaultClient;
        if (data.level) {
            telemetry.trackTrace({ message: data.msg, severity: mapSeverity(data.level), properties: data });
        }
        fs.appendFile(writer.path, JSON.stringify(data), function (err) {
            if (err)
                throw err;
        });
    }
}
function mapSeverity(hubitatSeverity) {
    switch (hubitatSeverity) {
        case "debug":
            return appInsights.Contracts.SeverityLevel.Verbose
        case "info":
            return appInsights.Contracts.SeverityLevel.Information
        case "warning":
            return appInsights.Contracts.SeverityLevel.Warning
        case "error":
            return appInsights.Contracts.SeverityLevel.Error
        default:
            return appInsights.Contracts.SeverityLevel.Critical
    }
}
function setCloudRole(envelope, context) {
    console.log(JSON.stringify(context));
    if (envelope.data.baseType === "MessageData") {
        envelope.tags["ai.cloud.roleInstance"] = "Hubitat"
        console.log(JSON.stringify(envelope));
    }
    // context.Cloud.RoleName = "Hubitat";
    if (envelope.data.baseType === "ExceptionData") {
        // var data = envelope.data.baseData;
        // if (data.exceptions && data.exceptions.length > 0) {
        //     for (var i = 0; i < data.exceptions.length; i++) {
        //         var exception = data.exceptions[i];
        //         exception.parsedStack = null;
        //         exception.hasFullStack = false;
        //     }
        // }
    }
    return true;
}