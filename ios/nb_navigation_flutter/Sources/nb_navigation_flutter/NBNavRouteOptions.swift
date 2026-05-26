//
//  NBNavRouteOptions.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/3/2.
//

import Foundation
import Nbmap
import NbmapCoreNavigation

class NBNavRouteOptions: NavigationRouteOptions {
    
    override var accessToken: String {
        return NGLAccountManager.accessToken ?? ""
    }
    
    
    override var apiEndpoint: URL {
        return URL(string: RoutingApiUtils.shared().baseUri)!
    }
    
    override var apiKeyHeaderName: String? {
        return NGLAccountManager.apiKeyHeaderName ?? nil
    }
    
}
