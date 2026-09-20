import Foundation

enum TreasureCatalog {
    static let all: [Treasure] = [
        .init(id: "star-drop", name: "ほしのしずく", flavor: "よるの空からおちてきた、ひかりのかけら。", rarity: .rare, shape: .gem, hue: 210),
        .init(id: "gold-acorn", name: "きんのドングリ", flavor: "もりのみずかみが、だいじにとっておいたおやつ。", rarity: .common, shape: .acorn, hue: 38),
        .init(id: "moon-pendant", name: "つきのペンダント", flavor: "みかづきが、小さなアクセサリーになったよ。", rarity: .rare, shape: .medal, hue: 48),
        .init(id: "rainbow-orb", name: "にじのたま", flavor: "てにすると、へやのなかがにじいろにひかる。", rarity: .legendary, shape: .orb, hue: 280),
        .init(id: "tiny-crown", name: "ちいさなおうかん", flavor: "だれでも、きょうだけはおうさま。", rarity: .rare, shape: .crown, hue: 46),
        .init(id: "magic-key", name: "まほうのカギ", flavor: "まだみたことのないとびらが、どこかにあるらしい。", rarity: .common, shape: .key, hue: 28),
        .init(id: "owl-medal", name: "ふくろうのメダル", flavor: "かしこいぼうけんかだけがもらえるしるし。", rarity: .rare, shape: .medal, hue: 25),
        .init(id: "sea-pearl", name: "うみのパール", flavor: "しずかなうみが、まるめてくれたたま。", rarity: .common, shape: .orb, hue: 180),
        .init(id: "dragon-scale", name: "りゅうのウロコ", flavor: "やさしいりゅうが、おみやげにくれたひとかけ。", rarity: .legendary, shape: .gem, hue: 150),
        .init(id: "secret-map", name: "ひみつのちず", flavor: "つぎのぼうけんが、うすくかいてある。", rarity: .common, shape: .map, hue: 32),
        .init(id: "fairy-feather", name: "フェアリーのはね", flavor: "かぜにのると、すこしだけうかびそう。", rarity: .rare, shape: .feather, hue: 310),
        .init(id: "ruby-shard", name: "ルビーのかけら", flavor: "あかくて、あったかい。てのひらがにえるみたい。", rarity: .common, shape: .gem, hue: 0),
        .init(id: "gold-compass", name: "きんのコンパス", flavor: "いつも、たのしいほうをさす。", rarity: .rare, shape: .medal, hue: 42),
        .init(id: "star-bottle", name: "ほしのビン", flavor: "ふたをあけると、小さな夜がもれるよ。", rarity: .legendary, shape: .bottle, hue: 255),
        .init(id: "lucky-cat", name: "まねきねこ", flavor: "みぎてをふって、つぎのたからをよんでいる。", rarity: .common, shape: .cat, hue: 12),
    ]

    static func treasure(id: String) -> Treasure {
        all.first { $0.id == id } ?? all[0]
    }

    static func rarityLabel(_ rarity: TreasureRarity) -> String {
        switch rarity {
        case .common: "ふつう"
        case .rare: "レア"
        case .legendary: "でんせつ"
        }
    }

    static func pickTreasureId(ownedTreasureIds: [String], huntId: String) -> String {
        let owned = Set(ownedTreasureIds)
        let unowned = all.filter { !owned.contains($0.id) }
        let pool = unowned.isEmpty ? all : unowned
        return pool[hashString(huntId) % pool.count].id
    }

    static func awardTreasure(collection: [CollectedTreasure], huntId: String, collectedAt: Date = Date()) -> CollectedTreasure {
        if let already = collection.first(where: { $0.huntId == huntId }) {
            return already
        }
        return CollectedTreasure(
            id: UUID().uuidString,
            treasureId: pickTreasureId(ownedTreasureIds: collection.map(\.treasureId), huntId: huntId),
            huntId: huntId,
            collectedAt: collectedAt
        )
    }

    static func uniqueCollected(_ collection: [CollectedTreasure]) -> [Treasure] {
        var seen = Set<String>()
        var items: [Treasure] = []
        for entry in collection where seen.insert(entry.treasureId).inserted {
            items.append(treasure(id: entry.treasureId))
        }
        return items
    }

    static func hashString(_ value: String) -> Int {
        var hash = 0
        for scalar in value.unicodeScalars {
            hash = (hash &* 31 &+ Int(scalar.value)) & 0x7FFF_FFFF
        }
        return hash
    }
}
