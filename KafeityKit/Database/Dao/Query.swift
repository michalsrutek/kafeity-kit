//
//  Query.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import CoreData


public protocol Query {

    var predicate: NSPredicate { get }
    var sortDescriptor: NSSortDescriptor? { get }
    var fetchOffset: Int? { get }
    var fetchLimit: Int? { get }
    
}
