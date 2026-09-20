import Foundation
import SwiftUI
import Testing
@testable import TakaraSagashi

private func readyHunt(stageCount: Int = 3) throws -> Hunt {
    var hunt = try HuntEngine.createHunt(stageCount: stageCount)
    for index in 1...stageCount {
        hunt = try HuntEngine.setStageHint(hunt, stageIndex: index, hint: "\(index)ばんめはソファのした")
    }
    return try HuntEngine.startHunt(hunt)
}

struct HuntEngineTests {
    @Test func createHuntMakesStages() throws {
        let hunt = try HuntEngine.createHunt(stageCount: 3)
        #expect(hunt.stageCount == 3)
        #expect(hunt.stages.count == 3)
        #expect(hunt.status == .draft)
    }

    @Test func createHuntRejectsOutOfRange() {
        #expect(throws: HuntError.invalidStageCount) {
            _ = try HuntEngine.createHunt(stageCount: 0)
        }
        #expect(throws: HuntError.invalidStageCount) {
            _ = try HuntEngine.createHunt(stageCount: 6)
        }
    }

    @Test func setStageHintIsImmutable() throws {
        let hunt = try HuntEngine.createHunt(stageCount: 2)
        let next = try HuntEngine.setStageHint(hunt, stageIndex: 1, hint: "  まどのそば  ")
        #expect(next.stages[0].hint == "まどのそば")
        #expect(hunt.stages[0].hint == "")
    }

    @Test func qrCodesAreFixedAcrossHunts() throws {
        let first = try HuntEngine.encodeQRPayload(stageIndex: 2)
        let second = try HuntEngine.encodeQRPayload(stageIndex: 2)
        #expect(first == second)
        #expect(HuntEngine.parseQRPayload(first)?.stageIndex == 2)
    }

    @Test func parseRejectsGarbage() {
        #expect(HuntEngine.parseQRPayload("https://example.com") == nil)
        #expect(HuntEngine.parseQRPayload("cluehunt:v1:abc") == nil)
        #expect(HuntEngine.parseQRPayload("") == nil)
    }

    @Test func startRequiresHints() throws {
        let hunt = try HuntEngine.setStageHint(try HuntEngine.createHunt(stageCount: 2), stageIndex: 1, hint: "つくえのした")
        #expect(throws: HuntError.missingHint) {
            _ = try HuntEngine.startHunt(hunt)
        }
    }

    @Test func correctScanAdvances() throws {
        let hunt = try readyHunt()
        let payload = try HuntEngine.encodeQRPayload(stageIndex: 1)
        let outcome = HuntEngine.applyScan(hunt, payload: payload)
        #expect(outcome.result == .advanced(nextStage: 2, nextHint: "2ばんめはソファのした"))
        #expect(outcome.hunt.currentStageIndex == 2)
    }

    @Test func lastScanClears() throws {
        var hunt = try readyHunt(stageCount: 2)
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 2))
        #expect(outcome.result == .cleared)
        #expect(outcome.hunt.status == .cleared)
    }

    @Test func futureQRIsWrongOrder() throws {
        let hunt = try readyHunt()
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 3))
        #expect(outcome.result == .wrongOrder(expected: 1, scanned: 3))
    }

    @Test func unusedCardWhenHuntUsesFewer() throws {
        let hunt = try readyHunt(stageCount: 2)
        let unused = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 3))
        #expect(unused.result == .unused(scanned: 3))
        let far = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 5))
        #expect(far.result == .unused(scanned: 5))
        let inHunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 2))
        #expect(inHunt.result == .wrongOrder(expected: 1, scanned: 2))
    }

    @Test func pastQRIsAlreadyFound() throws {
        var hunt = try readyHunt()
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 1))
        #expect(outcome.result == .alreadyFound(scanned: 1))
    }

    @Test func unknownPayload() throws {
        let hunt = try readyHunt(stageCount: 1)
        let outcome = HuntEngine.applyScan(hunt, payload: "https://example.com")
        #expect(outcome.result == .unknown)
    }

    @Test func alreadyCleared() throws {
        var hunt = try readyHunt(stageCount: 1)
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(stageIndex: 1))
        #expect(outcome.result == .alreadyCleared)
    }
}

struct TreasureCatalogTests {
    @MainActor @Test func treasureArtworkRenders() throws {
        let gallery = VStack(spacing: 20) {
            Text("たからのずかん").font(.title.bold()).foregroundStyle(.white)
            Text("50  COLLECTION").font(.caption.bold()).foregroundStyle(Palette.lantern)
            LazyVGrid(columns: [GridItem(.fixed(164)), GridItem(.fixed(164))], spacing: 16) {
                ForEach(TreasureCatalog.all.prefix(10)) { treasure in
                    VStack(spacing: 6) {
                        TreasureArtView(treasure: treasure, size: 140)
                        Text(treasure.name).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                        RarityBadge(rarity: treasure.rarity)
                    }
                    .padding(.vertical, 12).frame(width: 164)
                    .background(treasure.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
                }
            }
        }
        .padding(20).background(Palette.night).environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: gallery)
        renderer.scale = 2
        let image = try #require(renderer.uiImage)
        let data = try #require(image.pngData())
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("treasure-gallery.png")
        try data.write(to: path)
        print("Treasure gallery preview: \(path.path)")
    }

    @Test func catalogHasFiftyDistinctTreasures() {
        #expect(TreasureCatalog.all.count == 50)
        #expect(Set(TreasureCatalog.all.map(\.id)).count == 50)
        #expect(Set(TreasureCatalog.all.map(\.name)).count == 50)
    }

    @Test func fiftyAdventuresCompleteTheCollectionBeforeRepeats() throws {
        var collection: [CollectedTreasure] = []
        for index in 0..<50 {
            collection.append(TreasureCatalog.awardTreasure(collection: collection, huntId: "adventure-\(index)"))
        }
        #expect(Set(collection.map(\.treasureId)).count == 50)
        let afterCompletion = TreasureCatalog.awardTreasure(collection: collection, huntId: "adventure-51")
        #expect(TreasureCatalog.all.contains { $0.id == afterCompletion.treasureId })
        let restored = try JSONDecoder().decode([CollectedTreasure].self, from: JSONEncoder().encode(collection))
        #expect(TreasureCatalog.uniqueCollected(restored).count == 50)
    }

    @Test func prefersUnownedTreasure() {
        let first = TreasureCatalog.awardTreasure(collection: [], huntId: "hunt-a")
        let second = TreasureCatalog.awardTreasure(collection: [first], huntId: "hunt-b")
        #expect(first.treasureId != second.treasureId)
    }

    @Test func sameHuntIdIsIdempotent() {
        let a = TreasureCatalog.awardTreasure(collection: [], huntId: "same")
        let b = TreasureCatalog.awardTreasure(collection: [a], huntId: "same")
        #expect(a.id == b.id)
    }
}
