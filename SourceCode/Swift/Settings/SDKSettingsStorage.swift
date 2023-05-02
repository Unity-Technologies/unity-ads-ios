import Foundation

final class SDKSettingsStorage: LoggerLevelReader,
                                LoggerSettingsReader,
                                NetworkSettingsProvider,
                                SDKGameSettingsProvider {

    var metricSessionConfiguration: URLSessionConfiguration = .ephemeral

    var mainSessionConfiguration: URLSessionConfiguration = .default

    var responseSuccessCodes: [Int] = Array((200...299))

    var metricsResourceTypes: [Int] = [1] // corresponds to .networkLoad

    var allowDumpToFile: Bool {
        get { _logsIntoFile.load() }
        set { _logsIntoFile.mutate({ $0 = newValue }) }
    }
    @Atomic private var logsIntoFile: Bool = false
    var currentLevel: LogLevel {
        get { _logLevel.load() }
        set { _logLevel.mutate({ $0 = newValue }) }
    }
    @Atomic private var logLevel: LogLevel = .fatal

    @Atomic var currentInitConfig: SDKInitializerConfig = .init(gameID: "", isTestModeEnabled: true)

    var logsFileURL: URL { filePaths.diagnosticDump }
    let filePaths = FilePaths()

    var gameID: String {
        _currentInitConfig.load().gameID
    }

    var isTestModeEnabled: Bool {
        _currentInitConfig.load().isTestModeEnabled
    }
}

struct FilePaths: ConfigurationPathProvider {
    var baseDir: URL {
        FileManager.getCacheDirectoryPath()
    }
    var webviewURL: URL {
        return baseDir.appendingPathComponent("UnityAdsWebApp.html")
    }

    var configURL: URL {
        return baseDir.appendingPathComponent("UnityAdsWebViewConfiguration.json")
    }

    var diagnosticDump: URL {
        return baseDir.appendingPathComponent("Diagnostic.txt")
    }
}
