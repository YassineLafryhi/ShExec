import Foundation

protocol Model {
    var name: String { get set }
    var isLocal: Bool { get set }
    var urlString: String { get set }
    func setApiKey(_ apiKey: String)
    func generate(prompt: String, completion: @escaping (Result<Data, Error>) -> Void)
}
