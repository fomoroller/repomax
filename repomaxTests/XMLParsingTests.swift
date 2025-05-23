import XCTest
@testable import repomax

class XMLParsingTests: XCTestCase {
    var appState: AppState!
    
    override func setUp() {
        super.setUp()
        appState = AppState()
    }
    
    override func tearDown() {
        appState = nil
        super.tearDown()
    }
    
    func testParseXMLWithModifyAction() {
        // Given
        let xmlInput = """
        <Plan>
        We are adding a new method "power" to the SimpleCalculator class in /folder 1/file1.py. This method will raise the current value to the power of a given argument and return the updated value. We use a "modify" action to insert the new method immediately after the existing "divide" method.
        </Plan>

        <file path="/folder 1/file1.py" action="modify">
          <change>
            <description>Add "power" method to the SimpleCalculator class</description>
            <search>
        ===
            def divide(self, x):
                if x == 0:
                    raise ValueError("Cannot divide by zero")
                self.value /= x
                return self.value
        ===
            </search>
            <content>
        ===
            def divide(self, x):
                if x == 0:
                    raise ValueError("Cannot divide by zero")
                self.value /= x
                return self.value

            def power(self, x):
                """
                Raise the current value to the power of x.
                """
                self.value **= x
                return self.value
        ===
            </content>
          </change>
        </file>
        """
        
        // When
        appState.aiResponseText = xmlInput
        appState.applyChanges()
        
        // Then
        XCTAssertFalse(appState.pendingChanges.isEmpty, "Should have found changes to apply")
        XCTAssertEqual(appState.pendingChanges.count, 1, "Should have exactly one change")
        
        if let change = appState.pendingChanges.first {
            XCTAssertEqual(change.filePath, "/folder 1/file1.py", "File path should match")
            XCTAssertEqual(change.changeType, .modify, "Change type should be modify")
            XCTAssertTrue(change.newContent.contains("def power(self, x):"), "New content should contain the power method")
            XCTAssertTrue(appState.showMergeModal, "Merge modal should be shown")
        }
    }
} 