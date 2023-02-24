import Foundation

struct URLProtocolResponseStub {
    var data: Data?
    var status: Int = 200
    var error: Error?
    var url: String?

    func new(with data: Data?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    func new(with status: Int) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }

    func new(with error: Error?) -> Self {
        .init(data: data, status: status, error: error, url: url)
    }
}
