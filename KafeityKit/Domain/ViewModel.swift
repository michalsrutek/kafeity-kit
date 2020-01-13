//
//  ViewModel.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation


public protocol RxVM {
    
    associatedtype Inputs
    associatedtype Outputs
    
    var inputs: Inputs { get }
    var outputs: Outputs { get }
    
}


public protocol ViewModel {
    
    associatedtype RxType: RxVM
    
    var rx: RxType { get }
    
}
