//
//  API.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 08/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public class API<ErrorResponseType: Error> where ErrorResponseType: Decodable {

    private lazy var jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()
    
    private let eventBus: RxBus
    
    public init(eventBus: RxBus) {
        self.eventBus = eventBus
    }

    public func execute(request: RequestConvertible, successCodes: Set<Int>? = nil, responseHeaders: (([AnyHashable : Any]) -> Void)? = nil) -> Completable {
        return Completable.create { (completable) -> Disposable in
            let session = Alamofire.request(request)
                .validate(statusCode: Set(200 ..< 300).union(successCodes ?? Set()))
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success:
                        responseHeaders?(response.response?.allHeaderFields ?? [:])
                        completable(.completed)
                    case .failure(let error):
                        // Token is invalid, we must sign out
                        if response.response?.statusCode == 403 {
                            self.logOut()
                            completable(.error(error))
                            return
                        }
                        
                        // Parse error response from server
                        if let data = response.data, let response = self.parseErrorResponse(data: data) {
                            print(response)
                            completable(.error(response))
                            return
                        }
                        completable(.error(error))
                    }
            })
            
            return Disposables.create {
                session.cancel()
            }
        }
    }

    public func execute<Response: Decodable>(request: RequestConvertible, successCodes: Set<Int>? = nil, responseHeaders: (([AnyHashable : Any]) -> Void)? = nil) -> Single<Response> {
        let urlRequest = try! request.asURLRequest()

        return Single<Response>.create { (single) -> Disposable in
            let session = Alamofire.request(urlRequest)
                .validate(statusCode: Set(200 ..< 300).union(successCodes ?? Set()))
                .responseData(completionHandler: { [unowned self] (response) in
                    self.parseResponse(request: request, urlRequest: urlRequest, response: response, single: single, responseHeaders: responseHeaders)
                })

            return Disposables.create {
                session.cancel()
            }
        }
    }
    
    public func download(request: RequestConvertible) -> Single<Data> {
        let urlRequest = try! request.asURLRequest()
        
        return Single<Data>.create { (single) -> Disposable in
            let session = Alamofire.request(urlRequest)
                .validate()
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                            print(json)
                        }
                        
                        // Parse error response from server
                        if let data = response.data, let response = self.parseErrorResponse(data: data) {
                            single(.error(response))
                            return
                        }
                        
                        // Token is invalid, we must sign out
                        if response.response?.statusCode == 403 {
                            self.logOut()
                            single(.error(error))
                            return
                        }
                        
                        // Retrieve cached response if allowed
                        if request.allowCache, let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
                            single(.success(cachedResponse.data))
                            return
                        }
                        
                        print(error)
                        single(.error(error))
                    }
                })
            
            return Disposables.create {
                session.cancel()
            }
        }
    }
    
    func parseResponse<Response: Decodable>(request: RequestConvertible, urlRequest: URLRequest, response: Alamofire.DataResponse<Data>, single: (SingleEvent<Response>) -> (), responseHeaders: (([AnyHashable : Any]) -> Void)? = nil) {
        switch response.result {
        case .success(let data):
            responseHeaders?(response.response?.allHeaderFields ?? [:])
            self.parseResponse(data: data, single: single)
        case .failure(let error):
            if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                debugPrint(json)
            }

            // Parse error response from server
            if let data = response.data, let response = self.parseErrorResponse(data: data) {
                single(.error(response))
                return
            }

            // Token is invalid, we must sign out
            if response.response?.statusCode == 403 {
                self.logOut()
                single(.error(error))
                return
            }

            // Retrieve cached response if allowed
            if request.allowCache, let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
                self.parseResponse(data: cachedResponse.data, single: single)
                return
            }

            debugPrint(error)
            single(.error(error))
        }
    }
    
    private func logOut() {
        eventBus.post(LogoutBusEvent())
    }

    private func parseResponse<Response: Decodable>(data: Data, single: (SingleEvent<Response>) -> ()) {
        do {
            //debugPrint(try? JSONSerialization.jsonObject(with: data, options: []))
            let object = try self.jsonDecoder.decode(Response.self, from: data)
            single(.success(object))
        } catch {
            print(error)
            single(.error(error))
        }
    }
    
    private func parseErrorResponse(data: Data) -> ErrorResponseType? {
        return try? jsonDecoder.decode(ErrorResponseType.self, from: data)
    }
    
}
