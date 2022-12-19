import Foundation

@objc
final class NetworkLayerObjCBridge: NSObject {

    let network: UnityAdsWebViewNetwork
    let downloader: WebViewDownloader
    init(network: UnityAdsWebViewNetwork, downloader: WebViewDownloader) {
        self.network = network
        self.downloader = downloader
        super.init()
    }

    @objc
    func sendRequest(using dictionary: [String: Any],
                     success: @escaping Closure<[String: Any]>,
                     failure: @escaping Closure<[String: Any]>) {
        network.sendAndDecode(using: dictionary) { result in
            result.do(success)
                .onFailure({ failure( extractErrorDictionary($0)) })

        }
    }

    @objc
    func downloadWebViewSync(completion: @escaping Closure<URL>,
                             error: @escaping Closure<Error>) {
        var outputResult: UResult<URL> = .failure(NotStartedError())
        let semaphore = DispatchSemaphore(value: 0)

        downloader.download { result in
            outputResult = result
            semaphore.signal()
        }

        semaphore.wait()

        outputResult.do(completion)
                    .onFailure(error)

    }

    struct NotStartedError: LocalizedError {
        var errorDescription: String? {
            return "Downloader wasn't called."
        }
    }
}

private func extractErrorDictionary(_ error: UnityAdsWebViewNetwork.RequestError) -> [String: Any] {
    return (try? error.convertIntoDictionary()) ?? [:]
}
