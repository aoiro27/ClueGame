import Foundation
import Observation

@Observable
@MainActor
final class GameStore {
    var screen: Screen = .home
    var hunt: Hunt?
    var setupIndex = 1
    var collection: [CollectedTreasure] = []
    var lastAwardedId: String?
    var scanResult: ScanResult?
    var practiceMode = false

    private let defaultsKey = "cluegame-native-v1"

    init() {
        restore()
        if screen == .scan {
            screen = .play
        }
    }

    func goTo(_ screen: Screen) {
        self.screen = screen
        scanResult = nil
        persist()
    }

    func beginSetup() {
        hunt = nil
        setupIndex = 1
        scanResult = nil
        screen = .setupCount
        persist()
    }

    func chooseStageCount(_ count: Int) {
        hunt = try? HuntEngine.createHunt(stageCount: count)
        setupIndex = 1
        screen = .setupStage
        persist()
    }

    func updateCurrentHint(_ hint: String) {
        guard let hunt else { return }
        self.hunt = try? HuntEngine.setStageHint(hunt, stageIndex: setupIndex, hint: hint)
        persist()
    }

    func nextSetupStage() {
        guard let hunt else { return }
        if setupIndex >= hunt.stageCount {
            finishSetup()
            return
        }
        setupIndex += 1
        persist()
    }

    func prevSetupStage() {
        if setupIndex <= 1 {
            screen = .setupCount
            persist()
            return
        }
        setupIndex -= 1
        persist()
    }

    func finishSetup() {
        guard let hunt else { return }
        do {
            self.hunt = try HuntEngine.markReady(hunt)
            screen = .setupReady
            persist()
        } catch {
            screen = .setupStage
        }
    }

    func startAdventure() {
        guard let hunt else { return }
        if hunt.status == .playing {
            screen = .play
            scanResult = nil
            persist()
            return
        }
        self.hunt = try? HuntEngine.startHunt(hunt)
        screen = .play
        scanResult = nil
        persist()
    }

    func openScan() {
        screen = .scan
        scanResult = nil
        persist()
    }

    func closeScan() {
        screen = .play
        scanResult = nil
        persist()
    }

    @discardableResult
    func scanPayload(_ payload: String) -> ScanResult? {
        guard let hunt else { return nil }
        let outcome = HuntEngine.applyScan(hunt, payload: payload)
        if outcome.result == .cleared {
            let awarded = TreasureCatalog.awardTreasure(collection: collection, huntId: outcome.hunt.id)
            if !collection.contains(where: { $0.id == awarded.id }) {
                collection.append(awarded)
            }
            self.hunt = outcome.hunt
            scanResult = outcome.result
            lastAwardedId = awarded.id
            screen = .clear
            persist()
            return outcome.result
        }
        if case .advanced = outcome.result {
            self.hunt = outcome.hunt
            scanResult = outcome.result
            screen = .play
            persist()
            return outcome.result
        }
        scanResult = outcome.result
        persist()
        return outcome.result
    }

    func clearScanResult() {
        scanResult = nil
    }

    func openCollection() {
        screen = .collection
        scanResult = nil
        persist()
    }

    func finishClear() {
        screen = .collection
        persist()
    }

    func abandonHunt() {
        hunt = nil
        setupIndex = 1
        scanResult = nil
        lastAwardedId = nil
        screen = .parent
        persist()
    }

    func reviewQR() {
        guard hunt != nil else { return }
        screen = .setupReady
        setupIndex = 1
        persist()
    }

    var currentStage: Stage? {
        hunt?.stages.first { $0.index == setupIndex }
    }

    var awardedTreasure: Treasure {
        if let lastAwardedId,
           let item = collection.first(where: { $0.id == lastAwardedId }) {
            return TreasureCatalog.treasure(id: item.treasureId)
        }
        return TreasureCatalog.all[0]
    }

    private struct Snapshot: Codable {
        var screen: Screen
        var hunt: Hunt?
        var setupIndex: Int
        var collection: [CollectedTreasure]
        var lastAwardedId: String?
        var practiceMode: Bool
    }

    private func persist() {
        let snapshot = Snapshot(
            screen: screen == .scan ? .play : screen,
            hunt: hunt,
            setupIndex: setupIndex,
            collection: collection,
            lastAwardedId: lastAwardedId,
            practiceMode: practiceMode
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return
        }
        screen = snapshot.screen
        hunt = snapshot.hunt
        setupIndex = snapshot.setupIndex
        collection = snapshot.collection
        lastAwardedId = snapshot.lastAwardedId
        practiceMode = snapshot.practiceMode
    }
}
