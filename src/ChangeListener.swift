
import Foundation

extension NSObject {

  /// Creates a Listener for key-value observing.
  @warn_unused_result
  public func on <T:Any> (_ keyPath: String, _ handler: (Change<T>) -> Void) -> Listener {
    return on(keyPath, [.old, .new], handler)
  }

  /// Creates a single-use Listener for key-value observing.
  public func once <T:Any> (_ keyPath: String, _ handler: (Change<T>) -> Void) -> Listener {
    return once(keyPath, [.old, .new], handler)
  }

  /// Creates a Listener for key-value observing.
  public func on <T:Any> (_ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: (Change<T>) -> Void) -> Listener {
    return ChangeListener(false, self, keyPath, options, handler)
  }

  /// Creates a single-use Listener for key-value observing.
  public func once <T:Any> (_ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: (Change<T>) -> Void) -> Listener {
    return ChangeListener(true, self, keyPath, options, handler)
  }

  /// Call this before your NSObject's dealloc phase if the given Listener array has ChangeListeners.
  public func removeListeners (_ listeners: [Listener]) {
    for listener in listeners {
      if let listener = listener as? ChangeListener<Any> {
        listener.isListening = false
      }
    }
  }
}

open class Change <T:Any> : CustomStringConvertible {

  open let keyPath: String

  open let oldValue: T!

  open let newValue: T!

  open let isPrior: Bool

  open var description: String {
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

  func trigger (_ data: NSDictionary) {
    let oldValue = data[NSKeyValueChangeKey.oldKey] as? T
    let newValue = data[NSKeyValueChangeKey.newKey] as? T
    let isPrior = data[NSKeyValueChangeKey.notificationIsPriorKey] != nil
    trigger(Change<T>(keyPath, oldValue as! _!, newValue, isPrior))
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

  init (_ once: Bool, _ object: NSObject, _ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: (Change<T>) -> Void) {
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

  let handler: (NSDictionary) -> Void

  override func observeValue (forKeyPath keyPath: String?, of object: Any?, change: [String : Any]?, context: UnsafeMutableRawPointer?) {
    handler(change as NSDictionary? ?? [:])
  }

  init (_ handler: @escaping (NSDictionary) -> Void) {
    self.handler = handler
  }
}
