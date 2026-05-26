//
//  NBNavigationViewFactory.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2024/6/25.
//

import Foundation
import Flutter
public class NBNavigationViewFactory : NSObject, FlutterPlatformViewFactory
{
    let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return EmbeddedNavigationView(messenger: self.messenger, frame: frame, viewId: viewId, args: args)
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
