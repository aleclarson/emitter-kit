
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

public class Change <T:Any> : Printable {

  public let keyPath: String
  
  public let oldValue: T!
  
  public let newValue: T!
  
  public var description: String {
    return "(old \(keyPath): \(oldValue), new \(keyPath): \(newValue))"
  }
  
  init (_ keyPath: String, _ oldValue: T!, _ newValue: T!) {
    self.keyPath = keyPath
    self.oldValue = oldValue
    self.newValue = newValue
  }
}

public class ChangeListener <T:Any> : Listener {

  public let keyPath: String
  
  public private(set) weak var object: NSObject!
  
  var observer: ChangeObserver!
  
  override func startListening () {
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
    let values = Change<T>(keyPath, oldValue, newValue)
    super.trigger(values)
  }
  
  init (_ object: NSObject, _ keyPath: String, _ handler: Change<T> -> Void, _ once: Bool) {
    self.keyPath = keyPath
    self.object = object
    super.init(nil, { handler($0 as Change<T>) }, once)
  }
}

// A sacrifice to the NSObject gods.
// To keep away the shitload of properties from my precious ChangeListener class.
class ChangeObserver : NSObject {
  
  let handler: NSDictionary -> Void
  
  override func observeValueForKeyPath (keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    handler(change ?? [:])
  }
  
  init (_ handler: NSDictionary -> Void) {
    self.handler = handler
  }
}
