//
//  MarinTraceUITests.swift
//  MarinTraceUITests
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import XCTest
import M13Checkbox

class MarinTraceUITests: XCTestCase {
    
    var symptoms = ["Fever or chills", "Cough", "Shortness of breath", "Difficulty breathing", "Fatigue", "Muscle or body aches", "Headache", "New loss of taste or smell", "Sore throat", "Congestion or runny nose", "Nausea or vomiting", "Diarrhea"]
    var screeners = ["I have been outside the state in the last 14 days", "I have been in contact with someone who has tested positive within the last 14 days"]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /*func cellForText(tables: XCUIElementQuery, text:String) -> XCUIElementQuery {
        return tables.cells.containing(.staticText, identifier:text)
    }
    
    func executeTaps(app: XCUIApplication, labelTexts: [String]) {
        for text in labelTexts {
            print(app.checkBoxes)
            print(app.buttons)
            print(app.otherElements)
            print(app.radioButtons)

            let checkbox = app.checkBoxes[text]
            print(checkbox.debugDescription)
            checkbox.tap()
        }
    }

    //test checking and unchecking all
    func testQuestionnaire1() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let tablesQuery = app.tables
        print(tablesQuery.debugDescription)
        
        //open questionnaire
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Open Questionnaire"]/*[[".cells",".buttons[\"Open Questionnaire\"].staticTexts[\"Open Questionnaire\"]",".staticTexts[\"Open Questionnaire\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
                
        //check all
        let cells = screeners + symptoms
        executeTaps(app: app, labelTexts: cells)
        
        sleep(5)
        app.navigationBars["Daily Report"].buttons["Submit"].tap()
        
        XCTAssert((cellForText(tables: tablesQuery, text: cells[0]).checkbox as! M13Checkbox).checkState == .checked)
        
        
        
        
       /* let tablesQuery = XCUIApplication().tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["I have been in contact with someone who has tested positive within the last 14 days"]/*[[".cells.staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]",".staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["I have been outside the state in the last 14 days"]/*[[".cells.staticTexts[\"I have been outside the state in the last 14 days\"]",".staticTexts[\"I have been outside the state in the last 14 days\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fever or chills"]/*[[".cells.staticTexts[\"Fever or chills\"]",".staticTexts[\"Fever or chills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()*/
        
        
        
        
        
        
        
