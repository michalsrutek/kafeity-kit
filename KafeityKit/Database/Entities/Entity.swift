//
//  Entity.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

public protocol Entity {

    static var entityName: String { get }
}

public extension Entity {

    static var entityName: String {
        return String(describing: self)
    }
    
}
