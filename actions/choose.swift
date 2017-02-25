
import Glibc
import Foundation
import SwiftyJSON


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

    let env = ProcessInfo.processInfo.environment
    if args["debug"] != nil {
        print ("args: \(args)")
        print ("env: \(env)")

        // set debug to 2 to force an exit (convenience)
        if args["debug"] as! String == "2" {
            return createResponse([
                "args": args,
                "env": env,
            ], code: 200)
        }
    }

    // seed rand()
    let time = UInt32(Date().timeIntervalSince1970)
    srand(time)

    // determine choice of dring
    let drinks = HotDrinks()
    let drink = drinks.drinks.randomElement()

    // call incrementDrinkCount action
    let incrementAction = "/ibm1@19ft.com_craft/DC/incrementDrinkCount"
    let invokeResult = Whisk.invoke(actionNamed: incrementAction, withParameters: ["name": drink])
    let incrementResult = JSON(invokeResult)

    // handle error situations:
    // 1. no response
    // 2. status contains the word "error"
    guard let status = incrementResult["response"]["status"].string else {
        print("error: No response from wsk action")
        return createResponse(["error": "No response from wsk action"], code: 500)
    }
    if status.range(of:"error") != nil {
        let error = incrementResult["response"]["result"]["error"].stringValue
        print("error: \(error)")
        return createResponse(["error": error], code: 500)
    }

    // successful: return the recommended drink
    let body: [String:Any] = ["recommendation" : drink]
    print("response: \(body)")
    return createResponse(body, code: 200)
}
