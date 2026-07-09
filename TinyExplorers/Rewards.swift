import SwiftUI

// MARK: - Explorer buddy

/// The kid's chosen companion. It waves on the home screen, greets them by
/// time of day, and cheers in the sticker book.
struct Buddy: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let hello: String
    /// Global level at which this buddy becomes choosable. Starter buddies are
    /// level 1; the rest unlock as the kid earns stars, so the picker keeps
    /// growing new friends to discover.
    var unlockLevel: Int = 1

    static let all: [Buddy] = [
        Buddy(id: "fox", name: "Foxy", emoji: "🦊", hello: "Hi, I'm Foxy! Let's explore!"),
        Buddy(id: "bunny", name: "Hopper", emoji: "🐰", hello: "Hi, I'm Hopper! Hop hop!"),
        Buddy(id: "panda", name: "Bamboo", emoji: "🐼", hello: "Hi, I'm Bamboo! Let's play!"),
        Buddy(id: "frog", name: "Croaky", emoji: "🐸", hello: "Hi, I'm Croaky! Ribbit!", unlockLevel: 2),
        Buddy(id: "chick", name: "Chirpy", emoji: "🐥", hello: "Hi, I'm Chirpy! Cheep cheep!", unlockLevel: 2),
        Buddy(id: "cat", name: "Whiskers", emoji: "🐱", hello: "Hi, I'm Whiskers! Meow!", unlockLevel: 3),
        Buddy(id: "bear", name: "Honey", emoji: "🐻", hello: "Hi, I'm Honey! Big bear hug!", unlockLevel: 4),
        Buddy(id: "unicorn", name: "Sparkle", emoji: "🦄", hello: "Hi, I'm Sparkle! Magic time!", unlockLevel: 5),
        Buddy(id: "penguin", name: "Waddles", emoji: "🐧", hello: "Hi, I'm Waddles! Brrr, let's go!", unlockLevel: 6),
        Buddy(id: "dino", name: "Rexy", emoji: "🦖", hello: "Hi, I'm Rexy! Roar roar!", unlockLevel: 8),
    ]

    static func find(_ id: String) -> Buddy {
        all.first { $0.id == id } ?? all[0]
    }

    /// True when the kid's global level has reached this buddy's unlock gate.
    func isUnlocked(atLevel level: Int) -> Bool { level >= unlockLevel }
}

/// Persisted choice of buddy.
final class Profile: ObservableObject {
    static let shared = Profile()

    @Published var buddyID: String {
        didSet { UserDefaults.standard.set(buddyID, forKey: defaultsKey) }
    }

    private let defaultsKey = "TinyExplorers.buddy"

    private init() {
        buddyID = UserDefaults.standard.string(forKey: defaultsKey) ?? "fox"
    }

    var buddy: Buddy { Buddy.find(buddyID) }

    /// "Good morning" / "afternoon" / "evening" greeting for the home header.
    static func greeting(hour: Int = Calendar.current.component(.hour, from: Date())) -> String {
        switch hour {
        case 5..<12: return "Good morning, explorer!"
        case 12..<17: return "Good afternoon, explorer!"
        default: return "Good evening, explorer!"
        }
    }
}

// MARK: - Sticker collection

struct Sticker: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let cost: Int
}

struct StickerPack: Identifiable {
    let id: String
    let title: String
    let emoji: String
    let accent: Color
    /// Global level that reveals this pack. Locked packs show as silhouettes
    /// with a "Reach Level N" teaser, so the collection visibly grows.
    var unlockLevel: Int = 1
    let stickers: [Sticker]

    func isUnlocked(atLevel level: Int) -> Bool { level >= unlockLevel }

