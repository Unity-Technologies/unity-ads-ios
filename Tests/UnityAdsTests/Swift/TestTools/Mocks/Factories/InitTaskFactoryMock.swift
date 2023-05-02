import Foundation
@testable import UnityAds

final class InitTaskFactoryMock: TaskFactory {
    var taskMock = TaskMock()
    func task(of type: String) -> Task {
        return taskMock
    }

    typealias Element = String

}
