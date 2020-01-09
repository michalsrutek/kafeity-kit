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
    
    public let components: [SyncComponentProtocol]
    
    fileprivate let lastErrors = BehaviorRelay<[Error]>(value: [])
    fileprivate let isSyncing = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    public init(components: [SyncComponentProtocol]) {
        self.components = components
    }
    
    public func start() {
        if isSyncing.value {
            return
        }
        lastErrors.accept([])
        isSyncing.accept(true)
        run(components: components)
    }
    
    private func run(components: [SyncComponentProtocol]) {
        guard let component = components.first else {
            syncEnded()
            return
        }
        let remainComponents = Array(components.dropFirst())
        
        component.run().subscribe(onCompleted: { [unowned self] in
            self.run(components: remainComponents)
        }) { [unowned self] (error) in
            var errors = self.lastErrors.value
            errors.append(error)
            self.lastErrors.accept(errors)
            
            if component.continueOnFail {
                self.run(components: remainComponents)
            } else {
                self.syncEnded()
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
