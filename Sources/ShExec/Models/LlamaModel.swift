import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct LlamaResponse: Codable {
    let model: String
    let createdAt: String
    let message: LlamaMessage
    let done: Bool
    let totalDuration: Int
    let loadDuration: Int
    let promptEvalCount: Int
    let promptEvalDuration: Int
    let evalCount: Int
    let evalDuration: Int

    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case message
        case done
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

struct LlamaMessage: Codable {
    let role: String
    let content: String
}

class LlamaModel: Model {
    var name = "Llama2"
    var isLocal = true
    func setApiKey(_: String) {}

    static let shared = LlamaModel()
    var urlString = "http://localhost:11434/api/chat"

    private init() {}

    func generate(prompt: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")

        let requestBody = """
            {
                "model": "llama2",
                "messages": [
                    {"role": "user", "content": "\(prompt)"}
                ],
                "stream": false
            }
            """
        request.httpBody = requestBody.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: nil)))
                return
            }
            completion(.success(data))
        }

        task.resume()
    }
}
