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
        .init(id: "sun-crystal", name: "たいようのクリスタル", flavor: "あさのひかりを、ぎゅっととじこめたよ。", rarity: .rare, shape: .gem, hue: 35),
        .init(id: "ice-heart", name: "こおりのハート", flavor: "つめたいのに、こころはぽかぽか。", rarity: .rare, shape: .gem, hue: 190),
        .init(id: "forest-emerald", name: "もりのエメラルド", flavor: "はっぱのささやきがきこえる、みどりのいし。", rarity: .common, shape: .gem, hue: 135),
        .init(id: "meteor-stone", name: "ながれぼしのいし", flavor: "ねがいごとをのせて、そらをたびしてきたよ。", rarity: .legendary, shape: .gem, hue: 265),
        .init(id: "rose-quartz", name: "さくらのほうせき", flavor: "はるのはなびらが、きらきらのいしになったよ。", rarity: .common, shape: .gem, hue: 330),
        .init(id: "cloud-orb", name: "くものたま", flavor: "なかでちいさなくもが、おひるねしている。", rarity: .common, shape: .orb, hue: 205),
        .init(id: "aurora-orb", name: "オーロラのたま", flavor: "きたのそらのカーテンが、くるくるおどる。", rarity: .legendary, shape: .orb, hue: 165),
        .init(id: "firefly-orb", name: "ほたるのあかり", flavor: "くらいみちでも、やさしくてらしてくれる。", rarity: .common, shape: .orb, hue: 65),
        .init(id: "ocean-crown", name: "うみのおうかん", flavor: "さかなのパレードでかぶる、あおいおうかん。", rarity: .rare, shape: .crown, hue: 195),
        .init(id: "flower-crown", name: "はなのティアラ", flavor: "ようせいたちが、はなをあつめてつくったよ。", rarity: .common, shape: .crown, hue: 315),
        .init(id: "starlight-crown", name: "ほしぞらのおうかん", flavor: "よぞらのおうさまから、ぼうけんかへのおくりもの。", rarity: .legendary, shape: .crown, hue: 255),
        .init(id: "silver-key", name: "ぎんのカギ", flavor: "つきあかりのとびらに、ぴったりあうよ。", rarity: .common, shape: .key, hue: 210),
        .init(id: "heart-key", name: "ハートのカギ", flavor: "ともだちのえがおをひらく、ふしぎなカギ。", rarity: .rare, shape: .key, hue: 340),
        .init(id: "rainbow-key", name: "にじのカギ", flavor: "にじのむこうのくにへ、いつかいけるかな。", rarity: .legendary, shape: .key, hue: 285),
        .init(id: "sun-medal", name: "たいようのメダル", flavor: "げんきいっぱいのぼうけんかに、ぴかぴかのごほうび。", rarity: .common, shape: .medal, hue: 40),
        .init(id: "snow-medal", name: "ゆきのメダル", flavor: "とけないゆきのもようが、まんなかでひかる。", rarity: .rare, shape: .medal, hue: 185),
        .init(id: "brave-medal", name: "ゆうきのメダル", flavor: "さいごまであきらめなかった、きみのしるし。", rarity: .legendary, shape: .medal, hue: 15),
        .init(id: "island-map", name: "たからじまのちず", flavor: "なみのむこうに、ひみつのしまがあるらしい。", rarity: .rare, shape: .map, hue: 180),
        .init(id: "sky-map", name: "そらのちず", flavor: "くものうえをあるくみちが、かいてあるよ。", rarity: .rare, shape: .map, hue: 220),
        .init(id: "garden-map", name: "ひみつのにわのちず", flavor: "ちょうちょについていくと、おはなばたけへ。", rarity: .common, shape: .map, hue: 115),
        .init(id: "phoenix-feather", name: "ふしちょうのはね", flavor: "あかいはねに、あしたのげんきがつまっている。", rarity: .legendary, shape: .feather, hue: 15),
        .init(id: "moon-feather", name: "つきのはね", flavor: "よるのとりが、そっとおとしていったよ。", rarity: .rare, shape: .feather, hue: 230),
        .init(id: "wind-feather", name: "かぜのはね", flavor: "ふわりとゆれると、そよかぜがふく。", rarity: .common, shape: .feather, hue: 155),
        .init(id: "silver-acorn", name: "ぎんのドングリ", flavor: "りすのコレクションで、いちばんのおきにいり。", rarity: .common, shape: .acorn, hue: 215),
        .init(id: "rainbow-seed", name: "にじのたね", flavor: "どんなはながさくのかな。わくわくするね。", rarity: .rare, shape: .acorn, hue: 295),
        .init(id: "giant-seed", name: "おおきなきのたね", flavor: "いつか、そらにとどくきになるかもしれない。", rarity: .rare, shape: .acorn, hue: 125),
        .init(id: "ocean-bottle", name: "うみのこびん", flavor: "みみをすますと、なみのおとがきこえる。", rarity: .common, shape: .bottle, hue: 195),
        .init(id: "dream-bottle", name: "ゆめのこびん", flavor: "きょうのすてきなゆめを、ひとつしまっておこう。", rarity: .rare, shape: .bottle, hue: 280),
        .init(id: "rainbow-bottle", name: "にじのしずく", flavor: "あめあがりのにじを、すこしだけわけてもらったよ。", rarity: .legendary, shape: .bottle, hue: 320),
        .init(id: "honey-bottle", name: "きんいろのはちみつ", flavor: "もりのくまさんが、だいじにつくったたからもの。", rarity: .common, shape: .bottle, hue: 42),
        .init(id: "moon-cat", name: "つきのねこ", flavor: "つきのうえで、まいばんおさんぽしているよ。", rarity: .rare, shape: .cat, hue: 235),
        .init(id: "forest-cat", name: "もりのねこ", flavor: "まいごになったら、みちをおしえてくれる。", rarity: .common, shape: .cat, hue: 145),
        .init(id: "royal-cat", name: "おうさまねこ", flavor: "ねこのくにから、きみにあいにやってきたよ。", rarity: .legendary, shape: .cat, hue: 45),
        .init(id: "coral-pearl", name: "さんごのパール", flavor: "うみのそこからとどいた、ももいろのおてがみ。", rarity: .common, shape: .orb, hue: 350),
        .init(id: "adventure-compass", name: "ぼうけんのコンパス", flavor: "つぎのわくわくは、きっとすぐそばにあるよ。", rarity: .legendary, shape: .medal, hue: 165),
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
