
function createResponse(data, code) {
    return {
        'code': code,
        'headers': {'Content-Type':'application/json'},
        'body': new Buffer(JSON.stringify(data)).toString('base64'),
    };
}

function main(args) {
    console.log("started slackDrink.js");

    if (args["token"] != args["slack_verification_token"]) {
        return createResponse({"response_type": "ephemeral", "text": "Missing Slack verification token"}, 400);
    }

    var openwhisk = require('openwhisk');
    var ow = openwhisk();
    

    var action = "/" + process.env["__OW_NAMESPACE"] + "/DC/slackDrinkProcessor"
    console.log("action:", action)
    var promise = ow.actions.invoke({actionName: action, blocking:true, params:args})
    promise.then(function (result) {
        console.log("Finished: ", result);
    }).catch(function (err) {
        console.log("err", err);
        return createResponse({"response_type": "ephemeral", "text": "Failed to invoke action"}, 400);
    })

    console.log("Done")
    return createResponse({response_type: 'in_channel'}, 200);
}
