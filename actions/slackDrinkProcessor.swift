import KituraNet
import SwiftyJSON

func main(args: [String:Any]) -> [String:Any] {
    print ("slackDrinkProcessor called")

    // validate args
    guard
        let command = args["command"] as? String,
        let channelId = args["channel_id"] as? String,
        let channelName = args["channel_name"] as? String,
        let userId = args["user_id"] as? String,
        let username = args["user_name"] as? String,
        let responseUrl = args["response_url"] as? String,
        let token = args["token"] as? String,
        let text = args["text"] as? String
    else {
        return createResponse(["error": "Missing argument. Must have command, channel_id, channel_name, user_id, user_name, response_url, token, text"], code: 400)
    }

    if (token != args["slack_verification_token"] as! String) {
        return createResponse(["response_type": "ephemeral", "text": "Missing Slack verification token"])
    }

    // "command" must be "drink"
    if command != "/drink" {
        return createResponse(["response_type": "ephemeral", "text": "You didn't ask for a drink!"])
    }

    // text must be "please"
    if text != "please" {
        return createResponse(["response_type": "ephemeral", "text": "You didn't ask nicely!"])
    }

    print("Calling choose action")

    // call choose action
    let env = ProcessInfo.processInfo.environment
    let namespace : String = env["__OW_NAMESPACE"] ?? ""
    let incrementAction = "/" + namespace + "/DC/choose"
    let result = Whisk.invoke(actionNamed: incrementAction, withParameters: [
        "username": username
    ])
    
    let jsonResult = JSON(result)
    if jsonResult["response"]["success"].boolValue == false {
        return createResponse(["response_type": "ephemeral", "text": "I couldn't select a drink for you at this time, sorry!"])
    }

    let drink = jsonResult["response"]["result"]["recommendation"].stringValue

    print("How about \(drink), \(username)?")
    // print("Result: \(result)")

    let body: [String:Any] = [
        "response_type": "in_channel",
        "text" : "How about \(drink), \(username)?"
    ]

    if responseUrl != "" {
        print("posting to \(responseUrl)")
        postJsonTo(responseUrl, data: body) { response in
        }
    }

    return createResponse(body)
}

func postJsonTo(_ url: String, data: [String:Any], callback: @escaping ClientRequest.Callback) {
    let jsonBody = WhiskJsonUtils.dictionaryToJsonString(jsonDict: data) ?? ""
    let base64Body = Data(jsonBody.utf8)
    postTo(url, body: base64Body, headers: ["Content-Type": "application/json"], callback: callback)
}

func postTo(_ url: String, body: Data, headers: [String: String], callback: @escaping ClientRequest.Callback)  {
    var options: [ClientRequest.Options] = [
        .schema(""),
        .method("POST"),
        .hostname(url),
        .headers(headers)
    ]

    var result: [String:Any] = ["result": "No response"]

    let request = HTTP.request(options, callback: callback)
    request.write(from: body)
    request.end() // send request
}
