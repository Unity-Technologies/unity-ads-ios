import Foundation

final class DeviceInfoObjBridgeDecorator: DeviceInfoBodyStrategy {
    func initializeStaticInfo() {
        guard shouldUseNewImplementation else { return }
        config.original.initializeStaticInfo()
    }

    private let config: Config
    init(config: Config) {
        self.config = config
    }

    func getDeviceInfoBody(of type: DeviceInfoType) -> [String: Any] {
        guard shouldUseNewImplementation else {
            return getLegacyDeviceInfo(of: type)

        }
        return config.original.getDeviceInfoBody(of: type)
    }

    private var shouldUseNewImplementation: Bool {
        config.experimentsReader.experiments?.isSwiftDeviceInfoEnabled.value ?? false
    }

    private func getLegacyDeviceInfo(of type: DeviceInfoType) -> [String: Any] {
        guard let getLegacyInfo = config.getLegacyInfo else {
            config.logger.fatal(message: "Legacy Device Info Closure is Not set")
            return [:]
        }
        return getLegacyInfo(type == .extended)
    }
}

extension DeviceInfoObjBridgeDecorator {
    struct Config {
        let logger: Logger
        let experimentsReader: ExperimentsReader
        let original: DeviceInfoBodyStrategy
        let getLegacyInfo: ClosureWithReturn<Bool, [String: Any]>?
    }
}
