import Foundation

final class StartInitTask<F: TaskFactory>: PerformanceMeasurableTask {
    var startEventName: String? = Constants.Metrics.Task.Initializer.Started
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Initializer.self }
    private let runner: SyncTaskRunner<F>
    private let timeReader: TimeReader
    private let appStartTimeSaver: AppStartTimeSaver
    private let logger: Logger
    private let settingProvider: SDKGameSettingsProvider
    private let sessionInfoReader: SessionInfoReader

    init(factory: F,
         sequence: [F.Element],
         timeReader: TimeReader,
         appStartTimeSaver: AppStartTimeSaver,
         logger: Logger,
         settingProvider: SDKGameSettingsProvider,
         sessionInfoReader: SessionInfoReader) {
        self.runner = .init(factory: factory, sequence: sequence)
        self.timeReader = timeReader
        self.appStartTimeSaver = appStartTimeSaver
        self.logger = logger
        self.settingProvider = settingProvider
        self.sessionInfoReader = sessionInfoReader
    }

    func start(completion: @escaping ResultClosure<Void>) {
        appStartTimeSaver.save(startTime: timeReader.currentTimestamp(in: .milliseconds))
        logger.info(message: initLogMessage)
        runner.start(completion: completion)
    }
}

extension StartInitTask {

    var initLogMessage: String {
        "Initializing Unity Ads \(versionName) \(versionNumber) with game id \(settingProvider.gameID) in \(mode) mode, session \(sessionId)"
    }

    var versionName: String {
        Version().versionName
    }

    var versionNumber: Int {
        Version().versionNumber
    }

    var mode: String {
        settingProvider.isTestModeEnabled ? "test" : "production"
    }

    var sessionId: String {
        sessionInfoReader.sessionID
    }
}
