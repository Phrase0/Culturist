//
//  CulturistAPITests.swift
//  CulturistAPITests
//
//  Created by Peiyun on 2023/10/22.
//

import XCTest
import EventKit
@testable import Culturist

final class CulturistDateFormatTests: XCTestCase {

    var sut: DetailViewController!
    var dateFormatter: DateFormatter!
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DetailViewController()
        dateFormatter = DateFormatter()
    }

    override func tearDownWithError() throws {
        sut = nil
        dateFormatter = nil
        try super.tearDownWithError()
    }

    func testChangeDateFormatterWithValidDateString() {
        // Arrange
        let dateString = "2023/10/22 14:30:00"

        // Act
        let date = sut.changeDateFormatter(dateString: dateString)

        // Assert
        XCTAssertNotNil(date)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!)
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 22)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
        XCTAssertEqual(components.second, 0)
    }

    func testChangeDateFormatterWithNilDateString() {
        // Arrange
        let dateString: String? = nil
        // Act
        let date = sut.changeDateFormatter(dateString: dateString)

        // Assert
        XCTAssertNil(date)
    }

    func testChangeDateFormatterWithInvalidDateString() {
        // Arrange
        let dateString = "InvalidDateString"

        // Act
        let date = sut.changeDateFormatter(dateString: dateString)

        // Assert
        XCTAssertNil(date)
    }
}
