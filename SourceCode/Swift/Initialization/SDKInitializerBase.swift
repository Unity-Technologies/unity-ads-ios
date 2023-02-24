import Foundation

protocol SDKInitializer {
    func initialize(with config: SDKInitializerConfig, completion: @escaping ResultClosure<Void>)
}

final class SDKInitializerBase: SDKInitializer {

    private let task: Task
    private let queue = DispatchQueue(label: "SDKInitializer.queue")
    private let stateStorage: SDKStateStorage
    private let settingsStorage: SDKSettingsStorage
    private var completions: [ResultClosure<Void>] = []
    private var state: State {
        get { stateStorage.currentState }
        set { stateStorage.currentState = newValue }
    }

    private var initConfig: SDKInitializerConfig {
        get { settingsStorage.currentInitConfig }
        set { settingsStorage.currentInitConfig = newValue }
    }

    init(task: Task,
         stateStorage: SDKStateStorage,
         settingsStorage: SDKSettingsStorage) {
        self.task = task
        self.stateStorage = stateStorage
        self.settingsStorage = settingsStorage
    }

    func initialize(with config: SDKInitializerConfig, completion: @escaping ResultClosure<Void>) {
        queue.sync { startInitialization(with: config, completion: completion) }
    }
}

private extension SDKInitializerBase {
    func startInitialization(with config: SDKInitializerConfig, completion: @escaping ResultClosure<Void>) {
        completions = completions.appended(completion)
        switch state {
        case .notInitialized:
            changeStatusAndStartTheTask(config: config)
        case .inProcess:
            return
        case .failed(let error):
            notifySavedCompletionsAndClean(with: .failure(error))
        case .initialized:
            notifySavedCompletionsAndClean(with: VoidSuccess)
        }

    }

    func changeStatusAndStartTheTask(config: SDKInitializerConfig) {
        setInProgress(for: config)
        startTask()
    }

    func setInProgress(for config: SDKInitializerConfig) {
        initConfig = config
        state = .inProcess
    }

    func startTask() {
        self.task.start {[weak self] result in
            self?.processResult(result)
            self?.notifySavedCompletionsAndClean(with: result)
        }
    }

    func processResult(_ result: UResult<Void>) {
        queue.sync {
            result.do({ state = .initialized })
                  .onFailure({ state = .failed($0) })
            return // silencing the warning 
        }
    }

    func notifySavedCompletionsAndClean(with result: UResult<Void>) {
        queue.async {[weak self] in
            self?.completions.forEach({ $0(result) })
            self?.completions = []
        }
    }
}

public struct SDKInitializerConfig {
    public let gameID: String

    public init(gameID: String) {
        self.gameID = gameID
    }
}

extension SDKInitializerBase {
    enum State: Equatable {
        static func == (lhs: SDKInitializerBase.State, rhs: SDKInitializerBase.State) -> Bool {
            switch (rhs, lhs) {

            case (.initialized, .initialized),
                (.notInitialized, .notInitialized),
                (.inProcess, .inProcess): return true
            case let (.failed(err1), .failed(err2)):
                return err1.localizedDescription == err2.localizedDescription
            default: return false
            }
        }

        case notInitialized
        case inProcess
        case failed(Error)
        case initialized
    }
}
