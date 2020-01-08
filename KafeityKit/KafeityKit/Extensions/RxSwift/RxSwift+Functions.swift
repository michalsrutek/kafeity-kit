//
//  RxSwift+Functions.swift
//  KafeityKit
//
//  Created by Libor Polehna on 11/12/2019.
//  Copyright © 2019 SKOUMAL, s.r.o. All rights reserved.
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
