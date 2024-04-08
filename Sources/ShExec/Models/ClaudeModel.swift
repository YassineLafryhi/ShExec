import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [Content]
    let model: String
    let stopReason: String
    let stopSequence: String?
    let usage: Usage

    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model, usage
        case stopReason = "stop_reason"
        case stopSequence = "stop_sequence"
    }
}

struct Content: Codable {
    let type: String
    let text: String?
}

struct Usage: Codable {
    let inputTokens: Int
    let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

class ClaudeModel: Model {
    var name = "Claude-3-opus-20240229"
    var isLocal = false
    static let shared = ClaudeModel()
    var apiKey = ""
    var urlString = "https://api.anthropic.com/v1/messages"

    private init() {}

    func setApiKey(_ apiKey: String) {
        self.apiKey = apiKey
    }

    func generate(prompt: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")

        let requestBody = """
            {
                "model": "claude-3-opus-20240229",
                "max_tokens": 4000,
                "messages": [
                    {"role": "user", "content": "\(prompt)"}
                ]
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
