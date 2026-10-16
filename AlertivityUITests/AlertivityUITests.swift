import XCTest

final class AlertivityUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndStaysActive() {
        let app = launchApp()
        app.launch()

        // Menu-bar apps often remain background; just ensure they leave the notRunning state.
        let deadline = Date().addingTimeInterval(8)
        var isRunning = false
        repeat {
            if app.state != .notRunning {
                isRunning = true
                break
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        XCTAssertTrue(isRunning, "App should be launched (foreground or background)")
    }

    func testOnboardingCompletionAndReplay() {
        let app = launchApp()
        app.launch()
        let next = app.buttons["onboarding.next"]
        XCTAssertTrue(next.waitForExistence(timeout: 8))
        XCTAssertTrue(app.popUpButtons["onboarding.previewStyle"].waitForExistence(timeout: 3))
        saveWelcomeScreenshot(app)
        let previewStyle = app.popUpButtons["onboarding.previewStyle"]
        previewStyle.click()
        app.menuItems["CPU usage"].click()
        XCTAssertEqual(previewStyle.value as? String, "CPU usage")
        saveWelcomeScreenshot(app)
        let moreOptions = app.descendants(matching: .disclosureTriangle)["onboarding.moreOptions"]
        XCTAssertTrue(moreOptions.waitForExistence(timeout: 3))
        moreOptions.click()
        let autoSwitch = app.checkBoxes["onboarding.autoSwitch"]
        XCTAssertTrue(autoSwitch.waitForExistence(timeout: 3))
        XCTAssertTrue(checkboxIsOn(autoSwitch))
        autoSwitch.click()
        XCTAssertFalse(checkboxIsOn(autoSwitch))
        saveWelcomeScreenshot(app)
        next.click()
        XCTAssertTrue(app.staticTexts["onboarding.notificationStatus"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.checkBoxes["onboarding.autoSwitch"].exists)
        saveWelcomeScreenshot(app)
        next.click()
        XCTAssertTrue(next.waitForNonExistence(timeout: 3))

        // The same suite survives this launch; first-run presentation must stay suppressed.
        app.terminate()
        app.launchArguments.append("UITestsPreserveDefaults")
        app.launch()
        XCTAssertFalse(next.waitForExistence(timeout: 3))
        app.typeKey(",", modifierFlags: .command)
        let menuBar = app.buttons["Menu Bar"]
        XCTAssertTrue(menuBar.waitForExistence(timeout: 5))
        menuBar.click()
        XCTAssertEqual(app.popUpButtons["waveform.path.ecg"].value as? String, "Status icon")
        let savedAutoSwitch = app.checkBoxes["Auto switch to busiest metric"]
        XCTAssertTrue(savedAutoSwitch.exists)
        XCTAssertFalse(checkboxIsOn(savedAutoSwitch))
        let indicator = app.descendants(matching: .statusItem).firstMatch
        let showIndicator = app.checkBoxes["Show indicator"]
        showIndicator.click()
        XCTAssertTrue(indicator.waitForNonExistence(timeout: 3))
        showIndicator.click()
        XCTAssertTrue(indicator.waitForExistence(timeout: 3))
        let general = app.buttons["General"]
        XCTAssertTrue(general.waitForExistence(timeout: 5))
        general.click()
        XCTAssertFalse(app.buttons["onboarding.open"].exists)

        // Optional guidance belongs in Help, separate from app preferences.
        app.menuBars.menuBarItems["Help"].click()
        let menuLink = app.menuItems["Getting Started…"]
        XCTAssertTrue(menuLink.waitForExistence(timeout: 3))
        menuLink.click()
        XCTAssertTrue(next.waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["onboarding.step"].value as? String, "Step 1 of 2")
        app.buttons["onboarding.skip"].click()
    }

    func testApplyingPreviewStyleIsExplicitAndPersists() {
        let app = launchApp()
        app.launch()
        let picker = app.popUpButtons["onboarding.previewStyle"]
        XCTAssertTrue(picker.waitForExistence(timeout: 8))
        let apply = app.buttons["onboarding.applyStyle"]
        XCTAssertFalse(apply.isEnabled)
        picker.click()
        app.menuItems["Network throughput"].click()
        XCTAssertTrue(apply.isEnabled)
        apply.click()
        XCTAssertFalse(apply.isEnabled)
        // Continue and Done must not apply a subsequent exploratory selection.
        picker.click()
        app.menuItems["CPU usage"].click()
        app.buttons["onboarding.next"].click()
        app.buttons["onboarding.next"].click()
        app.terminate()
        app.launchArguments.append("UITestsPreserveDefaults")
        app.launch()
        app.typeKey(",", modifierFlags: .command)
        let menuBar = app.buttons["Menu Bar"]
        XCTAssertTrue(menuBar.waitForExistence(timeout: 5))
        menuBar.click()
        XCTAssertTrue(app.popUpButtons["arrow.up.arrow.down"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.popUpButtons["arrow.up.arrow.down"].value as? String, "Network throughput")
        app.menuBars.menuBarItems["Help"].click()
        app.menuItems["Getting Started…"].click()
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        XCTAssertEqual(picker.value as? String, "Network throughput")
        picker.click()
        app.menuItems["CPU usage"].click()
        app.buttons["onboarding.skip"].click()
        app.menuBars.menuBarItems["Help"].click()
        app.menuItems["Getting Started…"].click()
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        XCTAssertEqual(picker.value as? String, "Network throughput")
    }

    func testSkippingAndClosingSuppressFuturePresentation() {
        for closeWindow in [false, true] {
            let app = launchApp()
            app.launch()
            let next = app.buttons["onboarding.next"]
            XCTAssertTrue(next.waitForExistence(timeout: 8))
            if closeWindow {
                app.windows.containing(.button, identifier: "onboarding.next").firstMatch
                    .buttons[XCUIIdentifierCloseWindow].click()
            } else {
                app.buttons["onboarding.skip"].click()
            }
            XCTAssertTrue(next.waitForNonExistence(timeout: 3))
            app.terminate()
            app.launchArguments.append("UITestsPreserveDefaults")
            app.launch()
            XCTAssertFalse(next.waitForExistence(timeout: 3))
            app.terminate()
        }
    }

    private func checkboxIsOn(_ checkbox: XCUIElement) -> Bool {
        // Native macOS and SwiftUI controls can expose NSNumber or string accessibility values.
        if let value = checkbox.value as? NSNumber { return value.boolValue }
        return checkbox.value as? String == "1"
    }

    private func saveWelcomeScreenshot(_ app: XCUIApplication) {
        // Window captures can fail on secondary displays. Functional checks must not depend on capture support.
        guard ProcessInfo.processInfo.environment["ALERTIVITY_CAPTURE_ONBOARDING"] == "1" else { return }
        let window = app.windows.containing(.button, identifier: "onboarding.next").firstMatch
        let screenshot = window.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["UITests", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        return app
    }

    private func selectMenuValue(in popup: XCUIElement, value: String) {
        guard popup.waitForExistence(timeout: 2) else { return }
        popup.click()

        let menuItem = popup.menuItems[value]
        if menuItem.waitForExistence(timeout: 2) {
            menuItem.click()
        }
    }
}
