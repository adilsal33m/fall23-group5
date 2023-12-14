import XCTest
@testable import ARPersistence

class ScanDataTests: XCTestCase {

		func testScanDataInitialization() {
				// Given
				let content = "Test Content"
				
				// When
				let scanData = ScanData(content: content)
				
				// Then
				XCTAssertNotNil(scanData.id, "ID should not be nil after initialization.")
				XCTAssertEqual(scanData.content, content, "Content should be set correctly in init.")
		}
		
		func testScanDataIdIsUnique() {
				// Given
				let scanData1 = ScanData(content: "Content 1")
				let scanData2 = ScanData(content: "Content 2")
				
				// When
				let areIdsUnique = scanData1.id != scanData2.id
				
				// Then
				XCTAssertTrue(areIdsUnique, "Each ScanData instance should have a unique ID.")
		}
}
