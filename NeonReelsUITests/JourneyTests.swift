import XCTest

@MainActor final class JourneyTests: XCTestCase {
    func tab(_ name:String, app:XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format:"label == %@",name)).firstMatch
    }
    func capture(_ name:String) {
        let a=XCTAttachment(screenshot:XCUIScreen.main.screenshot());a.name=name;a.lifetime = .keepAlways;add(a)
    }
    func testCompleteUndoResumeAndExplore() {
        let app=XCUIApplication();app.launchArguments=["--uitest-reset", "-ReviewScreen"];app.launch()
        XCTAssertTrue(app.buttons["continue-puzzle"].waitForExistence(timeout:15));capture("01-hall")
        app.buttons["continue-puzzle"].tap()
        XCTAssertTrue(app.buttons["reel-0-up"].waitForExistence(timeout:5));capture("02-puzzle")
        app.buttons["reel-0-up"].tap();app.buttons["undo"].tap()
        XCTAssertTrue(app.staticTexts["move-count"].label.contains("0 /"))
        app.buttons["reel-0-up"].tap();app.buttons["hint"].tap();capture("03-hint")
        app.terminate();app.launchArguments=["-ReviewScreen"];app.launch()
        app.buttons["continue-puzzle"].tap()
        XCTAssertTrue(app.staticTexts["move-count"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["move-count"].label.contains("1 /"),app.staticTexts["move-count"].label)
        app.buttons["reel-0-up"].tap();app.buttons["check"].tap()
        XCTAssertTrue(app.staticTexts["Brilliant move."].waitForExistence(timeout:5));capture("04-result")
        app.swipeUp();app.buttons["result-close"].tap()
        XCTAssertTrue(tab("Album",app:app).waitForExistence(timeout:5));tab("Album",app:app).tap();capture("05-album")
        app.buttons["album-1"].tap();XCTAssertTrue(app.buttons["Back to album"].waitForExistence(timeout:5));capture("06-symbol");app.buttons["Back to album"].tap()
        tab("Daily",app:app).tap();capture("07-daily");app.buttons["play-daily"].tap()
        XCTAssertTrue(app.buttons["hint"].waitForExistence(timeout:5));capture("08-daily-play")
        for _ in 0..<10 {
            app.buttons["hint"].tap()
            let message=app.staticTexts["game-message"].label
            if message.contains("target is matched") { break }
            let words=message.components(separatedBy:" ")
            guard let reelWord=words.firstIndex(of:"Reel"), words.count>reelWord+2,
                  let number=Int(words[reelWord+1]) else { XCTFail("Missing actionable hint: \(message)");break }
            let direction=words[reelWord+2].hasPrefix("up") ? "up" : "down"
            app.buttons["reel-\(number-1)-\(direction)"].tap()
        }
        app.buttons["check"].tap()
        XCTAssertTrue(app.staticTexts["Brilliant move."].waitForExistence(timeout:5));capture("08b-daily-result")
        app.swipeUp();app.buttons["result-close"].tap();app.swipeUp();app.swipeUp();capture("08c-daily-history")
        tab("Settings",app:app).tap();capture("09-settings")
        tab("Play",app:app).tap();app.swipeUp();app.buttons["room-1"].tap()
        XCTAssertTrue(app.buttons["play-selected"].waitForExistence(timeout:5));capture("10-levels")
        app.buttons["play-selected"].tap();XCTAssertTrue(app.buttons["reel-0-up"].waitForExistence(timeout:5));app.buttons["reel-0-up"].tap();capture("11-linked")
        XCUIDevice.shared.orientation = .landscapeLeft
        waitForLandscape(app)
        XCTAssertTrue(app.buttons["reel-0-up"].exists);capture("11b-landscape")
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval:1)
    }
    func waitForLandscape(_ app:XCUIApplication) {
        let rotated=XCTNSPredicateExpectation(predicate:NSPredicate { _,_ in app.frame.width > app.frame.height },object:nil)
        XCTAssertEqual(XCTWaiter.wait(for:[rotated],timeout:10),.completed)
        Thread.sleep(forTimeInterval:1)
    }
    func testLandscapeSettled() {
        let app=XCUIApplication();app.launchArguments=["--uitest-reset", "-ReviewScreen"];app.launch()
        XCTAssertTrue(app.buttons["continue-puzzle"].waitForExistence(timeout:15));app.buttons["continue-puzzle"].tap()
        XCTAssertTrue(app.buttons["reel-0-up"].waitForExistence(timeout:5))
        app.descendants(matching:.any).matching(identifier:"reel-0").firstMatch.swipeUp()
        XCTAssertTrue(app.staticTexts["move-count"].label.contains("1 /"),app.staticTexts["move-count"].label)
        app.buttons["undo"].tap()
        XCTAssertTrue(app.staticTexts["move-count"].label.contains("0 /"))
        XCUIDevice.shared.orientation = .landscapeLeft;waitForLandscape(app)
        app.swipeUp();capture("13-landscape-settled")
        app.buttons["reel-0-up"].tap();app.buttons["reel-0-down"].tap()
        XCUIDevice.shared.orientation = .portrait;Thread.sleep(forTimeInterval:1)
        capture("14-portrait-return")
    }
    func testLimitRetryAndCheckMismatch() {
        let app=XCUIApplication();app.launchArguments=["--uitest-reset", "-ReviewScreen"];app.launch()
        XCTAssertTrue(app.buttons["continue-puzzle"].waitForExistence(timeout:15));app.buttons["continue-puzzle"].tap()
        app.buttons["check"].tap();XCTAssertTrue(app.staticTexts["game-message"].label.contains("Not matched"))
        for _ in 0..<5 { app.buttons["reel-1-up"].tap() }
        XCTAssertFalse(app.buttons["reel-1-up"].isEnabled)
        app.buttons["check"].tap();XCTAssertTrue(app.staticTexts["Try a fresh approach."].waitForExistence(timeout:5));capture("12-limit")
        app.swipeUp();app.buttons["retry-result"].tap()
        XCTAssertTrue(app.buttons["reel-1-up"].waitForExistence(timeout:5));XCTAssertTrue(app.buttons["reel-1-up"].isEnabled)
        XCTAssertTrue(app.staticTexts["move-count"].label.contains("0 /"))
    }
}
