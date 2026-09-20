import Foundation

enum HuntStatus: String, Codable, Sendable {
    case draft
    case ready
    case playing
    case cleared
}

enum Screen: String, Codable, Sendable {
    case home
    case parent
    case setupCount
    case setupStage
    case setupReady
    case qrDeck
    case play
    case scan
    case clear
    case collection
}

struct Stage: Codable, Equatable, Sendable, Identifiable {
    var index: Int
    var hint: String

    var id: Int { index }
}

struct Hunt: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var createdAt: Date
    var stageCount: Int
    var stages: [Stage]
    var currentStageIndex: Int
    var status: HuntStatus
}

struct ParsedQR: Equatable, Sendable {
    var stageIndex: Int
}

enum ScanResult: Equatable, Sendable {
    case advanced(nextStage: Int, nextHint: String)
    case cleared
    case wrongOrder(expected: Int, scanned: Int)
    case alreadyFound(scanned: Int)
    case unused(scanned: Int)
    case unknown
    case alreadyCleared
    case notPlaying
}

enum TreasureRarity: String, Codable, Sendable {
    case common
    case rare
    case legendary
}

enum TreasureShape: String, Codable, Sendable {
    case gem, orb, crown, key, medal, map, feather, acorn, bottle, cat
}

struct Treasure: Codable, Equatable, Sendable, Identifiable, Hashable {
    var id: String
    var name: String
    var flavor: String
    var rarity: TreasureRarity
    var shape: TreasureShape
    var hue: Double
}

struct CollectedTreasure: Codable, Equatable, Sendable, Identifiable {
    var id: String
    var treasureId: String
    var huntId: String
    var collectedAt: Date
}

enum HuntError: Error, Equatable {
    case invalidStageCount
    case missingStage
    case missingHint
}
