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
        }
        else {
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
    
    public fileprivate(set) var error: Error?
    public fileprivate(set) var previousResult: Any?
    fileprivate var checkStop: Bool = false
    fileprivate var next: DoThis?

    fileprivate var catchThis: ThisClosure?
    fileprivate var finallyThis: ThisClosure?
    
    fileprivate init(name: String?, on queue: DispatchQueue, checkStop: Bool = false, after delay: TimeInterval, index: Int, do this: @escaping ThisClosure) {
        self.name = name
        self.index = index
        self.onQueue = queue
        self.delay = delay
        self.checkStop = checkStop
        self.doThis = this
    }
    
    
    /// Done Callback, should be called within every this and then closures
    ///
    /// - Parameters:
    ///   - error: error if any, will continue to the catch and finally closures
    ///   - result: result (optional) passed to the next then or finally closures
    public func done(result: Any? = nil, finished: Bool = false, error: Error? = nil) {
        
        //if error
        if let error = error {
            
            self.error = error
            lastDo.catchThis?(self)
            
            lastDo.previousResult = result
            lastDo.finallyThis?(lastDo)
        }
        else if let next = self.next {
            
            if next.delay > 0 {
                if !next.checkStop || !finished {
                    next.onQueue.asyncAfter(deadline: .now() + next.delay, execute: {
                        next.previousResult = result
                        next.doThis(next)
                    })
                }
            }
            else {
                if !next.checkStop || !finished {
                    next.onQueue.async {
                        next.previousResult = result
                        next.doThis(next)
                        
                    }
                }
            }
        }
        else {
            lastDo.previousResult = result
            lastDo.finallyThis?(lastDo)
        }
    }
    
    public func then(name: String? = nil, on queue: DispatchQueue? = nil, after delay: TimeInterval = 0, do this: @escaping ThisClosure) -> DoThis {
        
        return createNext(name: name, on: queue, after: delay, do: this)
    }
    
    @discardableResult
    public func orThis(name: String? = nil, on queue: DispatchQueue? = nil, after delay: TimeInterval = 0, do this: @escaping ThisClosure) -> DoThis {
        
        return createNext(name: name, on: queue, checkStop: true, after: delay, do: this)
    }
    
    private func createNext(name: String? = nil, on queue: DispatchQueue? = nil, checkStop: Bool = false, after delay: TimeInterval = 0, do this: @escaping ThisClosure) -> DoThis {
        
        guard self.catchThis == nil else {
            fatalError("Can't call next() after catch()")
        }
        
        let queue = queue ?? self.onQueue
        
        let next = DoThis(name: name, on: queue, after: delay, index: self.index + 1, do: this)
        self.next = next
        
        return next
    }
    
    @discardableResult
    public func `catch`(this: @escaping ThisClosure) -> DoThis {
        
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

