//
//  Do.swift
//  Do
//
//  Created by Barak Harel on 05/12/2016.
//  Copyright © 2016 Barak Harel. All rights reserved.
//


import Foundation

public class Do {
    
    public typealias ThisClosure = ((Do) -> Void)
    
    private(set) var name: String?
    private(set) var index: Int
    private var onQueue: DispatchQueue = .main
    private var doThis: ThisClosure
    
    private(set) var error: Error?
    private(set) var previousResult: Any?
    private var next: Do?

    private var catchThis: ThisClosure?
    private var finallyThis: ThisClosure?
    
    private init(name: String?, on queue: DispatchQueue, index: Int, do this: @escaping ThisClosure) {
        self.name = name
        self.index = index
        self.onQueue = queue
        self.doThis = this
    }
    
    @discardableResult
    static func this(name: String? = nil, on queue: DispatchQueue = .main, do this: @escaping ThisClosure) -> Do {
        
        let first = Do(name: name, on: queue, index: 0, do: this)
        queue.async {
            first.doThis(first)
        }
        
        return first
    }
    
    
    /// Done Callback, should be called within every this and then closures
    ///
    /// - Parameters:
    ///   - error: error if any, will continue to the catch and finally closures
    ///   - result: result (optional) passed to the next then or finally closures
    func done(result: Any? = nil, error: Error? = nil) {
        
        //if error
        if let error = error {
            
            self.error = error
            lastDo.catchThis?(self)
            
            lastDo.previousResult = result
            lastDo.finallyThis?(lastDo)
        }
        else if let next = self.next {
            
            next.onQueue.async {
                next.previousResult = result
                next.doThis(next)
            }
        }
        else {
            lastDo.previousResult = result
            lastDo.finallyThis?(lastDo)
        }
    }
    
    func then(name: String? = nil, on queue: DispatchQueue? = nil, do this: @escaping ThisClosure) -> Do {
        
        guard self.catchThis == nil else {
            fatalError("Can't call next() after catch()")
        }
        
        let queue = queue ?? self.onQueue
        
        let next = Do(name: name, on: queue, index: self.index + 1, do: this)
        self.next = next
        
        return next
    }
    
    @discardableResult
    func `catch`(this: @escaping ThisClosure) -> Do {
        
        self.catchThis = this
        return self
    }
    
    func finally(this: @escaping ThisClosure) {
        
        self.finallyThis = this
    }
    
    private var lastDo: Do {
        
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

