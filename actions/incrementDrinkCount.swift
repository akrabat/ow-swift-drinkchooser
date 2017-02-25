
import Glibc
import Foundation
import SwiftyJSON

func main(args: [String:Any]) -> [String:Any] {

    if args["debug"] != nil {
        print ("args: \(args)")
    }

    // extract settings
    guard let redis_host: String = args["redis_host"] as! String,
        let redis_port: Int32 = Int32(args["redis_port"] as! Int),
        let redis_password: String = args["redis_password"] as! String else {
            return createResponse(["error": "Missing storage credentials"], code: 500)
    }

    // extract drink name
    guard let drink: String = args["name"] as! String else {
        return createResponse(["error": "Missing 'name' parameter"], code: 400)
    }

    // store to Redis
    let redis = Redis()
    var errorResult = ""
    var newCount = ""
    redis.connect(host: redis_host, port: redis_port) { (redisError: NSError?) in
        if let error = redisError {
            print(error)
            errorResult = "Failed to connect to Redis";
        }
        else {
            print("Connected to Redis on \(redis_host):\(redis_port)")

            redis.auth(redis_password) { (redisError: NSError?) in
                if let error = redisError {
                    print(error)
                    errorResult = "Failed to authenicate to Redis";
                }
                else {
                    print("Authenticated to Redis")

                    // add a count to this drink
                    redis.zincrby("drink_counts", increment: 1,  member: drink) { (result: RedisString?, redisError: NSError?) in
                        if let error = redisError {
                            print(error)
                        } else {
                            if let result = result {
                                newCount = result.asString
                                print ("Incrementing '\(drink). It is now \(result)'")
                            }
                        }
                    }
                }
            }
        }
    }

    if (errorResult != "") {
        // error: return error message
        let body: [String:Any] = ["error" : errorResult]
        return createResponse(body, code: 500)
    }

    // successful: return the new count
    let body: [String:Any] = ["drink" : drink, "new_count" : newCount]
    return createResponse(body, code: 200)
}
