//
//  ContentBlockerTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

class ContentBlockerTests: XCTestCase {
    
    struct TrackerPageUrl {
        static let noTrackers = "http://localhost:8000/notrackers.html"
        static let iFrames = "http://localhost:8000/iframetrackers.html"
        static let resources = "http://localhost:8000/resourcetrackers.html"
        static let requests = "http://localhost:8000/requesttrackers.html"
    }
    
    struct PageElementIndex {
        static let uniqueTrackerCount = 2
    }
    
    struct Timeout {
        static let postFirstLaunch: UInt32 = 10
        static let pageLoad: UInt32 = 5
    }
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        skipOnboarding()
        clearTabsAndData()
        continueAfterFailure = true
    }

    func testThatNothingIsBlockedOnCleanPage() {
        checkContentBlocking(onTestPage: TrackerPageUrl.noTrackers)
    }

    func testThatIFramesAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.iFrames)
    }
    
    func testThatResourcesAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.resources)
    }
    
    func testThatRequestsAreBlocked() {
        checkContentBlocking(onTestPage: TrackerPageUrl.requests)
    }
    
    func checkContentBlocking(onTestPage url: String, file: StaticString = #file, line: UInt = #line) {
        
        newTab()
        
        enterSearch(url)
        
        waitForPageLoad()

        let webTrackerCount = app.webViews.staticTexts.element(boundBy: PageElementIndex.uniqueTrackerCount).label + " Tracker Networks Blocked"

        openContentBlocker()
        
        let popoverTrackerCount = app.tables.staticTexts["trackerCount"].label

        XCTAssertEqual(popoverTrackerCount, webTrackerCount, file: file, line: line)
    }

    private func showTabs() {
        app.toolbars.buttons["Tabs Button"].tap()
    }
    
    private func addTab() {
        app.toolbars.buttons["Add"].tap()
    }
    
    private func newTab() {
        showTabs()
        addTab()
    }
    
    private func skipOnboarding() {
        guard app.staticTexts["Search Anonymously"].exists else { return }
        app.pageIndicators["page 1 of 2"].tap()
        app.buttons["Done"].tap()
        sleep(Timeout.postFirstLaunch)
    }
    
    private func clearTabsAndData() {
        app.toolbars.buttons["Fire"].tap()
        app.sheets.buttons["Clear Tabs and Data"].tap()
    }
    
    private func enterSearch(_ text: String, submit: Bool = true) {
        print("enterSearch text:", text, "submit:", submit)
        
        let searchOrTypeUrlTextField = app.textFields["Search or type URL"]
        searchOrTypeUrlTextField.typeText(text)
        
        if submit {
            searchOrTypeUrlTextField.typeText("\n")
        }
    }
    
    private func waitForPageLoad() {
        sleep(Timeout.pageLoad)
    }
    
    private func openContentBlocker() {
        app.otherElements["siteRating"].tap()
    }
}

