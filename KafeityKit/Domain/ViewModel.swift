//
//  ViewModel.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import RxSwift


public protocol ViewModel: ReactiveCompatible {
    
    associatedtype Inputs
    associatedtype Outputs
    
    var inputs: Inputs { get }
    var outputs: Outputs { get }
    
}
