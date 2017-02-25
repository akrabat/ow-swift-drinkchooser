
// import Glibc
import Foundation
import SwiftyJSON

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

func main(args: [String:Any]) -> [String:Any] {

    // extract settings
    guard let redis_host: String = args["redis_host"] as! String,
        let redis_port: Int32 = Int32(args["redis_port"] as! Int),
        let redis_password: String = args["redis_password"] as! String else {
        return ["failed": -1]
    }

    var results = [String: Int]()

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
                    errorResult = "Failed to authenicate to Redis";
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
                            print ("\nlist: \(list)\n")

                            // The results are a list with name followed by count, so we
                            // massage into a hash of [Name: count]
                            var name = ""
                            for (index, element) in list.enumerated() {
                                if index % 2 != 0 {
                                    results[name] = element.asInteger
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

    if (errorResult == "") {
        // successful: return the results
        print ("results: \(results)")
        let body = JSON(results).rawString()!.toBase64()
        return [
            "body": body,
            "code": 200,
            "headers": [
                "Content-Type": "application/json",
            ],
        ]
    }

    // error: return error message and set status code
    let body = JSON(["error" : errorResult]).rawString()!.toBase64()
    return [
        "body": body,
        "code": 500,
        "headers": [
            "Content-Type": "application/json",
        ],
    ]
}


