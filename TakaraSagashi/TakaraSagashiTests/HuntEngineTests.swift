import Testing
@testable import TakaraSagashi

private func readyHunt(stageCount: Int = 3) throws -> Hunt {
    var hunt = try HuntEngine.createHunt(stageCount: stageCount, tokenFactory: { "token-seed" })
    for index in 1...stageCount {
        hunt = try HuntEngine.setStageHint(hunt, stageIndex: index, hint: "\(index)ばんめはソファのした")
    }
    return try HuntEngine.startHunt(hunt)
}

struct HuntEngineTests {
    @Test func createHuntMakesUniqueTokens() throws {
        let hunt = try HuntEngine.createHunt(stageCount: 3)
        #expect(hunt.stageCount == 3)
        #expect(hunt.stages.count == 3)
        #expect(hunt.status == .draft)
        #expect(Set(hunt.stages.map(\.token)).count == 3)
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

    @Test func qrRoundTrips() throws {
        let hunt = try HuntEngine.createHunt(stageCount: 2)
        let payload = try HuntEngine.encodeQRPayload(hunt, stageIndex: 2)
        let parsed = HuntEngine.parseQRPayload(payload)
        #expect(parsed?.huntId == hunt.id)
        #expect(parsed?.stageIndex == 2)
        #expect(parsed?.token == hunt.stages[1].token)
    }

    @Test func parseRejectsGarbage() {
        #expect(HuntEngine.parseQRPayload("https://example.com") == nil)
        #expect(HuntEngine.parseQRPayload("cluehunt:v1:abc:x:tok") == nil)
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
        let payload = try HuntEngine.encodeQRPayload(hunt, stageIndex: 1)
        let outcome = HuntEngine.applyScan(hunt, payload: payload)
        #expect(outcome.result == .advanced(nextStage: 2, nextHint: "2ばんめはソファのした"))
        #expect(outcome.hunt.currentStageIndex == 2)
    }

    @Test func lastScanClears() throws {
        var hunt = try readyHunt(stageCount: 2)
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 2))
        #expect(outcome.result == .cleared)
        #expect(outcome.hunt.status == .cleared)
    }

    @Test func futureQRIsWrongOrder() throws {
        let hunt = try readyHunt()
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 3))
        #expect(outcome.result == .wrongOrder(expected: 1, scanned: 3))
    }

    @Test func pastQRIsAlreadyFound() throws {
        var hunt = try readyHunt()
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 1))
        #expect(outcome.result == .alreadyFound(scanned: 1))
    }

    @Test func unknownPayload() throws {
        let hunt = try readyHunt(stageCount: 1)
        let outcome = HuntEngine.applyScan(hunt, payload: "cluehunt:v1:other-hunt:1:zzzz")
        #expect(outcome.result == .unknown)
    }

    @Test func alreadyCleared() throws {
        var hunt = try readyHunt(stageCount: 1)
        hunt = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 1)).hunt
        let outcome = HuntEngine.applyScan(hunt, payload: try HuntEngine.encodeQRPayload(hunt, stageIndex: 1))
        #expect(outcome.result == .alreadyCleared)
    }
}

struct TreasureCatalogTests {
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
