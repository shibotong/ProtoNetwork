// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public nonisolated protocol ProtoNetworkProtocol {
    func get<T: Decodable>(url: String, as type: T.Type) async throws -> T
    func post<T: Decodable>(url: String, as type: T.Type) async throws -> T
    func put<T: Decodable>(url: String, as type: T.Type) async throws -> T
    func delete<T: Decodable>(url: String, as type: T.Type) async throws -> T
    func patch<T: Decodable>(url: String, as type: T.Type) async throws -> T
}

public class ProtoNetwork: ProtoNetworkProtocol {
    public func get<T: Decodable>(url: String, as type: T.Type) async throws -> T {
        return try await request(url: url, method: .get, as: type)
    }
    
    public func post<T: Decodable>(url: String, as type: T.Type) async throws -> T {
        return try await request(url: url, method: .post, as: type)
    }
    
    public func put<T: Decodable>(url: String, as type: T.Type) async throws -> T {
        return try await request(url: url, method: .put, as: type)
    }
    
    public func delete<T: Decodable>(url: String, as type: T.Type) async throws -> T {
        return try await request(url: url, method: .delete, as: type)
    }
    
    public func patch<T: Decodable>(url: String, as type: T.Type) async throws -> T {
        return try await request(url: url, method: .patch, as: type)
    }
    
    func request<T: Decodable>(url: String, method: ProtoNetworkMethod, as type: T.Type) async throws -> T {
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
    
    func makeRequest(url: String, method: ProtoNetworkMethod) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        return request
    }
}
