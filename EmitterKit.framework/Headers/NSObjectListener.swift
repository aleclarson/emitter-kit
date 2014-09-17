
import Foundation

public extension NSObject {
  
  /// Creates a Listener for key-value observing.
  func observe <T:Any> (keyPath: String, _ handler: ChangedValue<T> -> Void) -> NSObjectListener<T> {
    return NSObjectListener(self, keyPath, handler, false)
  }
  
  /// Creates a single-use Listener for key-value observing.
  func observeOnce <T:Any> (keyPath: String, _ handler: ChangedValue<T> -> Void) -> NSObjectListener<T> {
    return NSObjectListener(self, keyPath, handler, true)
  }
}

public struct ChangedValue <T:Any> {
  
  public let oldValue: T!
  
  public let newValue: T!
  
  init (_ oldValue: T!, _ newValue: T!) {
    self.oldValue = oldValue
    self.newValue = newValue
  }
}

public class NSObjectListener <T:Any> : Listener {

  public let keyPath: String
  
  public private(set) weak var object: NSObject!
  
  var observer: ChangedValueObserver!
  
  override func startListening () {
    println("NSObjectListener.startListening() keyPath: \(keyPath)")
    observer = ChangedValueObserver(trigger)
    object?.addObserver(observer, forKeyPath: keyPath, options: .Old | .New, context: nil)
  }
  
  override func stopListening() {
    object?.removeObserver(observer, forKeyPath: keyPath)
    observer = nil
  }
  
  func trigger (change: NSDictionary) {
    let oldValue = change[NSKeyValueChangeOldKey] as? T
    let newValue = change[NSKeyValueChangeNewKey] as? T
    let values = ChangedValue<T>(oldValue, newValue)
    super.trigger(values)
  }
  
  init (_ object: NSObject, _ keyPath: String, _ handler: ChangedValue<T> -> Void, _ once: Bool) {
    self.keyPath = keyPath
    self.object = object
    super.init(nil, { handler($0 as ChangedValue<T>) }, once)
  }
}

class ChangedValueObserver : NSObject {
  
  let handler: NSDictionary -> Void
  
  override func observeValueForKeyPath (keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    println("ChangedValueObserver { keyPath: \(keyPath), change: \(change) }")
    handler(change ?? [:])
  }
  
  init (_ handler: NSDictionary -> Void) {
    self.handler = handler
  }
}
