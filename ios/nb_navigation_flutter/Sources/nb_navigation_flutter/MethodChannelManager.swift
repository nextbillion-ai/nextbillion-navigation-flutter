//
//  MethodChannelManager.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/7/5.
//

import Foundation
import Flutter

class MethodChannelManager {
    static let shared = MethodChannelManager()
    
    var navigationChannel: FlutterMethodChannel?
    
    private init() {
    }
}
