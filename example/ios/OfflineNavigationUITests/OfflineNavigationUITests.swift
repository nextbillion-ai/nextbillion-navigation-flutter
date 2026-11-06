import CoreLocation
import XCTest

/// Drives real downloads, process launches, system connectivity and SDK routing.
/// Location is supplied through XCTest's system GPS input, never plugin callbacks.
/// Run permission-alert checks on a device whose system language is English.
@available(iOS 16.4, *)
final class OfflineNavigationUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "ai.nextbillion.navigation.nbNavigationFlutterExample")
    private let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
    private var originalAirplane: Bool?
    private var originalWifi: Bool?

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment["OFFLINE_ACCEPTANCE_UI_TEST"] = "1"
        addUIInterruptionMonitor(withDescription: "System permissions") { alert in
            for title in ["Allow While Using App", "Allow", "OK"] {
                let button = alert.buttons[title]
                if button.exists { button.tap(); return true }
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.location = nil
        if let wifi = originalWifi { try? setWifi(wifi) }
        if let airplane = originalAirplane { try? setAirplane(airplane) }
        app.activate()
    }

    func testDisconnectedColdStartAndReroute() throws {
        launch("prepare")
        try wait(["PREPARE_OK"], timeout: 1000)
        let fixtureElement = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", "FIXTURE:")).firstMatch
        XCTAssertTrue(fixtureElement.waitForExistence(timeout: 10))
        let data = Data(fixtureElement.label.dropFirst("FIXTURE:".count).utf8)
        let fixture = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let track = try XCTUnwrap(fixture["track"] as? [[Double]])
        XCTAssertGreaterThan(track.count, 5)
        let initialPid = pidLabel()

        openSettingsRoot()
        let airplane = try airplaneSwitch()
        originalAirplane = airplane.value as? String == "1"
        try readWifi()
        try setAirplane(true)
        try setWifi(false)
        launch("offline")
        try wait(["OFFLINE_OK"], timeout: 160)
        XCTAssertNotEqual(pidLabel(), initialPid, "Must launch a different OS process without reinstalling")
        attach("Disconnected route and map")

        launch("offline")
        XCTAssertNotEqual(pidLabel(), initialPid, "Must launch a different OS process without reinstalling")
        try wait(["OFFLINE_OK"], timeout: 160)
        attach("Cold start with no network")

        try navigate(track, phase: "full", success: "FULL_OK")
        try navigate(track, phase: "embedded", success: "EMBEDDED_OK")
        launch("cleanup")
        try wait(["CLEANUP_OK"], timeout: 180)
        attach("Acceptance complete")
    }

    private func navigate(_ track: [[Double]], phase: String, success: String) throws {
        inject(track, index: 0)
        launch(phase)
        sleep(3)
        for index in track.indices {
            inject(track, index: index)
            if app.staticTexts[success].exists { attach(success); return }
            handleAlert()
            Thread.sleep(forTimeInterval: 1)
        }
        try wait([success], timeout: 70)
        attach(success)
    }

    private func launch(_ phase: String) {
        app.terminate()
        app.launchEnvironment["OFFLINE_ACCEPTANCE_PHASE"] = phase
        app.launch()
    }

    private func inject(_ track: [[Double]], index: Int) {
        let p = track[index], next = track[min(index + 1, track.count - 1)]
        let radians = Double.pi / 180
        let y = sin((next[1] - p[1]) * radians) * cos(next[0] * radians)
        let x = cos(p[0] * radians) * sin(next[0] * radians) - sin(p[0] * radians) * cos(next[0] * radians) * cos((next[1] - p[1]) * radians)
        let course = (atan2(y, x) / radians + 360).truncatingRemainder(dividingBy: 360)
        XCUIDevice.shared.location = XCUILocation(location: CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: p[0], longitude: p[1]), altitude: 20,
            horizontalAccuracy: 5, verticalAccuracy: 5, course: course, speed: 20, timestamp: Date()))
    }

    private func wait(_ values: [String], timeout: TimeInterval) throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if values.contains(where: { app.staticTexts[$0].exists }) { return }
            let failure = app.staticTexts.matching(NSPredicate(format: "label ENDSWITH %@", "_FAILED")).firstMatch
            if failure.exists { XCTFail("\(failure.label)\n\(app.debugDescription)"); return }
            handleAlert()
            Thread.sleep(forTimeInterval: 1)
        }
        XCTFail("Timed out waiting for \(values)\n\(app.debugDescription)")
    }

    private func pidLabel() -> String {
        app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "PID:")).firstMatch.label
    }

    private func handleAlert() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for owner in [app, springboard] where owner.alerts.firstMatch.exists {
            let alert = owner.alerts.firstMatch
            for title in ["Allow While Using App", "Allow", "OK"] {
                if alert.buttons[title].exists { alert.buttons[title].tap(); break }
            }
        }
    }

    private func airplaneSwitch() throws -> XCUIElement {
        let value = settings.switches["com.apple.settings.airplaneMode"]
        XCTAssertTrue(value.waitForExistence(timeout: 15), settings.debugDescription)
        return value
    }

    private func setAirplane(_ enabled: Bool) throws {
        openSettingsRoot()
        let value = try airplaneSwitch()
        if (value.value as? String == "1") != enabled { value.tap() }
    }

    private func openWifi() throws -> XCUIElement {
        openSettingsRoot()
        let row = settings.buttons["com.apple.settings.wifi"]
        XCTAssertTrue(row.waitForExistence(timeout: 15), settings.debugDescription)
        row.tap()
        let value = settings.switches.firstMatch
        XCTAssertTrue(value.waitForExistence(timeout: 15), settings.debugDescription)
        return value
    }

    private func readWifi() throws { originalWifi = try openWifi().value as? String == "1" }
    private func setWifi(_ enabled: Bool) throws {
        let value = try openWifi()
        if (value.value as? String == "1") != enabled { value.tap() }
    }
    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    private func openSettingsRoot() {
        settings.activate()
        for _ in 0..<5 {
            let airplane = settings.switches["com.apple.settings.airplaneMode"]
            if airplane.exists { return }
            let back = settings.navigationBars.buttons.firstMatch
            if back.exists { back.tap() } else { break }
        }
    }
}
