
import Foundation

extension NSObject {

  /// Creates a Listener for key-value observing.
  public func on <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> Listener {
    return on(keyPath, [.Old, .New], handler)
  }

  /// Creates a single-use Listener for key-value observing.
  public func once <T:Any> (keyPath: String, _ handler: Change<T> -> Void) -> Listener {
    return once(keyPath, [.Old, .New], handler)
  }
  
  /// Creates a Listener for key-value observing.
  public func on <T:Any> (keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: Change<T> -> Void) -> Listener {
    return ChangeListener(false, self, keyPath, options, handler)
  }
  
  /// Creates a single-use Listener for key-value observing.
  public func once <T:Any> (keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: Change<T> -> Void) -> Listener {
    return ChangeListener(true, self, keyPath, options, handler)
  }

  /// Call this before your NSObject's dealloc phase if the given Listener array has ChangeListeners.
  public func removeListeners (listeners: [Listener]) {
    for listener in listeners {
      if let listener = listener as? ChangeListener<Any> {
        listener.isListening = false
      }
    }
  }
}

public class Change <T:Any> : CustomStringConvertible {

  public let keyPath: String
  
  public let oldValue: T!
  
  public let newValue: T!

  public let isPrior: Bool
  
  public var description: String {
    return "(Change = { address: \(getHash(self)), keyPath: \(keyPath), oldValue: \(oldValue), newValue: \(newValue), isPrior: \(isPrior) })"
  }
  
  public init (_ keyPath: String, _ oldValue: T!, _ newValue: T!, _ isPrior: Bool) {
    self.keyPath = keyPath
    self.oldValue = oldValue
    self.newValue = newValue
    self.isPrior = isPrior
  }
}

class ChangeListener <T:Any> : Listener {

  let keyPath: String

  let options: NSKeyValueObservingOptions
  
  unowned let object: NSObject
  
  var observer: ChangeObserver!

  func trigger (data: NSDictionary) {
    let oldValue = data[NSKeyValueChangeOldKey] as? T
    let newValue = data[NSKeyValueChangeNewKey] as? T
    let isPrior = data[NSKeyValueChangeNotificationIsPriorKey] != nil
    trigger(Change<T>(keyPath, oldValue, newValue, isPrior))
  }
  
  override func startListening () {

    // A middleman to prevent pollution of ChangeListener property list.
    observer = ChangeObserver({ [unowned self] in self.trigger($0) })

    // Uses traditional KVO provided by Apple
    object.addObserver(observer, forKeyPath: keyPath, options: options, context: nil)

    // Caches this ChangeListener
    var targets = ChangeListenerCache[keyPath] ?? [:]
    var listeners = targets[targetID] ?? [:]
    listeners[getHash(self)] = once ? StrongPointer(self) : WeakPointer(self)
    targets[targetID] = listeners
    ChangeListenerCache[keyPath] = targets
  }
  
  override func stopListening() {

    object.removeObserver(observer, forKeyPath: keyPath)
    observer = nil

    var targets = ChangeListenerCache[keyPath]!
    var listeners = targets[targetID]!
    listeners[getHash(self)] = nil
    targets[targetID] = listeners.nilIfEmpty
    ChangeListenerCache[keyPath] = targets.nilIfEmpty
  }
  
  init (_ once: Bool, _ object: NSObject, _ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: Change<T> -> Void) {
    self.object = object
    self.keyPath = keyPath
    self.options = options
    
    super.init(nil, { handler($0 as! Change<T>) }, once)
  }
}

// 1 - Listener.keyPath
// 2 - getHash(Listener.target)
// 3 - getHash(Listener)
// 4 - DynamicPointer<Listener>
var ChangeListenerCache = [String:[String:[String:DynamicPointer<Listener>]]]()

// A sacrifice to the NSObject gods.
// To keep away the shitload of properties from my precious ChangeListener class.
class ChangeObserver : NSObject {
  
  let handler: NSDictionary -> Void
  
  override func observeValueForKeyPath (keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    handler(change ?? [:])
  }
  
  init (_ handler: NSDictionary -> Void) {
    self.handler = handler
  }
}
