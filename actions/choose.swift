
import Glibc
import Foundation

// extend Array to pick a random choice from it
extension Array {
    func randomChoice() -> Element {
        let index = Int(rand()) % count
        return self[index]
    }
}

// Struct for our drinks
struct HotDrinks {
    let drinks = [
        "A nice hot cup of tea!", // The true drink of an Englishman! (even though it was invented in China…)
        "Espresso", // Coffee brewed by forcing a small amount of nearly boiling water under pressure through finely ground coffee beans.
        "Hot chocolate", // Also known as hot cocoa, it typically consists of shaved chocolate, melted chocolate or cocoa powder, heated milk or water, and sugar. Hot egg chocolate is a type of hot chocolate.
        "Anijsmelk", // Dutch drink, consisting of hot milk flavored with anise seed and sweetened with sugar
        "Bandrek", // raditional hot, sweet and spicy beverage native to Sundanese people of West Java, Indonesia. It's a mixture of jahe (ginger) essence, gula merah (palm sugar) and kayu manis (cinnamon).

    ]
}

func main(args: [String:Any]) -> [String:Any] {

    // extract settings
    guard let redis_host: String = args["redis_host"] as! String,
        let redis_port: Int32 = Int32(args["redis_port"] as! Int),
        let redis_password: String = args["redis_password"] as! String else {
        return ["failed": -1]
    }
 
    // seed rand()
    let time = UInt32(Date().timeIntervalSince1970)
    print(time)
    srand(time)

    let drinks = HotDrinks()
    let drink = drinks.drinks.randomChoice()


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
                    redis.zincrby("drink_counts", increment: 1,  member: drink) { (result: RedisString?, redisError: NSError?) in
                        if let error = redisError {
                            print(error)
                        } else {
                            if let result = result {
                                print ("Incrementing '\(drink). It is now \(result)'")
                            }
                        }
                    }
                }
            }
        }
    }

    if (errorResult == "") {
        // successful: return the recommended drink
        return [
            "Recommendation" : drink,
        ]
    }

    // error: return error message and set status code
    return [
        "Failed" : errorResult,
        "code" : 500,
    ]
 
}

