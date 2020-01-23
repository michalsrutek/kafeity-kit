//
//  Resources.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Alamofire

public enum Resources {

    private static let jsonEncoder = JSONEncoder()

    public static func encode<T: Encodable>(_ body: T) throws -> Data {
        return try jsonEncoder.encode(body)
    }
    
}
