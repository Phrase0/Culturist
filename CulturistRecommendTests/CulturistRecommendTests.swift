//
//  CulturistRecommendTests.swift
//  CulturistRecommendTests
//
//  Created by Peiyun on 2023/10/22.
//

import XCTest
@testable import Culturist
final class CulturistRecommendTests: XCTestCase {
    
    var sut: RecommendCollectionViewCell!
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = RecommendCollectionViewCell()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testSetFontWithValidFont() {
        // Arrange
        let label = UILabel()
        let size: CGFloat = 16.0
        // Act
        sut.setFont(productName: label, size: size)
        
        // Assert
        XCTAssertEqual(label.numberOfLines, 1)
        XCTAssertEqual(label.textAlignment, .center)
        XCTAssertEqual(label.font, UIFont(name: "PingFangTC-Regular", size: size))
    }

    func testSetFontWithCorrectFontNameParameter() {
        // Arrange
        let label = UILabel()
        let size: CGFloat = 16.0
        let expectedFontName = "PingFangTC-Regular"
        
        // Act
        sut.setFont(productName: label, size: size)
        
        // Assert
        XCTAssertEqual(label.font?.fontName, expectedFontName)
    }
    
    func testSetFontWithCorrectSizeParameter() {
        // Arrange
        let label = UILabel()
        let size: CGFloat = 16.0
        
        // Act
        sut.setFont(productName: label, size: size)
        
        // Assert
        XCTAssertEqual(label.font?.pointSize, size)
    }
    
    func testSetFontSetsNumberOfLinesAndTextAlignment() {
        // Arrange
        let label = UILabel()
        let size: CGFloat = 16.0
        
        // Act
        sut.setFont(productName: label, size: size)
        
        // Assert
        XCTAssertEqual(label.numberOfLines, 1)
        XCTAssertEqual(label.textAlignment, .center)
    }
}
