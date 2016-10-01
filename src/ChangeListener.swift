
import Foundation

public extension NSObject {

  /// Creates a Listener for key-value observing.
  func on <T> (_ keyPath: String, _ handler: @escaping (Change<T>) -> Void) -> ChangeListener<T> {
    return on(keyPath, [.old, .new], handler)
  }

  /// Creates a single-use Listener for key-value observing.
  @discardableResult
  func once <T> (_ keyPath: String, _ handler: @escaping (Change<T>) -> Void) -> ChangeListener<T> {
    return once(keyPath, [.old, .new], handler)
  }

  /// Creates a Listener for key-value observing.
  func on <T> (_ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: @escaping (Change<T>) -> Void) -> ChangeListener<T> {
    return ChangeListener(false, self, keyPath, options, handler)
  }

  /// Creates a single-use Listener for key-value observing.
  @discardableResult
  func once <T> (_ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: @escaping (Change<T>) -> Void) -> ChangeListener<T> {
    return ChangeListener(true, self, keyPath, options, handler)
  }

  /// Call this before your NSObject's dealloc phase if the given Listener array has ChangeListeners.
  func removeListeners (_ listeners: [Listener]) {
    for listener in listeners {
      if let listener = listener as? ChangeListener<NSObject> {
        listener.isListening = false
      }
    }
  }
}

public class Change <T> : CustomStringConvertible {

  public let keyPath: String

  public let oldValue: T!

  public let newValue: T!

  public let isPrior: Bool

  public var description: String {
    return "(Change = { address: \(getHash(self)), keyPath: \(keyPath), oldValue: \(oldValue), newValue: \(newValue), isPrior: \(isPrior) })"
  }

  init (_ keyPath: String, _ oldValue: T!, _ newValue: T!, _ isPrior: Bool) {
    self.keyPath = keyPath
    self.oldValue = oldValue
    self.newValue = newValue
    self.isPrior = isPrior
  }
}

public class ChangeListener <T> : Listener {

  public let keyPath: String

  public let options: NSKeyValueObservingOptions

  public unowned let object: NSObject

  var _observer: ChangeObserver!

  func _trigger (_ data: NSDictionary) {
    let oldValue = data[NSKeyValueChangeKey.oldKey] as? T
    let newValue = data[NSKeyValueChangeKey.newKey] as? T
    let isPrior = data[NSKeyValueChangeKey.notificationIsPriorKey] != nil
    _trigger(Change<T>(keyPath, oldValue, newValue, isPrior))
  }

  override func _startListening () {

    // A middleman to prevent pollution of ChangeListener property list.
    _observer = ChangeObserver({ [unowned self] in
      self._trigger($0)
    })

    self.object.addObserver(_observer, forKeyPath: self.keyPath, options: self.options, context: nil)

    // Add self to global cache.
    var targets = ChangeListenerCache[self.keyPath] ?? [:]
    var listeners = targets[_targetID] ?? [:]
    listeners[getHash(self)] = self.once ? StrongPointer(self) : WeakPointer(self)
    targets[_targetID] = listeners
    ChangeListenerCache[self.keyPath] = targets
  }

  override func _stopListening() {

    self.object.removeObserver(_observer, forKeyPath: self.keyPath)

    // Remove self from global cache.
    var targets = ChangeListenerCache[self.keyPath]!
    var listeners = targets[_targetID]!
    listeners[getHash(self)] = nil
    targets[_targetID] = listeners.nilIfEmpty
    ChangeListenerCache[self.keyPath] = targets.nilIfEmpty
  }

  init (_ once: Bool, _ object: NSObject, _ keyPath: String, _ options: NSKeyValueObservingOptions, _ handler: @escaping (Change<T>) -> Void) {
    self.object = object
    self.keyPath = keyPath
    self.options = options

    super.init(nil, once) {
      handler($0 as! Change<T>)
    }
  }
}

// 1 - Listener.keyPath
// 2 - getHash(Listener.target)
// 3 - getHash(Listener)
// 4 - DynamicPointer<Listener>
var ChangeListenerCache = [String:[String:[String:DynamicPointer<Listener>]]]()

class ChangeObserver : NSObject {

  let _handler: (NSDictionary) -> Void
    
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    _handler(change as NSDictionary? ?? [:])
  }

  init (_ handler: @escaping (NSDictionary) -> Void) {
    _handler = handler
  }
}
