import Foundation

protocol PrivacyStateReader {
    var privacyState: PrivacyState { get }
}

protocol PrivacyResponseSaver {
    func save(response: PrivacyResponse)
}

final class SDKSettingsStorage: LoggerLevelReader,
                                LoggerSettingsReader,
                                NetworkSettingsProvider,
                                SDKGameIdProvider {

    var metricSessionConfiguration: URLSessionConfiguration = .ephemeral

    var mainSessionConfiguration: URLSessionConfiguration = .default

    var responseSuccessCodes: [Int] = Array((200...299))

    var metricsResourceTypes: [Int] = [1] // corresponds to .networkLoad

    @Atomic var allowDumpToFile: Bool = false
    @Atomic var currentLevel: LogLevel = .fatal
    @Atomic var currentInitConfig: SDKInitializerConfig = .init(gameID: "")

    var logsFileURL: URL { filePaths.diagnosticDump }
    let filePaths = FilePaths()

    var gameID: String {
        currentInitConfig.gameID
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