        /*let iHaveBeenOutsideTheStateInTheLast14DaysStaticText = tablesQuery.staticTexts["I have been outside the state in the last 14 days"]
        iHaveBeenOutsideTheStateInTheLast14DaysStaticText.tap()
        
        let iHaveBeenInContact = tablesQuery.staticTexts["I have been in contact with someone who has tested positive within the last 14 days"]
        iHaveBeenInContact.tap()
        
        let feverOrChillsStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fever or chills"]/*[[".cells.staticTexts[\"Fever or chills\"]",".staticTexts[\"Fever or chills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        feverOrChillsStaticText.tap()
        
        let coughStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Cough"]/*[[".cells.staticTexts[\"Cough\"]",".staticTexts[\"Cough\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        coughStaticText.tap()
        
        coughStaticText.swipeUp()
        
        let shortnessOfBreathStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Shortness of breath"]/*[[".cells.staticTexts[\"Shortness of breath\"]",".staticTexts[\"Shortness of breath\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        shortnessOfBreathStaticText.tap()

        let difficultyBreathingStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Difficulty breathing"]/*[[".cells.staticTexts[\"Difficulty breathing\"]",".staticTexts[\"Difficulty breathing\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        difficultyBreathingStaticText.tap()
        
        let fatigueStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fatigue"]/*[[".cells.staticTexts[\"Fatigue\"]",".staticTexts[\"Fatigue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        fatigueStaticText.tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["I have been in contact with someone who has tested positive within the last 14 days"]/*[[".cells.staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]",".staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.cells.containing(.staticText, identifier:"I have been in contact with someone who has tested positive within the last 14 days").children(matching: .other).element(boundBy: 1).tap()
        
        let feverOrChillsStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fever or chills"]/*[[".cells.staticTexts[\"Fever or chills\"]",".staticTexts[\"Fever or chills\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        feverOrChillsStaticText.swipeUp()
        
        let coughStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Cough"]/*[[".cells.staticTexts[\"Cough\"]",".staticTexts[\"Cough\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        coughStaticText.swipeUp()
        feverOrChillsStaticText.tap()
        feverOrChillsStaticText.tap()
        coughStaticText.tap()
        coughStaticText.tap()
        
        let shortnessOfBreathStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Shortness of breath"]/*[[".cells.staticTexts[\"Shortness of breath\"]",".staticTexts[\"Shortness of breath\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        shortnessOfBreathStaticText.tap()
        shortnessOfBreathStaticText.tap()
        
        let difficultyBreathingStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Difficulty breathing"]/*[[".cells.staticTexts[\"Difficulty breathing\"]",".staticTexts[\"Difficulty breathing\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        difficultyBreathingStaticText.tap()
        difficultyBreathingStaticText.tap()
        
        let fatigueStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fatigue"]/*[[".cells.staticTexts[\"Fatigue\"]",".staticTexts[\"Fatigue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        fatigueStaticText.tap()
        fatigueStaticText.tap()
        
        let cellsQuery = tablesQuery.cells
        let element = cellsQuery.otherElements.containing(.staticText, identifier:"Muscle or body aches").children(matching: .other).element
        element.tap()
        element.tap()
        
        let headacheStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Headache"]/*[[".cells.staticTexts[\"Headache\"]",".staticTexts[\"Headache\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        headacheStaticText.tap()
        headacheStaticText.tap()
        
        let element2 = cellsQuery.otherElements.containing(.staticText, identifier:"New loss of taste or smell").children(matching: .other).element
        element2.tap()
        element2.tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"New loss of taste or smell").element.swipeUp()
        
        let soreThroatStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Sore throat"]/*[[".cells.staticTexts[\"Sore throat\"]",".staticTexts[\"Sore throat\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        soreThroatStaticText.tap()
        soreThroatStaticText.tap()
        
        let element3 = cellsQuery.otherElements.containing(.staticText, identifier:"Congestion or runny nose").children(matching: .other).element
        element3.tap()
        element3.tap()
        
        let nauseaOrVomitingStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Nausea or vomiting"]/*[[".cells.staticTexts[\"Nausea or vomiting\"]",".staticTexts[\"Nausea or vomiting\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        nauseaOrVomitingStaticText.tap()
        nauseaOrVomitingStaticText.tap()
        
        let element4 = cellsQuery.otherElements.containing(.staticText, identifier:"Diarrhea").children(matching: .other).element
        element4.tap()
        element4.tap()
        app.navigationBars["Daily Report"].buttons["Submit"].tap()
        app.launch()*/
        
        /*let tablesQuery = XCUIApplication().tables
        
        let iHaveBeenOutsideTheStateInTheLast14DaysStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["I have been outside the state in the last 14 days"]/*[[".cells.staticTexts[\"I have been outside the state in the last 14 days\"]",".staticTexts[\"I have been outside the state in the last 14 days\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        iHaveBeenOutsideTheStateInTheLast14DaysStaticText.tap()
        iHaveBeenOutsideTheStateInTheLast14DaysStaticText.tap()
        tablesQuery.children(matching: .other).element(boundBy: 0).swipeUp()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Sore throat"]/*[[".cells.staticTexts[\"Sore throat\"]",".staticTexts[\"Sore throat\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Nausea or vomiting"]/*[[".cells.staticTexts[\"Nausea or vomiting\"]",".staticTexts[\"Nausea or vomiting\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let cellsQuery = tablesQuery.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"New loss of taste or smell").children(matching: .other).element.tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Muscle or body aches").children(matching: .other).element.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Shortness of breath"]/*[[".cells.staticTexts[\"Shortness of breath\"]",".staticTexts[\"Shortness of breath\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["I have been in contact with someone who has tested positive within the last 14 days"]/*[[".cells.staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]",".staticTexts[\"I have been in contact with someone who has tested positive within the last 14 days\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Cough"]/*[[".cells.staticTexts[\"Cough\"]",".staticTexts[\"Cough\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Fatigue"]/*[[".cells.staticTexts[\"Fatigue\"]",".staticTexts[\"Fatigue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Headache"]/*[[".cells.staticTexts[\"Headache\"]",".staticTexts[\"Headache\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"New loss of taste or smell").element.swipeUp()
        cellsQuery.otherElements.containing(.staticText, identifier:"Congestion or runny nose").children(matching: .other).element.tap()*/
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }*/

    /*func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }*/
}

extension XCUIElementQuery {
    var checkbox: XCUIElement {
        return self.children(matching: .other).element(boundBy: 1)
    }
}
