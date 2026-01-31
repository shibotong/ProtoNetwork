// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public nonisolated protocol ProtoNetworkProtocol {
    func request<T: Decodable>(method: ProtoNetworkMethod, url: String, query: [String: String], headers: [String: String?], body: [String: Any?], as type: T.Type) async throws -> T
}

public extension ProtoNetworkProtocol {
    func request<T: Decodable>(_ method: ProtoNetworkMethod, url: String, query: [String: String] = [:], headers: [String: String?] = [:], body: [String: Any?], as type: T.Type) async throws -> T {
        return try await request(method: method, url: url, query: query, headers: headers, body: body, as: type)
    }
}

public class ProtoNetwork: ProtoNetworkProtocol {
    
    public var timeoutInterval: TimeInterval
    
    public init(timeoutInterval: TimeInterval = 30) {
        self.timeoutInterval = timeoutInterval
    }
    
    public func request<T: Decodable>(method: ProtoNetworkMethod, url: String, query: [String: String], headers: [String: String?], body: [String: Any?], as type: T.Type) async throws -> T {
        let request = try makeRequest(url: url, method: method, query: query, body: body, httpHeaders: headers)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func makeRequest(url: String, method: ProtoNetworkMethod, query: [String: String], body: [String: Any?], httpHeaders: [String: String?]) throws -> URLRequest {
        guard var url = URL(string: url) else {
            throw URLError(.badURL)
        }
        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        url.append(queryItems: queryItems)
        var request = URLRequest(url: url)
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = bodyData
        request.httpMethod = method.rawValue
        for (key, value) in httpHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = timeoutInterval
        return request
    }
}
