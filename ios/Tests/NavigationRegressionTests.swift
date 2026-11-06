import Flutter
import Foundation
import NbmapCoreNavigation
import UIKit
@testable import nb_navigation_flutter

/// Standalone simulator checks using the built plugin and actual SDK binaries.
/// No API key, network access, or downloaded regions are required.
@main
struct NavigationRegressionTests {
    @MainActor
    static func main() throws {
        let options = Convert.convertRouteRequestParams(arguments: """
        {"origin":[-120.2,38.5],"destination":[-120.95,40.7],"geometry":"polyline"}
        """)!
        let json = """
        {"distance":1000,"duration":100,"geometry":"_p~iF~ps|U_ulLnnqC",
         "_nbFlutterGuidanceReady":true,"legs":[{"distance":{"value":1000},
         "duration":{"value":100},"steps":[{"distance":{"value":1000},
         "duration":{"value":100},"geometry":"_p~iF~ps|U_ulLnnqC",
         "maneuver":{"maneuver_type":"depart","coordinate":{"latitude":38.5,"longitude":-120.2}},
         "intersections":[{"location":{"latitude":38.5,"longitude":-120.2},
         "bearings":[0.5,90.25,180.75],"entry":[true,true,true],"intersection_in":1,"intersection_out":2}],
         "bannerInstructions":[{"distanceAlongGeometry":100,"primary":{"type":"turn","components":[
         {"type":"icon","imageURL":"https://example.test/sign@3x.png?key=a","label":"A1","abbr":"A","abbr_priority":2}]},
         "sub":{"components":[{"type":"lane","directions":["left","straight"],"active":true}]}}]}]}]}
        """
        let original = Convert.modifyRoute(routeOptions: options, routeJson: json)
        let encoded = try NavigationRouteCodec.encode(original)
        let decoded = Convert.modifyRoute(routeOptions: options, routeJson: encoded)
        let step = decoded.legs[0].steps[0]
        let intersection = step.intersections![0]
        precondition(intersection.approachIndex == 1 && intersection.outletIndex == 2)
        precondition(intersection.headings == [0.5, 90.25, 180.75])
        let banner = step.instructionsDisplayedAlongStep![0]
        let component = banner.primaryInstruction!.components[0] as! VisualInstructionComponent
        precondition(component.imageURL?.absoluteString == "https://example.test/sign@3x.png?key=a")
        precondition(component.abbreviationPriority == 2 && component.label == "A1")
        let lane = banner.tertiaryInstruction!.components[0] as! LaneIndicationComponent
        precondition(lane.isUsable && lane.indications.contains(.left) && lane.indications.contains(.straightAhead))

        let roadJson = json.replacingOccurrences(of: "\"maneuver_type\":\"depart\"", with: "\"maneuver_type\":\"roundabout\"")
            .replacingOccurrences(of: "\"maneuver\":{", with: "\"name\":\"Exit Road\",\"rotary_name\":\"Test Circle\",\"ref\":\"R1\",\"destinations\":\"D1: Town\",\"exits\":\"7A\",\"pronunciation\":\"exit\",\"rotary_pronunciation\":\"circle\",\"maneuver\":{")
        let fused = Convert.modifyRoute(routeOptions: options, routeJson: roadJson)
        fused.json = nil
        let restored = Convert.modifyRoute(routeOptions: options, routeJson: try NavigationRouteCodec.encode(fused)).legs[0].steps[0]
        precondition(restored.names == ["Test Circle"] && restored.exitNames == ["Exit Road"])
        precondition(restored.codes == ["R1"] && restored.exitCodes == ["7A"])
        precondition(restored.destinationCodes == ["D1"] && restored.destinations == ["Town"])
        precondition(restored.phoneticNames == ["circle"] && restored.phoneticExitNames == ["exit"])
        print("PASS: fused routes without original JSON preserve road, exit and roundabout metadata")

        let invalid = Convert.modifyRoute(routeOptions: options,
            routeJson: json.replacingOccurrences(of: "\"intersection_out\":2", with: "\"intersection_out\":99"))
        let safe = Convert.modifyRoute(routeOptions: options, routeJson: try NavigationRouteCodec.encode(invalid))
        precondition(safe.legs[0].steps[0].intersections![0].outletIndex == -1)
        print("PASS: native route round trip preserves lanes, images and bounded intersection indices")

        let fetcher = RouteFetcherHandler()
        for args: [String: Any] in [
            ["clickPoint": [], "coordinates": []],
            ["clickPoint": [38.5, -120.2], "coordinates": [[[38.5]]]],
            ["clickPoint": [Double.nan, -120.2], "coordinates": []]
        ] {
            var replied = false
            fetcher.handleMethodCallResult(call: FlutterMethodCall(methodName: "route/findSelectedRouteIndex", arguments: args)) {
                precondition(($0 as? FlutterError)?.code == "INVALID_ARGUMENT")
                replied = true
            }
            precondition(replied)
        }
        var selected: Int?
        fetcher.handleMethodCallResult(call: FlutterMethodCall(methodName: "route/findSelectedRouteIndex", arguments: [
            "clickPoint": [38.5, -120.2], "coordinates": [[], [[38.5, -120.2]], [[38.5, -120.2], [38.51, -120.21]]]
        ])) { selected = $0 as? Int }
        precondition(selected == 2, "Empty routes must not crash or shift the original route index")
        print("PASS: malformed and empty route-selection geometry cannot crash native code")

        let messenger = RetainingMessenger()
        for id in 1...20 {
            weak var released: EmbeddedNavigationView?
            autoreleasepool {
                var view: EmbeddedNavigationView? = EmbeddedNavigationView(
                    messenger: messenger, frame: .zero, viewId: Int64(id), args: nil)
                released = view
                view!.onMethodCall(methodCall: FlutterMethodCall(methodName: "stopNavigation", arguments: nil)) { _ in }
                view = nil
            }
            precondition(released == nil, "Event handler retained a disposed navigation view")
            precondition(messenger.handlers.isEmpty, "Channel handlers were not removed")
        }
        print("PASS: 20 native embedded views release their handlers and deallocate")

        let modal = ModalPreviewNavigationController(rootViewController: UIViewController())
        modal.loadViewIfNeeded()
        modal.beginAppearanceTransition(true, animated: false)
        modal.endAppearanceTransition()
        let close = modal.topViewController!.navigationItem.leftBarButtonItem!
        precondition(close.target === modal && modal.responds(to: close.action))
        print("PASS: modal preview supplies a container-owned close action")
    }
}

/// Models Flutter's strong retention of registered stream handlers.
private final class RetainingMessenger: NSObject, FlutterBinaryMessenger {
    var handlers: [String: FlutterBinaryMessageHandler] = [:]
    private var channels: [FlutterBinaryMessengerConnection: String] = [:]
    private var sequence: FlutterBinaryMessengerConnection = 0

    func send(onChannel channel: String, message: Data?) {}
    func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
        callback?(nil)
    }
    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
        sequence += 1
        handlers[channel] = handler
        channels[sequence] = channel
        return sequence
    }
    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {
        if let channel = channels.removeValue(forKey: connection) { handlers.removeValue(forKey: channel) }
    }
}
