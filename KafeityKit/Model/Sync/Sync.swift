//
//  Sync.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay


public final class Sync {
    
    public let startComponents: [SyncStartComponentProtocol]
    public let components: [SyncComponentProtocol]
    public let endComponents: [SyncEndComponentProtocol]
    
    fileprivate let lastErrors = BehaviorRelay<[Error]>(value: [])
    fileprivate let isSyncing = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    public init(components: [SyncComponentProtocol]) {
        var startComponents = [SyncStartComponentProtocol]()
        var components = [SyncComponentProtocol]()
        var endComponents = [SyncEndComponentProtocol]()
        
        for component in components {
            if let startComponent = component as? SyncStartComponentProtocol {
                startComponents.append(startComponent)
            } else if let endComponent = component as? SyncEndComponentProtocol {
                endComponents.append(endComponent)
            } else {
                components.append(component)
            }
        }
        
        self.startComponents = startComponents
        self.components = components
        self.endComponents = endComponents
    }
    
    public func start() {
        if isSyncing.value {
            return
        }
        lastErrors.accept([])
        isSyncing.accept(true)
        run(components: startComponents) { [unowned self] canContinue in
            if !canContinue {
                self.syncEnded()
                return
            }
            self.run(components: self.components) { [unowned self] canContinue in
                if !canContinue {
                    self.syncEnded()
                    return
                }
                self.run(components: self.endComponents) { [unowned self] _ in
                    self.syncEnded()
                }
            }
        }
    }
    
    private func run(components: [SyncComponentProtocol], completion: @escaping (Bool) -> Void) {
        guard let component = components.first else {
            completion(true)
            return
        }
        let remainComponents = Array(components.dropFirst())
        
        component.run().subscribe(onCompleted: { [unowned self] in
            self.run(components: remainComponents, completion: completion)
        }) { [unowned self] (error) in
            var errors = self.lastErrors.value
            errors.append(error)
            self.lastErrors.accept(errors)
            
            if component.continueOnFail {
                self.run(components: remainComponents, completion: completion)
            } else {
                completion(false)
            }
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Helpers methods
    
    private func syncEnded() {
        isSyncing.accept(false)
    }
    
}

extension Sync: ReactiveCompatible {}

public extension Reactive where Base: Sync {
    
    var isSyncing: Observable<Bool> {
        return base.isSyncing.asObservable()
    }
    
    var finished: Observable<Void> {
        return base.isSyncing.skipWhile({ (isSyncing) -> Bool in
            return isSyncing
        }).asVoid()
    }
    
}
