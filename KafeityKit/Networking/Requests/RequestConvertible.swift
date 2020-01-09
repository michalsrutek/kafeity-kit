//
//  RequestConvertible.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Alamofire

public protocol RequestConvertible: URLRequestConvertible {

    var url: URLConvertible { get }
    var method: HTTPMethod { get }
    var allowCache: Bool { get }
    var allowAcceptType: Bool { get }
    var commonHeaders: [HeaderItem]? { get }

    func encodeBody() throws -> Data?
}

public extension RequestConvertible {
    
    var allowAcceptType: Bool {
        return true
    }
    
}

public extension RequestConvertible {

    func encodeBody() throws -> Data? {
        return nil
    }

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: url, method: method)
        let headers = HeadersBuilder()

        // Add common header fields
        for header in commonHeaders ?? [] {
            _ = headers.add(header)
        }

        // Encode request body
        if let body = try! encodeBody() {
            request.httpBody = body
            _ = headers.add(.contentType(.json))
        }
        
        if allowAcceptType {
            _ = headers.add(.accept("application/json"))
        }

        request.allHTTPHeaderFields = headers.build()

        return request
    }
}
