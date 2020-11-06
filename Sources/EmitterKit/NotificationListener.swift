
import Foundation

public class NotificationListener : Listener {

  public let name: Notification.Name

  var _observer: NSObjectProtocol!

  override func _startListening() {

    _observer = NotificationCenter.default.addObserver(forName: self.name, object: nil, queue: nil, using: {
      [unowned self] (notif: Notification) in

      // `getHash(notif.object as AnyObject)` returns
      // '0' when `notif.object` equals nil. Listen to all 
      // objects emitting `name` when listening on nil, mirroring
      // functionality in NSNotificationCenter.
      if self._targetID != "0" {
        if let target: AnyObject = notif.object as AnyObject? {
          if self._targetID != getHash(target) {
            return
          }
        } else {
          return
        }
      }

      self._trigger(notif)
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
    _observer = nil

    // Remove self from global cache.
    var targets = NotificationListenerCache[self.name]!
    var listeners = targets[_targetID]!
    listeners[getHash(self)] = nil
    targets[_targetID] = listeners.nilIfEmpty
    NotificationListenerCache[self.name] = targets.nilIfEmpty
  }

  init (_ name: Notification.Name, _ target: AnyObject!, _ once: Bool, _ handler: @escaping (Notification) -> Void) {
    self.name = name
    super.init(target, once) {
      handler($0 as! Notification)
    }
  }
}

// 1 - Listener.name
// 2 - getHash(Listener.target)
// 3 - getHash(Listener)
// 4 - DynamicPointer<Listener>
var NotificationListenerCache = [AnyHashable: [String: [String: DynamicPointer<Listener>]] ]()
