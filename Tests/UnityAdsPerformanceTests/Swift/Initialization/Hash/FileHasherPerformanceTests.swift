import XCTest
@testable import UnityAds

class FileHasherPerformanceTests: XCTestCase {

    private var fileURL: URL {
        url(with: "file.test")
    }
    private func url(with filename: String) -> URL {
        FileManager.getTempDirectoryPath().appendingPathComponent(filename)
    }

    private func saveLongFile(_ sizeInMb: Int = 5) throws {
        let string = String(repeating: "*", count: 1_024*1_024*sizeInMb)
        guard let sample = string.data(using: .utf8) else { return }
        try sample.write(to: fileURL)
    }

    override func setUp() {
        try? saveLongFile()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func test_hasher_with_memory() throws {
        measureMetrics([.wallClockTime],
                       automaticallyStartMeasuring: true,
                       for: {
            let hasher = SHA256Hasher(calculateInMemory: true)
            _ = try? hasher.hash(from: fileURL)
        })
    }

    func test_hasher_with_input_stream() throws {
        measureMetrics([.wallClockTime],
                       automaticallyStartMeasuring: true,
                       for: {
            let hasher = SHA256Hasher(calculateInMemory: false)
            _ = try? hasher.hash(from: fileURL)
        })
    }

    @available(iOS 13.2, *)
    func test_crypto_hasher_with_input_stream() throws {
        measureMetrics([.wallClockTime],
                       automaticallyStartMeasuring: true,
                       for: {
            let hasher = CryptoKitHasher(calculateInMemory: false)
            _ = try? hasher.hash(from: fileURL)
        })
    }

    @available(iOS 13.2, *)
    func test_crypto_hasher_with_memory() throws {
        measureMetrics([.wallClockTime],
                       automaticallyStartMeasuring: true,
                       for: {
            let hasher = CryptoKitHasher(calculateInMemory: true)
            _ = try? hasher.hashInMemory(from: fileURL)
        })
    }
}
