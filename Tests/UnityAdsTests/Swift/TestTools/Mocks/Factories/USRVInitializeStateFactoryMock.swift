import Foundation

final class USRVInitializeStateFactoryMock: USRVInitializeStateFactory {

    var webViewCreateError: Error?
    var original: USRVInitializeStateFactory?

    override func state(for type: USRVInitializeStateType) -> USRVInitializeTask {
        guard type == .createWebView else {
            return original?.state(for: type) ?? super.state(for: type)
        }

        let webViewCreate = USRVInitializeTaskWebViewCreate()
        webViewCreate.errorToFail = webViewCreateError
        return webViewCreate
    }
}
