//
//  CulturistSearchTests.swift
//  CulturistSearchTests
//
//  Created by Peiyun on 2023/10/22.
//

import XCTest
@testable import Culturist
final class CulturistSearchTests: XCTestCase {

    var sut: SearchViewController!
   
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SearchViewController()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testFilterContentWithSearchTextInTitle() {
        // Arrange
        let searchText = "舒伯特"
        
        // Create mock ArtDatum objects
        let fakeArtData1 = ArtDatum(
            uid: "1",
            title: "舒伯特：五重奏",
            category: "6",
            showInfo: [
                ShowInfo(
                    time: "2023-10-10 19:00:00",
                    location: "臺北市中正區中山南路21-1號",
                    locationName: "國家兩廳院演奏廳",
                    price: "",
                    latitude: "12.345",
                    longitude: "67.890",
                    endTime: "2023-10-10 21:00:00"
                )
            ],
            descriptionFilterHTML: "Description for Event 1",
            imageURL: "https://example.com/image1.jpg",
            webSales: "https://example.com/tickets/event1",
            sourceWebPromote: "https://example.com/promo/event1",
            startDate: "2023-10-10",
            endDate: "2023-10-10",
            hitRate: 85
        )

        // Act
        sut.allProducts = [fakeArtData1]

        sut.filterContent(for: searchText)

        // Assert
        XCTAssertTrue(sut.searchResult.contains { artData in
            return artData.title.lowercased().contains(searchText.lowercased())
        })
    }
    
    func testFilterContentWithSearchTextInLocationName() {
        // Arrange
        let searchText = "兩廳院"
        
        // Create mock ArtDatum objects
        let fakeArtData1 = ArtDatum(
            uid: "1",
            title: "舒伯特：五重奏",
            category: "6",
            showInfo: [
                ShowInfo(
                    time: "2023-10-10 19:00:00",
                    location: "臺北市中正區中山南路21-1號",
                    locationName: "國家兩廳院演奏廳",
                    price: "",
                    latitude: "12.345",
                    longitude: "67.890",
                    endTime: "2023-10-10 21:00:00"
                )
            ],
            descriptionFilterHTML: "Description for Event 1",
            imageURL: "https://example.com/image1.jpg",
            webSales: "https://example.com/tickets/event1",
            sourceWebPromote: "https://example.com/promo/event1",
            startDate: "2023-10-10",
            endDate: "2023-10-10",
            hitRate: 85
        )

        // Act
        sut.allProducts = [fakeArtData1]

        // Act
        sut.filterContent(for: searchText)

        // Assert
        XCTAssertTrue(sut.searchResult.contains { artData in
            return artData.showInfo.first?.locationName.lowercased().contains(searchText.lowercased()) ?? false
        })
    }

    func testFilterContentWithSearchTextInLocation() {
        // Arrange
        let searchText = "臺北"
        
        // Create mock ArtDatum objects
        let fakeArtData1 = ArtDatum(
            uid: "1",
            title: "舒伯特：五重奏",
            category: "6",
            showInfo: [
                ShowInfo(
                    time: "2023-10-10 19:00:00",
                    location: "臺北市中正區中山南路21-1號",
                    locationName: "國家兩廳院演奏廳",
                    price: "",
                    latitude: "12.345",
                    longitude: "67.890",
                    endTime: "2023-10-10 21:00:00"
                )
            ],
            descriptionFilterHTML: "Description for Event 1",
            imageURL: "https://example.com/image1.jpg",
            webSales: "https://example.com/tickets/event1",
            sourceWebPromote: "https://example.com/promo/event1",
            startDate: "2023-10-10",
            endDate: "2023-10-10",
            hitRate: 85
        )

        // Act
        sut.allProducts = [fakeArtData1]

        // Act
        sut.filterContent(for: searchText)

        // Assert
        XCTAssertTrue(sut.searchResult.contains { artData in
            return artData.showInfo.first?.location.lowercased().contains(searchText.lowercased()) ?? false
        })
    }

    func testFilterContentWithNoMatch() {
        // Arrange
        let searchText = "&"
        
        // Create mock ArtDatum objects
        let fakeArtData1 = ArtDatum(
            uid: "1",
            title: "舒伯特：五重奏",
            category: "6",
            showInfo: [
                ShowInfo(
                    time: "2023-10-10 19:00:00",
                    location: "臺北市中正區中山南路21-1號",
                    locationName: "國家兩廳院演奏廳",
                    price: "",
                    latitude: "12.345",
                    longitude: "67.890",
                    endTime: "2023-10-10 21:00:00"
                )
            ],
            descriptionFilterHTML: "Description for Event 1",
            imageURL: "https://example.com/image1.jpg",
            webSales: "https://example.com/tickets/event1",
            sourceWebPromote: "https://example.com/promo/event1",
            startDate: "2023-10-10",
            endDate: "2023-10-10",
            hitRate: 85
        )

        // Act
        sut.filterContent(for: searchText)

        // Assert
        XCTAssertTrue(sut.searchResult.isEmpty)
    }
}
