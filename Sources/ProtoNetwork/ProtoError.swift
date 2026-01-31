//
//  ProtoError.swift
//  ProtoNetwork
//
//  Created by Shibo Tong on 31/1/2026.
//

public struct ProtoError: Error, Decodable, CustomStringConvertible {
    public let error: String
    
    public var description: String {
        return error
    }
}
