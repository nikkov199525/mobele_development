import Foundation

class Animal {
    let specs: String
    var name: String
    var age: Int
    var health: Int
    var isAlive: Bool
    
    init(specs: String, name: String) {
        self.specs = specs
        self.name = name
        self.age = Int.random(in: 1...15)
        self.health = Int.random(in: 30...100)
        self.isAlive = true
    }
    
    func eat() {
        if isAlive {
            print("\(specs) \(name) наполняет свой желудок здоровой пищей")
            health += 5
        }
    }
    
    func drink() {
        if isAlive {
            print("\(specs) \(name) пьет жидкость")
            health += 2
        }
    }
    
    func walk() {
        if isAlive {
            print("\(specs) \(name) ведет оздоровительную прогулку по зоопарку")
            health += Int.random(in: -3...5)
        }
    }
    
    func is_ill() {
        if isAlive {
            print("\(specs) \(name) заболел...")
            health -= Int.random(in: 10...30)
            if health <= 0 {
                die()
            }
        }
    }
    
    func reproduce() -> Animal? {
        if isAlive && Int.random(in: 0...100) < 20 {
            let babyName = "Отпрыск \(name)"
            print("\(specs) \(name) увеличивает популяцию  своего вида \(babyName)!")
            return Animal(specs: specs, name: babyName)
        }
        return nil
    }
    
    func die() {
        isAlive = false
        print("\(specs) \(name) погибает...")
    }
}

class Lion: Animal {}
class Elephant: Animal {}
class Zebra: Animal {}
class Monkey: Animal {}
class Snake: Animal {}
class Penguin: Animal {}
class Bear: Animal {}
class Tiger: Animal {}
class Wolf: Animal {}
class Giraffe: Animal {}

class Zoo {
    var animals: [Animal] = []
    
    init() {
        populateZoo()
    }
    
    func populateZoo() {
        let specsList: [(String, () -> Animal)] = [
            ("Лев", { Lion(specs: "Лев", name: "Лев\(Int.random(in: 1...99))") }),
            ("Слон", { Elephant(specs: "Слон", name: "Слон\(Int.random(in: 1...20))") }),
            ("Зебра", { Zebra(specs: "Зебра", name: "Зебра\(Int.random(in: 1...10))") }),
            ("Обезьяна", { Monkey(specs: "Обезьяна", name: "Обезьяна\(Int.random(in: 1...60))") }),
            ("Змея", { Snake(specs: "Змея", name: "Змея\(Int.random(in: 1...120))") }),
            ("Пингвин", { Penguin(specs: "Пингвин", name: "Пингвин\(Int.random(in: 1...10))") }),
            ("Медведь", { Bear(specs: "Медведь", name: "Медведь\(Int.random(in: 1...20))") }),
            ("Тигр", { Tiger(specs: "Тигр", name: "Тигр\(Int.random(in: 1...200))") }),
            ("Волк", { Wolf(specs: "Волк", name: "Волк\(Int.random(in: 1...80))") }),
            ("Жираф", { Giraffe(specs: "Жираф", name: "Жираф\(Int.random(in: 1...10))") })
        ]
        
        for (_, factory) in specsList {
            let count = Int.random(in: 1...10)
            for _ in 0..<count {
                animals.append(factory())
            }
        }
    }
    
    func simulateDay() {
        var newborns: [Animal] = []
        
        for animal in animals {
            guard animal.isAlive else { continue }
            
            let event = Int.random(in: 0...100)
            switch event {
            case 0...25: animal.eat()
            case 26...40: animal.drink()
            case 41...60: animal.walk()
            case 61...75: animal.is_ill()
            case 76...85:
                if let baby = animal.reproduce() {
                    newborns.append(baby)
                }
            default:
                if Int.random(in: 0...100) < 10 {
                    animal.die()
                }
            }
            
            animal.health = min(animal.health, 100)
        }
        
        animals.append(contentsOf: newborns)
        report()
    }
    
    func report() {
        let alive = animals.filter { $0.isAlive }.count
        let dead = animals.count - alive
        print("\n--- Краткая сводка")
        print("Живых обитателей \(alive)")
        print("почивших  \(dead)")
        print("\n")
    }
}

let zoo = Zoo()

for day in 1...20 {
    print("\n Начинается новый прекрасный \(day) день в зоопарке!")
    zoo.simulateDay()
    sleep(1)
}
