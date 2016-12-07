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
        
        Do.this { this in
            
            print("Do.this")
            this.done()
            
        }.then (name: "result step") { this in
            
            print("previousResult: \(this.previousResult)")
            this.done(result: this.name)
            
        }.then { this in
            
            print("previousResult: \(this.previousResult)")
            this.done(result: this.index, error: nil)
            
        }.then { this in
            
            print("previousResult: \(this.previousResult)")
            let error: Error? = nil //NSError(domain: "error4", code: 4, userInfo: nil)
            this.done(result: this.index, error: error)
            
        }.then (on: DispatchQueue.global(qos: .background)) { this in
            
            print("previousResult: \(this.previousResult) on: \(DispatchQueue.currentLabel)")
            this.done(result: this.index)
            
        }.then (on: .main) { this in
            
            print("previousResult: \(this.previousResult) on: \(DispatchQueue.currentLabel)")
            this.done(result: this.index)
            
        }.catch { this in
            
            print("catched error: \(this.error) from \(this.name ?? String(this.index))")
            
        }.finally { this in
            
            print("finally (previousResult: \(this.previousResult))")
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
