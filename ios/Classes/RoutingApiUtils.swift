//
// Copyright © 2023 NextBillion.ai. All rights reserved.
// Use of this source code is governed by license that can be found in the LICENSE file.
//


import Foundation
import UIKit

public let DEFAULT_BASE_URL = "https://api.nextbillion.io"
open class RoutingApiUtils {
    
    private static var sharedRoutingApiUtils: RoutingApiUtils?
    
    public var baseUri: String
    
    private init(baseUri: String?) {
        guard let uri = baseUri, !baseUri!.isEmpty else {
            guard let resUri = Bundle.main.object(forInfoDictionaryKey: "NBNavBaseUri") as? String, !resUri.isEmpty else {
                self.baseUri = DEFAULT_BASE_URL
                return
            }
            self.baseUri = resUri
            return
        }
        self.baseUri = uri
    }
    
    open class func shared(baseUri: String? = DEFAULT_BASE_URL) -> RoutingApiUtils {
        if sharedRoutingApiUtils == nil {
            sharedRoutingApiUtils = RoutingApiUtils(baseUri: baseUri)
        }
        return sharedRoutingApiUtils!
    }
    
    
}
