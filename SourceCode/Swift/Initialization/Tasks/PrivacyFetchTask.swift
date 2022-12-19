import Foundation

final class PrivacyFetchTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.PrivacyFetch.self }

    typealias PrivacyCRUD = PrivacyStateReader & PrivacyResponseSaver
    let id: UUID = .init()

    private let asyncReader: PrivacyAsyncReader
    private let storage: PrivacyCRUD
    init(asyncReader: PrivacyAsyncReader, storage: PrivacyCRUD) {
        self.asyncReader = asyncReader
        self.storage = storage
    }

    func start(completion: @escaping ResultClosure<Void>) {
        guard storage.privacyState == .unknown else {
            completion(VoidSuccess)
            return
        }

        asyncReader.getPrivacyData { [storage] result in
            result.do(storage.save)
                  .map({ _ in })
                  .recover({ _ in })
                  .sink(completion)
        }
    }

}
