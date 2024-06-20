import Foundation
import Alamofire

struct ApifyItem: Codable {
    let someField: String
}

struct ApifyResponse: Codable {
    let items: [ApifyItem]
}

class ApifyClient {
    static let shared = ApifyClient()
    
    private init() {}
    
    func runApifyTask(completion: @escaping (Result<ApifyResponse, Error>, String?) -> Void) {
        guard let taskId = ProcessInfo.processInfo.environment["APIFY_TASK_ID"],
              let apiKey = ProcessInfo.processInfo.environment["APIFY_API_KEY"] else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing API key or Task ID"])), nil)
            return
        }
        
        let url = "https://api.apify.com/v2/actor-tasks/\(taskId)/run-sync-get-dataset-items"
        let parameters: Parameters = ["token": apiKey]
        
        AF.request(url, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apifyResponse = try decoder.decode(ApifyResponse.self, from: data)
                    completion(.success(apifyResponse), nil)
                } catch {
                    // Log the raw data for debugging
                    let rawDataString = String(data: data, encoding: .utf8) ?? "Unable to convert data to string."
                    completion(.failure(error), rawDataString)
                }
            case .failure(let error):
                completion(.failure(error), nil)
            }
        }
    }
}
