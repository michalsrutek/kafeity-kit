//
//  RxSwift+Functions.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import RxSwift


public extension Observable {
    
    func asVoid() -> Observable<Void> {
        return map({ _ -> Void in
            return
        })
    }
    
}
