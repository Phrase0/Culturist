//
//  CulturistTimeTests.swift
//  CulturistTimeTests
//
//  Created by Peiyun on 2023/10/22.
//

import XCTest
@testable import Culturist
final class CulturistTimeTests: XCTestCase {

    var sut: DetailViewController!

    override func setUpWithError() throws {
      try super.setUpWithError()
      sut = DetailViewController()
    }

    override func tearDownWithError() throws {
      sut = nil
      try super.tearDownWithError()
    }
    func testFormatTimeWithValidInput() {
        // Arrange
        let inputTime = "12:34"
        
        // Act
        let formattedTime = sut.formatTime(inputTime)
        
        // Assert
        XCTAssertEqual(formattedTime, "12:34")
    }
    
    func testFormatTimeWithInvalidInput() {
        // Arrange
        let inputTime: String? = nil
        
        // Act
        let formattedTime = sut.formatTime(inputTime)
        
        // Assert
        XCTAssertNil(formattedTime)
    }

    func testFormatTimeWithInvalidInputSeconds() {
        // Arrange
        let inputTime = "12:34:00"
        
        // Act
        let formattedTime = sut.formatTime(inputTime)
        
        // Assert
        XCTAssertEqual(formattedTime, "12:34")
    }

}
