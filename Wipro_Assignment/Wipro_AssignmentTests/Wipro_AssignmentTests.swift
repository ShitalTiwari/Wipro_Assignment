//
//  Wipro_AssignmentTests.swift
//  Wipro_AssignmentTests
//
//  Created by SierraVista Technologies Pvt Ltd on 10/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import XCTest
@testable import Wipro_Assignment

class Wipro_AssignmentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //This method checks for successful network call to API url
    func testUserDataSuccessCase() {
        guard let gitUrl = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json") else { return }
        let promise = expectation(description: "Simple Request")
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            
            if let responseString = String(data: data, encoding: String.Encoding.ascii) {
                
                if let jsonData = responseString.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                        //Inserting success test status
                        if (json["rows"] as? [[String: AnyObject]]) != nil {
                            XCTAssertTrue(json["title"] as! String != "")
                            promise.fulfill()
                        }
                        
                    } catch {//managing failed test state
                        print("Err", error)
                    }
                }
            }
            }.resume()
        //Cehcks for exceptions for 20 seconds
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    //This method tests failed network API call for given url
    func testUserDataFailCase() {
        guard let gitUrl = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json") else { return }
        let promise = expectation(description: "Simple Request")
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                //Inserting success test state
                if let result = json as? NSDictionary {
                    XCTAssertTrue(result["title"] as! String != "")
                    promise.fulfill()
                }
            } catch let err {//managing failed test state
                print("Err", err)
            }
            }.resume()
        //Cehcks for exceptions for 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
    }
}
