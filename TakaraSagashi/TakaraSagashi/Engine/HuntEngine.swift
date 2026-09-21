import Foundation

enum HuntEngine {
    static let minStages = 1
    static let maxStages = 5
    static let maxHintLength = 80
    static let qrPrefix = "cluehunt:v1"

    static func createHunt(stageCount: Int) throws -> Hunt {
        guard (minStages...maxStages).contains(stageCount) else {
            throw HuntError.invalidStageCount
        }
        let stages = (1...stageCount).map { index in
            Stage(index: index, hint: "")
        }
        return Hunt(
            id: UUID().uuidString,
            createdAt: Date(),
            stageCount: stageCount,
            stages: stages,
            currentStageIndex: 1,
            status: .draft
        )
    }

    static func setStageHint(_ hunt: Hunt, stageIndex: Int, hint: String) throws -> Hunt {
        guard hunt.stages.contains(where: { $0.index == stageIndex }) else {
            throw HuntError.missingStage
        }
        let trimmed = String(hint.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxHintLength))
        var next = hunt
        next.stages = hunt.stages.map { stage in
            guard stage.index == stageIndex else { return stage }
            var updated = stage
            updated.hint = trimmed
            return updated
        }
        return next
    }

    static func missingHintIndexes(_ hunt: Hunt) -> [Int] {
        hunt.stages.filter { $0.hint.isEmpty }.map(\.index)
    }

    static func markReady(_ hunt: Hunt) throws -> Hunt {
        guard missingHintIndexes(hunt).isEmpty else {
            throw HuntError.missingHint
        }
        var next = hunt
        next.status = .ready
        return next
    }

    static func startHunt(_ hunt: Hunt) throws -> Hunt {
        let withHints = hunt.status == .draft ? try markReady(hunt) : hunt
        guard missingHintIndexes(withHints).isEmpty else {
            throw HuntError.missingHint
        }
        var next = withHints
        next.status = .playing
        next.currentStageIndex = 1
        return next
    }

    static func encodeQRPayload(stageIndex: Int) throws -> String {
        guard (minStages...maxStages).contains(stageIndex) else {
            throw HuntError.missingStage
        }
        return "\(qrPrefix):\(stageIndex)"
    }

    static func parseQRPayload(_ raw: String) -> ParsedQR? {
        let parts = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":", omittingEmptySubsequences: false)
            .map(String.init)
        guard parts.count == 3 else { return nil }
        guard parts[0] == "cluehunt", parts[1] == "v1" else { return nil }
        guard let stageIndex = Int(parts[2]), (minStages...maxStages).contains(stageIndex) else {
            return nil
        }
        return ParsedQR(stageIndex: stageIndex)
    }

    static func currentHint(_ hunt: Hunt) -> String {
        hunt.stages.first(where: { $0.index == hunt.currentStageIndex })?.hint ?? ""
    }

    static func applyScan(_ hunt: Hunt, payload: String) -> (hunt: Hunt, result: ScanResult) {
        if hunt.status == .cleared {
            return (hunt, .alreadyCleared)
        }
        if hunt.status != .playing {
            return (hunt, .notPlaying)
        }
        guard let parsed = parseQRPayload(payload) else {
            return (hunt, .unknown)
        }
        if parsed.stageIndex > hunt.stageCount {
            return (hunt, .unused(scanned: parsed.stageIndex))
        }
        if parsed.stageIndex > hunt.currentStageIndex {
            return (hunt, .wrongOrder(expected: hunt.currentStageIndex, scanned: parsed.stageIndex))
        }
        if parsed.stageIndex < hunt.currentStageIndex {
            return (hunt, .alreadyFound(scanned: parsed.stageIndex))
        }
        if parsed.stageIndex == hunt.stageCount {
            var cleared = hunt
            cleared.status = .cleared
            return (cleared, .cleared)
        }
        let nextStage = parsed.stageIndex + 1
        let nextHint = hunt.stages.first(where: { $0.index == nextStage })?.hint ?? ""
        var advanced = hunt
        advanced.currentStageIndex = nextStage
        return (advanced, .advanced(nextStage: nextStage, nextHint: nextHint))
    }
}

extension ScanResult {
    var speech: String {
        switch self {
        case .advanced(_, let nextHint):
            "やったあ。つぎのヒントだよ。\(nextHint)"
        case .cleared:
            "クリア！たからをゲットしたよ"
        case .wrongOrder(let expected, _):
            "まだだよ。いまは\(expected)ばんをさがしてね"
        case .alreadyFound:
            "それはもうみつけたよ。つぎをさがしてね"
        case .unused:
            "このぼうけんではつかわないカードだよ"
        case .unknown:
            "このぼうけんのカードじゃないみたい"
        case .alreadyCleared:
            "このぼうけんはもうクリアだよ"
        case .notPlaying:
            "まだぼうけんははじまっていないよ"
        }
    }

    var title: String {
        switch self {
        case .advanced: "みつけた！"
        case .cleared: "クリア！"
        case .wrongOrder: "まだだよ"
        case .alreadyFound: "もうみたよ"
        case .unused: "つかわないよ"
        case .unknown: "あれれ？"
        case .alreadyCleared: "おわりだよ"
        case .notPlaying: "まってね"
        }
    }
}
