import Foundation
@testable import UnityAds

final class MockWebRequest: USRVWebRequestWithUrlConnection {
     var allowReturningEmptyData: Bool = false
     var isProtocolClientEmpty = false
     var urlSession: URLSession = .shared
     override func make() -> Data! {
         guard let requestURL = URL(string: url) else {
             fatalError()
         }
         var request = URLRequest(url: requestURL)
         request.httpBody = bodyData ?? body?.data(using: .utf8)
         request.set(headers: ["Mock": "true"])
         let sem = DispatchSemaphore(value: 0)
         var receivedData: Data?
         urlSession.dataTask(with: request) { data, _, _ in

             receivedData = data
             sem.signal()
         }
         .resume()
         sem.wait()
         guard let data = receivedData else {
             if allowReturningEmptyData { return Data() }
             fatalError()
         }

         return data
     }

     override func is2XXResponse() -> Bool {
         true
     }
 }
