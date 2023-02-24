import Foundation

final class InitializationSequence {
    private let experimentsReader: ExperimentsReader
    init(experimentsReader: ExperimentsReader) {
        self.experimentsReader = experimentsReader
    }

    typealias State = InitTaskCategory
    private var isNewParallelEnabled: Bool {
        experimentsReader.experiments?.isParallelExecutionEnabled.value ?? false
    }

    private var isNewSequentialEnabled: Bool {
        experimentsReader.experiments?.isUseNewTasksEnabled.value ?? false
    }

    var sequence: [State] {
        if isNewParallelEnabled { return newParallel }
        if isNewSequentialEnabled { return newSequential }

        return legacyFlow
    }

    private var legacyFlow: [State] {
        [
            .loadLocalConfig,
            .reset,
            .initModules,
            .configFetch,
            .webViewDownload,
            .webViewCreate,
            .complete
        ].map({ .sync($0) })
    }

    private var newSequential: [State] {
        [
            .reset,
            .loadLocalConfig,
            .initModules,
            .privacyFetch,
            .configFetch,
            .webViewDownload,
            .webViewCreate,
            .complete
        ].map({ .sync($0) })
    }

    private var newParallel: [State] {
        [
            .sync(.reset),
            .sync(.loadLocalConfig),
            .sync(.initModules),
            .sync(.privacyFetch),
            .async([.configFetch, .webViewDownload]),
            .sync(.webViewCreate),
            .sync(.complete)
        ]
    }

}
