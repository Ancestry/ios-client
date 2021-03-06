//
//  Api.swift
//  SwiftSeedProject
//
//  Created by Brian Sztamfater on 9/19/17.
//  Copyright © 2017 Split Software. All rights reserved.
//

import Foundation

@objc public final class RestClient: NSObject {
    // MARK: - Private Properties
    private let manager: RestClientManagerProtocol
    
    // MARK: - Designated Initializer
    init(manager: RestClientManagerProtocol = RestClientConfiguration.manager) {
        self.manager = manager
    }
    
    // MARK: - Private Functions
    private func start<T: Any>(target: Target, completion: @escaping (DataResult<T>) -> Void) where T: Decodable {
        let _ = manager.sendRequest(target: target).getResponse(errorSanitizer: target.errorSanitizer) { response in
            switch response.result {
            case .success(let json):
                if json.isNull(){
                    completion( DataResult{ return nil } )
                    return
                }
                
                do {
                    let parsedObject = try json.decode(T.self)
                    completion( DataResult{ return parsedObject } )
                } catch {
                    completion( DataResult{ throw error })
                }
            case .failure(let error):
                completion( DataResult{ throw error })
            }
        }
    }
    
    // MARK: - Internal Functions
    internal func execute<T>(target: Target, completion: @escaping (DataResult<T>) -> Void) where T: Decodable {
        self.start(target: target, completion: completion)
    }
}

extension RestClient {
    func isServerAvailable(_ url: URL) -> Bool {
        return self.isServerAvailable(url.absoluteString)
    }
    
    func isServerAvailable(_ url: String) -> Bool {
        if let reachabilityManager = NetworkReachabilityManager(host: url) {
            return reachabilityManager.isReachable
        }
        return false
    }
    
    func isServerAvailable() -> Bool {
        return self.isServerAvailable(EnvironmentTargetManager.shared.eventsBaseURL)
    }
}
