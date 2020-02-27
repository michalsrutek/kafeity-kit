//
//  SyncComponentProtocl.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import RxSwift


public protocol SyncComponentProtocol {
    
    var continueOnFail: Bool { get }
    
    func run() -> Completable
    
}
