
import Foundation

public extension NSObject {
  
  /// Creates a Listener for key-value observing.
  func on <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> Listener {
    return ChangeListener(self, keyPath, handler, false)
  }
  
  /// Creates a single-use Listener for key-value observing.
  func once <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> Listener {
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

class ChangeListener <T:Any> : Listener {

  let keyPath: String
  
  weak var object: NSObject!
  
  var relayer: ChangeRelayer!
  
  override func startListening () {
    relayer = ChangeRelayer({
      [unowned self] in
      let oldValue = $0[NSKeyValueChangeOldKey] as? T
      let newValue = $0[NSKeyValueChangeNewKey] as? T
      let values = Change<T>(self.keyPath, oldValue, newValue)
      self.trigger(values)
    })
    object?.addObserver(relayer, forKeyPath: keyPath, options: .Old | .New, context: nil)
    
    var targets = ChangeListenerCache[keyPath] ?? [:]
    var listeners = targets[targetID] ?? [:]
    listeners[hashify(self)] = once ? StrongPointer(self) : WeakPointer(self)
    targets[targetID] = listeners
    ChangeListenerCache[keyPath] = targets
  }
  
  override func stopListening() {
    object?.removeObserver(relayer, forKeyPath: keyPath)
    relayer = nil
    
    var targets = ChangeListenerCache[keyPath]!
    var listeners = targets[targetID]!
    listeners[hashify(self)] = nil
    targets[targetID] = listeners.nilIfEmpty
    ChangeListenerCache[keyPath] = targets.nilIfEmpty
  }
  
  init (_ object: NSObject, _ keyPath: String, _ handler: Change<T> -> Void, _ once: Bool) {
    self.keyPath = keyPath
    self.object = object
    super.init(nil, { handler($0 as Change<T>) }, once)
  }
}

// 1 - Listener.keyPath
// 2 - hashify(Listener.target)
// 3 - hashify(Listener)
// 4 - Pointer<Listener>
var ChangeListenerCache = [String:[String:[String:Pointer<Listener>]]]()

// A sacrifice to the NSObject gods.
// To keep away the shitload of properties from my precious ChangeListener class.
class ChangeRelayer : NSObject {
  
  let handler: NSDictionary -> Void
  
  override func observeValueForKeyPath (keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
    handler(change ?? [:])
  }
  
  init (_ handler: NSDictionary -> Void) {
    self.handler = handler
  }
}
