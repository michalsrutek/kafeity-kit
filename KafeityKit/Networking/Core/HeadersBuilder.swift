//
//  HeadersBuilder.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Alamofire

public enum HeaderItem {
    
    case token(String, String)
    case acceptLanguage(String)
    case contentType(HeadersBuilder.ContentType)
    case accept(String)
    case generic(String, String)
    
    var key: String {
        switch self {
        case .token: return "Authorization"
        case .acceptLanguage: return "Accept-Language"
        case .contentType: return "Content-Type"
        case .accept: return "Accept"
        case .generic(let key, _): return key
        }
    }
    
    var value: String {
        switch self {
        case .token(let type, let token): return "\(type) \(token)"
        case .acceptLanguage(let language): return language
        case .contentType(let contentType): return contentType.toString
        case .accept(let value): return value
        case .generic(_, let value): return value
        }
    }
}

public class HeadersBuilder {
    
    public enum ContentType {
        case json
        
        var toString: String {
            switch self {
            case .json: return "application/json"
            }
        }
    }
    
    private var headers = HTTPHeaders()
    
    public func add(_ item: HeaderItem) -> HeadersBuilder {
        headers[item.key] = item.value
        return self
    }
    
    public func build() -> HTTPHeaders {
        return headers
    }
}
