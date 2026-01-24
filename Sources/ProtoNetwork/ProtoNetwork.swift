// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public nonisolated protocol ProtoNetworkProtocol {
    func request<T: Decodable>(_ method: ProtoNetworkMethod, url: String, headers: [String: String?], as type: T.Type) async throws -> T
}

public extension ProtoNetworkProtocol {
    func request<T: Decodable>(_ method: ProtoNetworkMethod, url: String, as type: T.Type) async throws -> T {
        return try await request(method, url: url, headers: [:], as: type)
    }
}

public class ProtoNetwork: ProtoNetworkProtocol {
    
    public var timeoutInterval: TimeInterval
    
    public init(timeoutInterval: TimeInterval = 30) {
        self.timeoutInterval = timeoutInterval
    }
    
    public func request<T: Decodable>(_ method: ProtoNetworkMethod, url: String, headers: [String: String?], as type: T.Type) async throws -> T {
        let request = try makeRequest(url: url, method: method)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func makeRequest(url: String, method: ProtoNetworkMethod, httpHeaders: [String: String?] = [:]) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = timeoutInterval
        return request
    }
}
