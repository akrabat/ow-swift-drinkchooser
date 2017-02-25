
import Foundation


func main(args: [String:Any]) -> [String:Any] {

    if args["debug"] != nil {
        print ("args: \(args)")
    }

    // extract settings
    guard let redis_host: String = args["redis_host"] as! String,
        let redis_port: Int32 = Int32(args["redis_port"] as! Int),
        let redis_password: String = args["redis_password"] as! String else {
        return ["failed": -1]
    }

    var results: Array<[String:Int]> = Array()

    let redis = Redis()
    var errorResult = ""
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
                    errorResult = "Failed to authenticate to Redis";
                }
                else {
                    print("Authenticated to Redis")

                    // add a count to this drink
                    redis.zrevrange("drink_counts", start: 0, stop: 10, withscores: true) {
                        (list: [RedisString?]?, redisError: NSError?) in

                        if let error = redisError {
                            print(error)
                        } else {
                            // unwrap list
                            guard let list = list?.flatMap({ $0 }) else {
                                return
                            }
                            // print ("list: \(list)\n")

                            // The results are a list with name followed by count, so we
                            // massage into a hash of [Name: count]
                            var name = ""
                            for (index, element) in list.enumerated() {
                                if index % 2 != 0 {
                                    results.append([name: element.asInteger])
                                } else {
                                    name = element.asString
                                }
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

    // successful: return the results
    print ("results: \(results)\n")
    return createResponse(["results": results], code: 200)
}
