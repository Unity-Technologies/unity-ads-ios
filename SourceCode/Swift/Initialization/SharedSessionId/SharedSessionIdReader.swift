import Foundation

protocol SharedSessionIdReader {
    var sessionId: String { get }
}

class SharedSessionIdReaderBase: SharedSessionIdReader {
    var sessionId: String {
        UADSSessionId.shared().sessionId()
    }
}
