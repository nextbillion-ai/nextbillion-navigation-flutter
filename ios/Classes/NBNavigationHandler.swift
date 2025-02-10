//
//  NBNavigationHandler.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/7/5.
//

import Foundation
import Flutter
import Nbmap

class NBNavigationHandler: MethodChannelHandler {
    override init() {
        super.init()
        methodChannel = MethodChannelManager.shared.navigationChannel
    }
    
    override func handleMethodCallResult(call: FlutterMethodCall?, result: @escaping FlutterResult) {
        super.handleMethodCallResult(call: call, result: result)
        
        guard let call = call else {
            return
        }
        
        switch call.method {
        case MethodID.NAVIGATION_INIT_NAVIGATION:
            guard let args = call.arguments as? [String : Any] else {
                result(nil)
                return
            }
            if let accessKey = args["accessKey"] as? String {
                NGLAccountManager.accessToken = accessKey
            }
            result(nil)
        case MethodID.NAVIGATION_GET_BASE_URL:
            result(RoutingApiUtils.shared().baseUri)
            
        case MethodID.NAVIGATION_SET_BASE_URL:
            guard let args = call.arguments as? [String : Any] else {
                result(false)
                return
            }
            RoutingApiUtils.shared().baseUri = args["navigationBaseUri"] as! String
            result(true)
        default:
            break
        }
    }
    
}
