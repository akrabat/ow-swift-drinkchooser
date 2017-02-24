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
    // seed rand()
    let time = UInt32(Date().timeIntervalSince1970)
    print(time)
    srand(time)

    let drinks = HotDrinks()
    let drink = drinks.drinks.randomChoice()
    return [ "Recommendation" : drink ]
}