    static let all: [StickerPack] = [
        StickerPack(
            id: "animals", title: "Animal Pals", emoji: "🐾",
            accent: Color(red: 0.22, green: 0.66, blue: 0.34),
            stickers: [
                Sticker(id: "lion", name: "Lion", emoji: "🦁", cost: 8),
                Sticker(id: "koala", name: "Koala", emoji: "🐨", cost: 10),
                Sticker(id: "giraffe", name: "Giraffe", emoji: "🦒", cost: 12),
                Sticker(id: "flamingo", name: "Flamingo", emoji: "🦩", cost: 15),
                Sticker(id: "octopus", name: "Octopus", emoji: "🐙", cost: 18),
                Sticker(id: "dragon", name: "Dragon", emoji: "🐉", cost: 25),
            ]
        ),
        StickerPack(
            id: "space", title: "Space Explorers", emoji: "🚀",
            accent: Color(red: 0.42, green: 0.40, blue: 0.91),
            unlockLevel: 3,
            stickers: [
                Sticker(id: "rocket", name: "Rocket", emoji: "🚀", cost: 8),
                Sticker(id: "moon", name: "Moon", emoji: "🌙", cost: 10),
                Sticker(id: "planet", name: "Planet", emoji: "🪐", cost: 12),
                Sticker(id: "astronaut", name: "Astronaut", emoji: "👩‍🚀", cost: 15),
                Sticker(id: "ufo", name: "UFO", emoji: "🛸", cost: 18),
                Sticker(id: "comet", name: "Comet", emoji: "☄️", cost: 25),
            ]
        ),
        StickerPack(
            id: "ocean", title: "Ocean Friends", emoji: "🌊",
            accent: Color(red: 0.0, green: 0.6, blue: 0.78),
            unlockLevel: 5,
            stickers: [
                Sticker(id: "fish", name: "Fish", emoji: "🐠", cost: 8),
                Sticker(id: "crab", name: "Crab", emoji: "🦀", cost: 10),
                Sticker(id: "dolphin", name: "Dolphin", emoji: "🐬", cost: 12),
                Sticker(id: "whale", name: "Whale", emoji: "🐳", cost: 15),
                Sticker(id: "shell", name: "Seashell", emoji: "🐚", cost: 18),
                Sticker(id: "mermaid", name: "Mermaid", emoji: "🧜‍♀️", cost: 25),
            ]
        ),
        StickerPack(
            id: "treats", title: "Sweet Treats", emoji: "🍭",
            accent: Color(red: 0.93, green: 0.38, blue: 0.62),
            unlockLevel: 8,
            stickers: [
                Sticker(id: "strawberry", name: "Strawberry", emoji: "🍓", cost: 8),
                Sticker(id: "icecream", name: "Ice Cream", emoji: "🍦", cost: 10),
                Sticker(id: "donut", name: "Donut", emoji: "🍩", cost: 12),
                Sticker(id: "cupcake", name: "Cupcake", emoji: "🧁", cost: 15),
                Sticker(id: "lollipop", name: "Lollipop", emoji: "🍭", cost: 18),
                Sticker(id: "cake", name: "Rainbow Cake", emoji: "🎂", cost: 25),
            ]
        ),
    ]

    static var totalStickerCount: Int {
        all.reduce(0) { $0 + $1.stickers.count }
    }
}

/// Persisted set of unlocked stickers. Unlocking spends stars from StarBank,
/// which is what makes earning stars in games mean something.
final class StickerAlbum: ObservableObject {
    static let shared = StickerAlbum()

    @Published private(set) var unlocked: Set<String>

    private let defaultsKey = "TinyExplorers.stickers"

    private init() {
        unlocked = Set(UserDefaults.standard.stringArray(forKey: defaultsKey) ?? [])
    }

    var unlockedCount: Int { unlocked.count }

    func isUnlocked(_ sticker: Sticker) -> Bool { unlocked.contains(sticker.id) }

    /// Spends stars and unlocks; returns false when the kid can't afford it yet.
    func unlock(_ sticker: Sticker) -> Bool {
        guard !isUnlocked(sticker), StarBank.shared.spend(sticker.cost) else { return false }
        unlocked.insert(sticker.id)
        UserDefaults.standard.set(Array(unlocked), forKey: defaultsKey)
        return true
    }
}

// MARK: - Daily gift

/// Once-a-day surprise box on the home screen: the "come back tomorrow" hook.
final class DailyGift: ObservableObject {
    static let shared = DailyGift()

    @Published private(set) var lastOpenedDay: String?

    private let defaultsKey = "TinyExplorers.dailyGiftDay"

    private init() {
        lastOpenedDay = UserDefaults.standard.string(forKey: defaultsKey)
    }

    private static func dayStamp(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    var isReady: Bool { lastOpenedDay != Self.dayStamp() }

    /// Opens today's gift and returns the number of bonus stars awarded.
    func open() -> Int {
        guard isReady else { return 0 }
        lastOpenedDay = Self.dayStamp()
        UserDefaults.standard.set(lastOpenedDay, forKey: defaultsKey)
        let reward = Int.random(in: 3...7)
        StarBank.shared.award(reward, to: "bonus")
        return reward
    }
}

// MARK: - Sticker book theme

extension GameTheme {
    /// Golden treasure-book look for the sticker collection screen.
    static let stickers = GameTheme(
        key: "stickers",
        accent: Color(red: 0.85, green: 0.6, blue: 0.05),
        gradientTop: Color(red: 1.0, green: 0.94, blue: 0.80),
        gradientBottom: Color(red: 1.0, green: 0.90, blue: 0.86),
        floaters: ["✨", "🌟", "🎁"],
        mascot: "🦊"
    )
}
