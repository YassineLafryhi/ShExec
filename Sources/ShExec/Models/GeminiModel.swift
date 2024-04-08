import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
    let promptFeedback: GeminiPromptFeedback
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
    let finishReason: String
    let index: Int
    let safetyRatings: [GeminiSafetyRating]
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
    let role: String
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiSafetyRating: Codable {
    let category: String
    let probability: String
}

struct GeminiPromptFeedback: Codable {
    let safetyRatings: [GeminiSafetyRating]
}

class GeminiModel: Model {
    var name = "Gemini 1.0 Pro"
    var isLocal = false
    static let shared = GeminiModel()
    var apiKey = ""
    var urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro:generateContent"

    private init() {}

    func setApiKey(_ apiKey: String) {
        self.apiKey = apiKey
    }

    func generate(prompt: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString + "?key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.9,
                "topK": 1,
                "topP": 1,
                "maxOutputTokens": 2_048,
                "stopSequences": []
            ],
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2, userInfo: nil)))
                return
            }
            completion(.success(data))
        }.resume()
    }
}
