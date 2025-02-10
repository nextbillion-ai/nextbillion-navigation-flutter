//
//  UIColor.swift
//  Runner
//
//  Created by qiuyu on 2023/8/25.
//

import Foundation

extension UIColor {
    
    class var defaultTint: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
    class var defaultTintStroke: UIColor { #colorLiteral(red: 0.1843137255, green: 0.4784313725, blue: 0.7764705882, alpha: 1) }
    class var defaultPrimaryText: UIColor { #colorLiteral(red: 0.176, green: 0.176, blue: 0.176, alpha: 1) }
    class var defaultDarkAppearanceBackgroundColor: UIColor { #colorLiteral(red: 0.1493228376, green: 0.2374534607, blue: 0.333029449, alpha: 1) }
    
    class var defaultRouteCasing: UIColor { .defaultTintStroke }
    class var defaultRouteLayer: UIColor { #colorLiteral(red: 0.4520691633, green: 0.5277981758, blue: 0.9168900847, alpha: 1) }
    class var defaultAlternateLine: UIColor { #colorLiteral(red: 0.760784328, green: 0.7607844472, blue: 0.7607844472, alpha: 1) }
    class var defaultAlternateLineCasing: UIColor { #colorLiteral(red: 0.5019607843, green: 0.4980392157, blue: 0.5019607843, alpha: 1) }
    class var defaultTraversedRouteColor: UIColor { #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)}
    class var defaultManeuverArrowStroke: UIColor { .defaultRouteLayer }
    class var defaultManeuverArrow: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    
    class var defaultTurnArrowPrimary: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    class var defaultTurnArrowSecondary: UIColor { #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1) }
    
    
    class var defaultTurnArrowPrimaryHighlighted: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    class var defaultTurnArrowSecondaryHighlighted: UIColor { UIColor.white.withAlphaComponent(0.4) }
    
    class var defaultLaneArrowPrimary: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    class var defaultLaneArrowSecondary: UIColor { #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1) }
    
    class var defaultLaneArrowPrimaryHighlighted: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    class var defaultLaneArrowSecondaryHighlighted: UIColor { UIColor(white: 0.7, alpha: 1.0) }
    
    class var trafficUnknown: UIColor { defaultRouteLayer }
    class var trafficLow: UIColor { defaultRouteLayer }
    class var trafficModerate: UIColor { #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1) }
    class var trafficHeavy: UIColor { #colorLiteral(red: 1, green: 0.3019607843, blue: 0.3019607843, alpha: 1) }
    class var trafficSevere: UIColor { #colorLiteral(red: 0.5607843137, green: 0.1411764706, blue: 0.2784313725, alpha: 1) }
    class var trafficAlternateLow: UIColor { get { return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) } }
    
    class var alternativeTrafficUnknown: UIColor { defaultAlternateLine }
    class var alternativeTrafficLow: UIColor { defaultAlternateLine }
    class var alternativeTrafficModerate: UIColor { #colorLiteral(red: 0.75, green: 0.63, blue: 0.53, alpha: 1.0) }
    class var alternativeTrafficHeavy: UIColor { #colorLiteral(red: 0.71, green: 0.51, blue: 0.51, alpha: 1.0) }
    class var alternativeTrafficSevere: UIColor { #colorLiteral(red: 0.71, green: 0.51, blue: 0.51, alpha: 1.0) }
    class var defaultBuildingColor: UIColor { #colorLiteral(red: 0.9833194452, green: 0.9843137255, blue: 0.9331936657, alpha: 0.8019049658) }
    class var defaultBuildingHighlightColor: UIColor { #colorLiteral(red: 0.337254902, green: 0.6588235294, blue: 0.9843137255, alpha: 0.949406036) }
}
