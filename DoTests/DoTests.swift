//
//  DoTests.swift
//  DoTests
//
//  Created by Barak Harel on 05/12/2016.
//  Copyright © 2016 Barak Harel. All rights reserved.
//

import XCTest
@testable import DoThis

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
      this.succeeded()
      
    }.then (name: "result step", after: 2) { this in
      
      print("previousResult: \(String(describing: this.previousResult))")
      this.succeeded(this.name)
      
    }.then { this in
      
      print("previousResult: \(String(describing: this.previousResult))")
      this.succeeded("\(this.index) - before error")
      
    }.then { this in
      
      print("previousResult: \(String(describing: this.previousResult))")
      //this.failed(NSError(domain: "error4", code: 4, userInfo: nil))
      this.succeeded("boop")
      
    }.then (on: DispatchQueue.global(qos: .background)) { this in
      
      print("previousResult: \(String(describing: this.previousResult)) on: \(DispatchQueue.currentLabel ?? "")")
      this.done(.success(this.index))
      
    }.then (on: .main) { this in
      
      print("previousResult: \(String(describing: this.previousResult)) on: \(DispatchQueue.currentLabel ?? "")")
      this.done(.success(this.index))
      
    }.catch { error, this in
      
      print("catched error: \(String(describing: error)) from \(this.name ?? String(this.index))")
      
    }.finally { this in
      
      print("finally (previousResult: \(String(describing: this.previousResult)))")
      exp.fulfill()
    }
    
    self.waitForExpectations(timeout: 25.0) { (error) -> Void in
      XCTAssert(error == nil, "test took too long, error: \(String(describing: error))")
    }
  }
}

extension DispatchQueue {
  class var currentLabel: String? {
    let name = __dispatch_queue_get_label(nil)
    return String(cString: name, encoding: .utf8)
  }
}
