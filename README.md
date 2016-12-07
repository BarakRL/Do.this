# Do.this

Do.this is a Swift 3 quick async helper inspired by node.js Async.

### Usage:
#
```swift
Do.this { this in
    
    //do stuff
    this.done(result: someResult)
    
}.then (name: "result step") { this in
    
	//you can give this a name (optional)
	
    //you can access the previous result if needed:
    print("previousResult: \(this.previousResult)")
    
    //do more stuff
    //result is optional
    this.done()
    
}.then { this in
    
    //if an error happened, pass it in the done callback (you can still pass a result)
    //if you pass an error, the chain will break (see catch and finally below).
    let error: SomeError.bummer
    this.done(result: this.index, error: error)
    
}.then (on: DispatchQueue.global(qos: .background)) { this in
    
    //this will execute in a background queue
    print("on: \(DispatchQueue.currentLabel)")
    this.done(result: this.index)
    
}.then (on: .main) { this in
    
    //this will be execute in the main queue
    //if you dont specify a queue, this will be executed on the current (last used) queue.
    print("on: \(DispatchQueue.currentLabel)")
    this.done(result: this.index)
    
}.catch { this in
    
    //catch an error, this will point to the step that triggered the error
    print("catched error: \(this.error) from \(this.name ?? String(this.index))")
    
}.finally { this in
    
    //finally - will execute even if an error happened
    print("finally (previousResult: \(this.previousResult))")
    exp.fulfill()
}
```

License
----

MIT