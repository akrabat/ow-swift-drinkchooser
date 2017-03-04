
func main(args: [String:Any]) -> [String:Any] {
    print ("slackDrink called")

    var userArgs = args
    userArgs["__ow_meta_path"] = nil
    userArgs["__ow_meta_verb"] = nil
    userArgs["__ow_meta_headers"] = nil
    userArgs["redis_host"] = nil
    userArgs["redis_port"] = nil
    userArgs["redis_password"] = nil
    print("userArgs: \(userArgs)")

    // validate args
    guard
        let command = args["command"] as? String,
        let channelId = args["channel_id"] as? String,
        let channelName = args["channel_name"] as? String,
        let userId = args["user_id"] as? String,
        let username = args["user_name"] as? String,
        let text = args["text"] as? String
    else {
        return createResponse(["error": "Missing argument. Must have command, channel_id, channel_name, user_id, user_name, text"], code: 400)
    }

    // "command" must be "drink"
    if command != "/drink" {
        return createResponse(["text": "You didn't ask for a drink!"], code: 400)
    }

    // text must be "please"
    if text != "please" {
        return createResponse(["text": "You didn't ask nicely!"], code: 400)
    }

    print("")
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
        return createResponse(["text": "I couldn't select a drink for you at this time, sorry!"], code: 400)
    }

    let drink = jsonResult["response"]["result"]["recommendation"].stringValue

    print("How about \(drink), \(username)?")
    // print("Result: \(result)")

    let body: [String:Any] = [
        "response_type": "in_channel",
        "text" : "How about \(drink), \(username)?"
    ]
    return createResponse(body)
}