
import Foundation
import RxSwift


public protocol SyncEndComponentProtocol: SyncComponentProtocol {
    
}

public extension SyncEndComponentProtocol {
    
    var continueOnFail: Bool {
        true
    }
    
}
