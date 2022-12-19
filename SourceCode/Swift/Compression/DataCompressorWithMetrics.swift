import Foundation

final class DataCompressorWithMetrics: GenericPerformanceMetricsDecorator<
DataCompressor, Constants.Metrics.Compression, Data>, DataCompressor {
    func compress<T>(obj: T) throws -> Data where T: DataSerializable {
        startMeasuring()
        do {
            let data = try original.compress(obj: obj)
            sendMetrics(for: .success(data))
            return data
        } catch {
            sendMetrics(for: .failure(error))
            throw error
        }

    }
}
