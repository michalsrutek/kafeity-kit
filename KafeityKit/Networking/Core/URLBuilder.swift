//
//  URLBuilder.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Alamofire

public enum QueryItem {

    case offset(Int)
    case limit(Int)
    case query(String)
    case category(Int)
    case location(Int)
    case id(String)
    case count(Int)
    case search(String)
    case date(String)
    case generic(String, String)

    public var urlQueryItem: URLQueryItem {
        switch self {
        case .offset(let value):
            return URLQueryItem(name: "offset", value: String(value))
        case .limit(let value):
            return URLQueryItem(name: "limit", value: String(value))
        case .query(let value):
            return URLQueryItem(name: "q", value: value)
        case .category(let value):
            return URLQueryItem(name: "category", value: String(value))
        case .location(let value):
            return URLQueryItem(name: "location", value: String(value))
        case .id(let id):
            return URLQueryItem(name: "fkUser", value: id)
        case .count(let value):
            return URLQueryItem(name: "count", value: String(value))
        case .search(let value):
            return URLQueryItem(name: "searchIn", value: value)
        case .date(let value):
            return URLQueryItem(name: "date", value: value)
        case .generic(let key, let value):
            return URLQueryItem(name: key, value: value)
        }
    }
}

public class URLBuilder {

    private let url: String
    private var queryItems = [URLQueryItem]()

    public init(path: String) {
        url = path
    }

    public func query(_ item: QueryItem) -> URLBuilder {
        queryItems.append(item.urlQueryItem)
        return self
    }

    public func build() -> URL {
        var components = URLComponents(string: url)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return try! components.asURL()
    }
}

extension URLBuilder: URLConvertible {

    public func asURL() throws -> URL {
        return build()
    }
    
}
