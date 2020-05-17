//
//  ResponseContainsStringValidatorTests.swift
//  Hyperconnectivity_Tests
//
//  Created by Ross Butler on 17/05/2020.
//  Copyright © 2020 Ross Butler. All rights reserved.
//

import Foundation
import OHHTTPStubs
import XCTest
@testable import Hyperconnectivity

class ResponseContainsStringValidatorTests: XCTestCase {
    private let timeout: TimeInterval = 5.0
    
    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }
    
    private func stubHost(_ host: String, withHTMLFrom fileName: String) throws {
        let stubPath = try XCTUnwrap(OHPathForFile(fileName, type(of: self)))
        stub(condition: isHost(host)) { _ in
            return fixture(filePath: stubPath, headers: ["Content-Type": "text/html"])
        }
    }
    
    /// Test response is valid when the response string contains the expected response.
    func testContainsExpectedResponseString() throws {
        try stubHost("www.apple.com", withHTMLFrom: "string-contains-response.html")
        let expectation = XCTestExpectation(description: "Connectivity check succeeds")
        let config = Hyperconnectivity.Configuration(responseValidator: ResponseContainsStringValidator(expectedResponse: "Success"))
        let connectivity = Hyperconnectivity(configuration: config)
        let connectivityChanged: (ConnectivityResult) -> Void = { result in
            XCTAssert(result.state == .wifiWithInternet)
            expectation.fulfill()
        }
        connectivity.connectivityChanged = connectivityChanged
        connectivity.startNotifier()
        wait(for: [expectation], timeout: timeout)
        connectivity.stopNotifier()
    }
    
    /// Test response is valid when the response string does not contain the expected response.
    func testDoesNotContainExpectedResponseString() throws {
        try stubHost("www.apple.com", withHTMLFrom: "string-contains-response.html")
        let expectation = XCTestExpectation(description: "Connectivity check succeeds")
        let config = Hyperconnectivity.Configuration(responseValidator: ResponseContainsStringValidator(expectedResponse: "Failure"))
        let connectivity = Hyperconnectivity(configuration: config)
        let connectivityChanged: (ConnectivityResult) -> Void = { result in
            XCTAssert(result.state == .wifiWithoutInternet)
            expectation.fulfill()
        }
        connectivity.connectivityChanged = connectivityChanged
        connectivity.startNotifier()
        wait(for: [expectation], timeout: timeout)
        connectivity.stopNotifier()
    }
}
