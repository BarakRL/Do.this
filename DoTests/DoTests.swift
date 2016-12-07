//
//  DoTests.swift
//  DoTests
//
//  Created by Barak Harel on 05/12/2016.
//  Copyright © 2016 Barak Harel. All rights reserved.
//

import XCTest
@testable import Do

class DoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        let exp = expectation(description: "test")
        
        Do.this { (_, done) in
            
            print("Do.this")
            done(nil, nil)
            
        }.then { (result, done) in
            
            print("then with: \(result)")
            done("result1", nil)
            
        }.then { (result, done) in
            
            print("then with: \(result)")
            done("result2", nil)
            
        }.then { (result, done) in
            
            print("then with: \(result)")
            let error: Error? = nil //NSError(domain: "error4", code: 4, userInfo: nil)
            done("result3", error)
            
        }.then (on: DispatchQueue.global(qos: .background)) { (result, done) in
            
            print("then with: \(result) on: \(DispatchQueue.currentLabel)")
            done("result4", nil)
            
        }.then (on: .main) { (result, done) in
            
            print("then with: \(result) on: \(DispatchQueue.currentLabel)")
            done("result5", nil)
            
        }.catch { (from, error) in
            
            print("catched error: \(error) from \(from.name ?? String(from.index))")
            
        }.finally { (result) in
            
            print("finally: \(result)")
            exp.fulfill()
        }
        
        self.waitForExpectations(timeout: 25.0) { (error) -> Void in
            XCTAssert(error == nil, "test took too long, error: \(error)")
        }
    }
}

extension DispatchQueue {
    class var currentLabel: String? {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))
    }
}
