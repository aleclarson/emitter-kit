
import Foundation

open class Emitter {

  // 1 - getHash(Listener.target)
  // 2 - getHash(Listener)
  // 3 - DynamicPointer<Listener>
  var listeners = [String:[String:DynamicPointer<Listener>]]()

  func emit (_ target: AnyObject!, _ data: Any!) {
    emit((target as? String) ?? getHash(target), data)
  }

  func emit (_ targets: [AnyObject], _ data: Any!) {
    for target in targets { emit(target, data) }
  }

  init () {}

  deinit {
    for (_, listeners) in self.listeners {
      for (_, listener) in listeners {
        listener.object.listening = false
      }
    }
  }

  fileprivate func emit (_ id: String, _ data: Any!) {
    if let listeners = self.listeners[id] {
      for (_, listener) in listeners {
        listener.object.trigger(data)
      }
    }
  }
}
