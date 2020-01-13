//
//  Config.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 13/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation


public enum ConfigKey {
    
    static let token = "Token"
    
}

public struct Config {
    
    @UserDefault(key: ConfigKey.token, defaultValue: nil)
    static var token: String?
    
}
