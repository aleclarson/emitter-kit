
import Foundation

public extension NSObject {
  
  /// Creates a Listener for key-value observing.
  func on <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> ChangeListener<T> {
    return ChangeListener(self, keyPath, handler, false)
  }
  
  /// Creates a single-use Listener for key-value observing.
  func once <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> ChangeListener<T> {
    return ChangeListener(self, keyPath, handler, true)
  }
}

public struct Change <T:Any> {
  
  public let oldValue: T!
  
  public let newValue: T!
  
  init (_ oldValue: T!, _ newValue: T!) {
    self.oldValue = oldValue
    self.newValue = newValue
  }
}

public class ChangeListener <T:Any> : Listener {

  public let keyPath: String
  
  public private(set) weak var object: NSObject!
  
  var observer: ChangeObserver!
  
  override func startListening () {
    println("ChangeListener.startListening() keyPath: \(keyPath)")
    observer = ChangeObserver(trigger)
    object?.addObserver(observer, forKeyPath: keyPath, options: .Old | .New, context: nil)
  }
  
  override func stopListening() {
    object?.removeObserver(observer, forKeyPath: keyPath)
    observer = nil
  }
  
  func trigger (change: NSDictionary) {
    let oldValue = change[NSKeyValueChangeOldKey] as? T
    let newValue = change[NSKeyValueChangeNewKey] as? T
    let values = Change<T>(oldValue, newValue)
    super.trigger(values)
  }
  
  init (_ object: NSObject, _ keyPath: String, _ handler: Change<T> -> Void, _ once: Bool) {
    self.keyPath = keyPath
    self.object = object
    super.init(nil, { handler($0 as Change<T>) }, once)
  }
}

class ChangeObserver : NSObject {
  
  let handler: NSDictionary -> Void
  
  override func observeValueForKeyPath (keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    println("ChangeObserver { keyPath: \(keyPath), change: \(change) }")
    handler(change ?? [:])
  }
  
  init (_ handler: NSDictionary -> Void) {
    self.handler = handler
  }
}
