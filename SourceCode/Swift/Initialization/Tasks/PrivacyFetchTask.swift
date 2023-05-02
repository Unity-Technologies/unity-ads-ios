import Foundation

final class PrivacyFetchTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.PrivacyFetch.self }

    typealias PrivacyCRUD = PrivacyStateReader & PrivacyResponseSaver
    let id: UUID = .init()

    private let asyncReader: PrivacyAsyncReader
    private let storage: PrivacyCRUD
    private let codesToFail = [PrivacyError.gameIdDisabled.rawValue]
    init(asyncReader: PrivacyAsyncReader, storage: PrivacyCRUD) {
        self.asyncReader = asyncReader
        self.storage = storage
    }

    func start(completion: @escaping ResultClosure<Void>) {
        guard storage.privacyState == .unknown else {
            completion(VoidSuccess)
            return
        }

        asyncReader.getPrivacyData { [storage] (result: UResult<PrivacyResponse>) in
            result.do(storage.save)
                  .map({ _ in })
                  .flatMapError(self.failErrorIfNeed)
                  .sink(completion)
        }
    }

    private func failErrorIfNeed(_ error: Error) -> UResult<Void> {
        guard let error = error as? NetworkResponseError,
              let errorCode = error.errorCode,
              codesToFail.contains(errorCode),
              let privacyErrorCode = PrivacyError(rawValue: errorCode) else {
            return VoidSuccess
        }
        return .failure(privacyErrorCode)
    }
}

enum PrivacyError: Int, LocalizedError {
    case gameIdDisabled = 423

    var errorDescription: String? {
        switch self {
        case .gameIdDisabled:
            return "GameId disabled"
        }
    }
}
