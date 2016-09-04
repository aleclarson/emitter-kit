
import Foundation

public class NotificationListener : Listener {

  public let name: String

  var _observer: NSObjectProtocol!

  override func _startListening() {

    _observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: self.name), object: nil, queue: nil, using: {
      [unowned self] (notif: Notification) in

      // `getHash(notif.object as AnyObject)` returns an
      // incorrect value when `notif.object` equals nil.
      if let target: AnyObject = notif.object as AnyObject? {
        if self._targetID != getHash(target) {
          return
        }
      } else if self._targetID != "0" {
        return
      }

      self._trigger(notif.userInfo)
    })

    // Add self to global cache.
    var targets = NotificationListenerCache[name] ?? [:]
    var listeners = targets[_targetID] ?? [:]
    listeners[getHash(self)] = once ? StrongPointer(self) : WeakPointer(self)
    targets[_targetID] = listeners
    NotificationListenerCache[name] = targets
  }

  override func _stopListening() {

    NotificationCenter.default.removeObserver(_observer)

    // Remove self from global cache.
    var targets = NotificationListenerCache[self.name]!
    var listeners = targets[_targetID]!
    listeners[getHash(self)] = nil
    targets[_targetID] = listeners.nilIfEmpty
    NotificationListenerCache[self.name] = targets.nilIfEmpty
  }

  init (_ name: String, _ target: AnyObject!, _ once: Bool, _ handler: @escaping (NSDictionary) -> Void) {
    self.name = name
    super.init(target, once) {
      handler(($0 as? NSDictionary) ?? [:])
    }
  }
}

// 1 - Listener.name
// 2 - getHash(Listener.target)
// 3 - getHash(Listener)
// 4 - DynamicPointer<Listener>
var NotificationListenerCache = [String:[String:[String:DynamicPointer<Listener>]]]()
