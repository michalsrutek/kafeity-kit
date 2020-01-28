//
//  RxBus.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import RxSwift


public class RxBus {

    private let bus = PublishSubject<RxBusEvent>()
    
    public init() {
        
    }

    public func register<T>(_ type: T.Type) -> Observable<T> where T: RxBusEvent {
        return bus
            .filter({ $0 is T })
            .map({ return $0 as! T })
    }
    
    public func register<T, R>(_ firstType: T.Type, _ secondType: R.Type) -> Observable<Void> where T: RxBusEvent, R: RxBusEvent {
        let firstObservable = register(firstType).asVoid()
        let secondObservable = register(secondType).asVoid()
        return Observable.merge(firstObservable, secondObservable).map({ return })
    }

    public func post(_ event: RxBusEvent) {
        bus.onNext(event)
    }
    
}
