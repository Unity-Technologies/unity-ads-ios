import Foundation

protocol HeaderBiddingTokenReader {
    func getToken(_ completion: Closure<HeaderBiddingToken>) throws
}

final class HeaderBiddingTokenReaderBase: HeaderBiddingTokenReader {
    private let config: Config

    init(_ config: Config) {
        self.config = config
    }

    func getToken(_ completion: Closure<HeaderBiddingToken>) throws {
        var info = config.deviceInfoReader.getDeviceInfoBody(of: .extended)
        let uniqueId = config.uniqueIdGenerator.uniqueID
        info["tid"] = uniqueId
        let tokenValue = try config.compressor.compressedInfoString(info)
        let prefixedTokenValue = config.customPrefix + tokenValue
        let token = HeaderBiddingToken(value: prefixedTokenValue,
                                       type: .native,
                                       uuidString: uniqueId,
                                       info: info,
                                       customPrefix: config.customPrefix)
        completion(token)
    }

    struct Config {
        let deviceInfoReader: DeviceInfoBodyStrategy
        let compressor: StringCompressor
        let customPrefix: String
        let uniqueIdGenerator: UniqueGenerator
        let experiments: ExperimentsReader
    }
}
