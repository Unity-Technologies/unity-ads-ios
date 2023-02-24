import Foundation
@testable import UnityAds
import XCTest

final class SDKMetricsValidator {

    private let stub: URLProtocolStubBase.Type

    var receivedCount: Int {
        let metrics = try? extractMetricsWithSorting(from: try receivedMetricContainer())
        return metrics?.count ?? 0
    }

    init(stub: URLProtocolStubBase.Type) {
        self.stub = stub
    }

    func containsLegacy(metrics type: [SDKMetricType],
                        file: StaticString = #filePath,
                        line: UInt = #line) throws {
        let received = try extractMetricsWithSorting(from: try receivedMetricContainer())
        let expected = sortedMetrics(type.map({ $0.diagnosticMetric }))

        let receivedNames = received.map({ $0.name })
        expected.forEach { metric in
            XCTAssertEqual(receivedNames.contains(metric.name),
                           true,
                           "Metric has not been sent \(metric.name)",
                           file: file,
                           line: line)
        }

    }

    func expectedLegacy(metrics types: [SDKMetricType],
                        file: StaticString = #filePath,
                        line: UInt = #line) throws {
        let received = try extractMetricsWithSorting(from: try receivedMetricContainer())
        let expected = sortedMetrics(types.map({ $0.diagnosticMetric }))

        let receivedNames = received.map({ $0.name })
        receivedNames.enumerated().forEach { element in
            XCTAssertEqual(expected[element.offset].name,
                           element.element,
                           file: file,
                           line: line)
        }
    }

    func expectedTags(for metrics: [SDKMetricType],
                      tags: [String: String],
                      file: StaticString = #filePath,
                      line: UInt = #line) throws {
        let expected = metrics.map({ $0.diagnosticMetric.name })
        let received = try extractMetricsWithSorting(from: try receivedMetricContainer())
        received.filter({ expected.contains($0.name) })
            .enumerated()
            .forEach({ XCTAssertEqual($0.element.tags, tags, "Shoud have tags \(tags) for metric \($0.element.name)") })
    }
}

private extension SDKMetricsValidator {
    func extractMetricsWithSorting(from containers: [UnityAdsDiagnosticMetricContainer]) throws -> [UnityAdsDiagnosticMetric] {
        sortedMetrics(containers.flatMap({ $0.metrics }))
    }
    func receivedMetricContainer() throws -> [UnityAdsDiagnosticMetricContainer] {
        try self.stub.requests.compactMap({ try $0.decodableObject() })
    }

    func sortedMetrics(_ metrics: [UnityAdsDiagnosticMetric]) -> [UnityAdsDiagnosticMetric] {
        metrics.sorted(by: { $0.name < $1.name })
    }
}
