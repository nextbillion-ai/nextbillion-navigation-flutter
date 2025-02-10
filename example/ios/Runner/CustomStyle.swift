//
//  CustomStyle.swift
//  Runner
//
//  Created by qiuyu on 2023/8/25.
//

import Foundation
import NbmapNavigation

class CustomDayStyle: DayStyle {
    required init() {
        super.init()
        mapStyleURL = URL(string: "https://api.nextbillion.io/tt/style/1/style/22.2.1-9?map=2/basic_street-light")!
    }
    
    override func apply() {
        super.apply()
        ArrivalTimeLabel.appearance().font = UIFont.systemFont(ofSize: 18, weight: .medium).adjustedFont
        ArrivalTimeLabel.appearance().normalTextColor = .defaultPrimaryText
        BottomBannerContentView.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        BottomBannerView.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Button.appearance().textColor = .defaultPrimaryText
        CancelButton.appearance().backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        CancelButton.appearance().textFont = UIFont.systemFont(ofSize: 16, weight: .regular).adjustedFont
        CancelButton.appearance().textColor =  #colorLiteral(red: 0.9842069745, green: 0.9843751788, blue: 0.9841964841, alpha: 1)
        OverviewButton.appearance().borderColor = #colorLiteral(red: 0.94117647, green: 0.95294118, blue: 1, alpha: 1)
        OverviewButton.appearance().tintColor = #colorLiteral(red: 0.2566259801, green: 0.3436664343, blue: 0.8086165786, alpha: 0.6812137831)
        DismissButton.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        DismissButton.appearance().textColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
        DismissButton.appearance().textFont = UIFont.systemFont(ofSize: 20, weight: .medium).adjustedFont
        DistanceLabel.appearance().unitFont = UIFont.systemFont(ofSize: 14, weight: .medium).adjustedFont
        DistanceLabel.appearance().valueFont = UIFont.systemFont(ofSize: 22, weight: .medium).adjustedFont
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).unitTextColor = #colorLiteral(red: 0.980392158, green: 0.980392158, blue: 0.980392158, alpha: 1)
        DistanceLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).valueTextColor = #colorLiteral(red: 0.980392158, green: 0.980392158, blue: 0.980392158, alpha: 1)
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).unitTextColor = #colorLiteral(red: 0.3999999762, green: 0.3999999762, blue: 0.3999999762, alpha: 1)
        DistanceLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).valueTextColor = #colorLiteral(red: 0.3999999762, green: 0.3999999762, blue: 0.3999999762, alpha: 1)
        DistanceRemainingLabel.appearance().font = UIFont.systemFont(ofSize: 18, weight: .medium).adjustedFont
        DistanceRemainingLabel.appearance().normalTextColor = #colorLiteral(red: 0.3999999762, green: 0.3999999762, blue: 0.3999999762, alpha: 1)
        EndOfRouteButton.appearance().textColor = .darkGray
        EndOfRouteButton.appearance().textFont = .systemFont(ofSize: 15)
        EndOfRouteContentView.appearance().backgroundColor = .white
        EndOfRouteStaticLabel.appearance().normalFont = .systemFont(ofSize: 14.0)
        EndOfRouteStaticLabel.appearance().normalTextColor = #colorLiteral(red: 0.217173934, green: 0.3645851612, blue: 0.489295125, alpha: 1)
        EndOfRouteTitleLabel.appearance().normalFont = .systemFont(ofSize: 36.0)
        EndOfRouteTitleLabel.appearance().normalTextColor = UIColor.black
        FloatingButton.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        FloatingButton.appearance().tintColor = tintColor
        GenericRouteShield.appearance().backgroundColor = UIColor.clear
        InstructionsBannerContentView.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        InstructionsBannerView.appearance().backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        LaneView.appearance().primaryColor = .defaultLaneArrowPrimary
        LaneView.appearance().secondaryColor = .defaultLaneArrowSecondary
        LanesView.appearance().backgroundColor = #colorLiteral(red: 0.1522715986, green: 0.5290428996, blue: 0.1787364483, alpha: 1)
        LineView.appearance().lineColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1)
        ManeuverView.appearance().backgroundColor = .clear
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).primaryColor = .defaultTurnArrowPrimary
        ManeuverView.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).secondaryColor = .defaultTurnArrowSecondary
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).primaryColor = .defaultTurnArrowPrimary
        ManeuverView.appearance(whenContainedInInstancesOf: [NextBannerView.self]).secondaryColor = .defaultTurnArrowSecondary
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).primaryColor =  #colorLiteral(red: 0.2392157018, green: 0.2392157018, blue: 0.2392157018, alpha: 1) //.defaultTurnArrowPrimary
        ManeuverView.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).secondaryColor = .defaultTurnArrowSecondary
        NavigationMapView.appearance().maneuverArrowColor       = .defaultManeuverArrow
        NavigationMapView.appearance().maneuverArrowStrokeColor = .defaultManeuverArrowStroke
        NavigationMapView.appearance().routeAlternateColor      = .defaultAlternateLine
        NavigationMapView.appearance().routeCasingColor         = .defaultRouteCasing
        NavigationMapView.appearance().trafficHeavyColor        = .trafficHeavy
        NavigationMapView.appearance().trafficLowColor          = .trafficLow
        NavigationMapView.appearance().trafficModerateColor     = .trafficModerate
        NavigationMapView.appearance().trafficSevereColor       = .trafficSevere
        NavigationMapView.appearance().trafficUnknownColor      = #colorLiteral(red: 0.6196078431, green: 0.06274509804, blue: 1, alpha: 1)
        NavigationView.appearance().backgroundColor = #colorLiteral(red: 0.764706, green: 0.752941, blue: 0.733333, alpha: 1)
        NextBannerView.appearance().backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.06274509804, blue: 1, alpha: 1)
        NextInstructionLabel.appearance().font = UIFont.systemFont(ofSize: 20, weight: .medium).adjustedFont
        NextInstructionLabel.appearance().normalTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        PrimaryLabel.appearance().normalFont = UIFont.systemFont(ofSize: 30, weight: .medium).adjustedFont
        PrimaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
        PrimaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalFont =  UIFont.systemFont(ofSize: 15, weight: .medium).adjustedFont
        ProgressBar.appearance().barColor = #colorLiteral(red: 0.149, green: 0.239, blue: 0.341, alpha: 1)
        ReportButton.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        ReportButton.appearance().textColor = tintColor!
        ReportButton.appearance().textFont = UIFont.systemFont(ofSize: 15, weight: .medium).adjustedFont
        ResumeButton.appearance().backgroundColor = #colorLiteral(red: 0.4609908462, green: 0.5315783024, blue: 0.9125307202, alpha: 1)
        ResumeButton.appearance().tintColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        SecondaryLabel.appearance().normalFont = UIFont.systemFont(ofSize: 26, weight: .medium).adjustedFont
        SecondaryLabel.appearance(whenContainedInInstancesOf: [InstructionsBannerView.self]).normalTextColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        SecondaryLabel.appearance(whenContainedInInstancesOf: [StepInstructionsView.self]).normalTextColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        SeparatorView.appearance().backgroundColor = #colorLiteral(red: 0.737254902, green: 0.7960784314, blue: 0.8705882353, alpha: 1)
        StatusView.appearance().backgroundColor = UIColor.black.withAlphaComponent(2.0/3.0)
        StepInstructionsView.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        StepListIndicatorView.appearance().gradientColors = [#colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1), #colorLiteral(red: 0.6274509804, green: 0.6274509804, blue: 0.6274509804, alpha: 1), #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)]
        StepTableViewCell.appearance().backgroundColor = #colorLiteral(red: 0.9675388083, green: 0.9675388083, blue: 0.9675388083, alpha: 1)
        StepsBackgroundView.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        TimeRemainingLabel.appearance().font = UIFont.systemFont(ofSize: 28, weight: .medium).adjustedFont
        TimeRemainingLabel.appearance().normalTextColor = .defaultPrimaryText
        TimeRemainingLabel.appearance().trafficHeavyColor = #colorLiteral(red:0.91, green:0.20, blue:0.25, alpha:1.0)
        TimeRemainingLabel.appearance().trafficLowColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        TimeRemainingLabel.appearance().trafficModerateColor = #colorLiteral(red:0.95, green:0.65, blue:0.31, alpha:1.0)
        TimeRemainingLabel.appearance().trafficSevereColor = #colorLiteral(red: 0.7705719471, green: 0.1753477752, blue: 0.1177056804, alpha: 1)
        TimeRemainingLabel.appearance().trafficUnknownColor = .defaultPrimaryText
//        UserPuckCourseView.appearance().puckColor = #colorLiteral(red: 0.4609908462, green: 0.5315783024, blue: 0.9125307202, alpha: 1)
        WayNameLabel.appearance().normalFont = UIFont.systemFont(ofSize:20, weight: .medium).adjustedFont
        WayNameLabel.appearance().normalTextColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        WayNameView.appearance().backgroundColor = UIColor.defaultRouteLayer.withAlphaComponent(0.85)
        WayNameView.appearance().borderColor = UIColor.defaultRouteCasing.withAlphaComponent(0.8)
        SpeedView.appearance().textColor = UIColor.defaultPrimaryText
        SpeedView.appearance().signBackColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

class CustomNightStyle: NightStyle {
    required init() {
        super.init()
        mapStyleURL = URL(string: "https://api.nextbillion.io/tt/style/1/style/22.2.1-9?map=2/basic_street-dark")!
    }
    
    override func apply() {
        super.apply()
        NavigationMapView.appearance().trafficUnknownColor = UIColor.green
    }
}
