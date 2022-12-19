import Foundation

final class USRVInitializeTaskWebViewCreate: NSObject, USRVInitializeTask {

    var errorToFail: Error?

    func systemName() -> String {
        return "MockWebView"
    }

    func start(completion: @escaping () -> Void, error: @escaping (Error) -> Void) {
        errorToFail.do(error)
            .onNone(completion)
    }
}
