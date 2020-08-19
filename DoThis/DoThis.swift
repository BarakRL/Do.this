//
//  DoThis.swift
//  Do.this
//
//  Created by Barak Harel on 05/12/2016.
//  Copyright © 2016 Barak Harel. All rights reserved.
//


import Foundation

public typealias ThisClosure = ((DoThis) -> Void)

public class Do {
  
  @discardableResult
  public static func this(name: String? = nil, on queue: DispatchQueue = .main, after delay: TimeInterval = 0, do this: @escaping ThisClosure) -> DoThis {
    
    let first = DoThis(name: name, on: queue, after: delay, index: 0, do: this)
    if delay > 0 {
      queue.asyncAfter(deadline: .now() + delay, execute: {
        first.doThis(first)
      })
    } else {
      queue.async {
        first.doThis(first)
      }
    }
    
    return first
  }
  
}

public class DoThis {
  
  public private(set) var name: String?
  public private(set) var index: Int
  fileprivate var delay: TimeInterval = 0
  fileprivate var onQueue: DispatchQueue = .main
  fileprivate var doThis: ThisClosure
  
  public fileprivate(set) var previousResult: Result<Any?, Error>?
  public var previousValue: Any? {
    guard let previousResult = previousResult else { return nil }
    switch previousResult {
    case .success(let value): return value
    case .failure(_): return nil    
    }
  }
  
  fileprivate var next: DoThis?
  
  fileprivate var catchThis: ((_ error: Error, _ in: DoThis) -> Void)?
  fileprivate var finallyThis: ThisClosure?
  
  fileprivate init(name: String?, on queue: DispatchQueue, after delay: TimeInterval, index: Int, do this: @escaping ThisClosure) {
    self.name = name
    self.index = index
    self.onQueue = queue
    self.delay = delay
    self.doThis = this
  }
    
  /// This succeeded
  /// - Parameter value: optional value
  public func succeeded(_ value: Any? = nil) {
    self.done(.success(value))
  }
    
  /// This failed
  /// - Parameter error: error
  public func failed(_ error: Error) {
    self.done(.failure(error))
  }
  
  /// Done Callback, should be called within every this and then closures
  ///
  /// - Parameters:
  ///   - error: error if any, will continue to the catch and finally closures
  ///   - result: result (optional) passed to the next then or finally closures
  public func done(_ result: Result<Any?, Error>) {
    
    switch result {
    // Handle error
    case .failure(let error):
      lastDo.previousResult = result
      lastDo.catchThis?(error, self)
      lastDo.finallyThis?(lastDo)
      
    // Handle success
    case .success(_):
      // if next is set, use it
      if let next = self.next {
        if next.delay > 0 {
          next.onQueue.asyncAfter(deadline: .now() + next.delay, execute: {
            next.previousResult = result
            next.doThis(next)
          })
        } else {
          next.onQueue.async {
            next.previousResult = result
            next.doThis(next)
          }
        }
      } else { // no next, call finally if set
        lastDo.previousResult = result
        lastDo.finallyThis?(lastDo)
      }
    }
  }
  
  public func then(name: String? = nil, on queue: DispatchQueue? = nil, after delay: TimeInterval = 0, do this: @escaping ThisClosure) -> DoThis {
    guard self.catchThis == nil else { fatalError("Can't call next() after catch()") }
    
    let queue = queue ?? self.onQueue
    let next = DoThis(name: name, on: queue, after: delay, index: self.index + 1, do: this)
    self.next = next
    
    return next
  }
  
  @discardableResult
  public func `catch`(this: @escaping ((Error, DoThis)->Void)) -> DoThis {
    self.catchThis = this
    return self
  }
  
  public func finally(this: @escaping ThisClosure) {
    self.finallyThis = this
  }
  
  private var lastDo: DoThis {
    var last = self
    while let next = last.next {
      last = next
    }
    
    return last
  }
  
  deinit {
    //print("deinit \(self.index)")
  }
}

