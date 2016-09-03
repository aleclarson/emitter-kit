
import Foundation

open class Emitter {

  // 1 - getHash(Listener.target)
  // 2 - getHash(Listener)
  // 3 - DynamicPointer<Listener>
  var listeners = [String:[String:DynamicPointer<Listener>]]()

  func emit (_ data: Any!, on target: AnyObject!) {
    emit(data, on: (target as? String) ?? getHash(target))
  }

  func emit (_ data: Any!, on targets: [AnyObject]) {
    for target in targets { emit(data, on: target) }
  }

  init () {}

  deinit {
    for (_, listeners) in self.listeners {
      for (_, listener) in listeners {
        listener.object.listening = false
      }
    }
  }

  fileprivate func emit (_ data: Any!, on id: String) {
    if let listeners = self.listeners[id] {
      for (_, listener) in listeners {
        listener.object.trigger(data)
      }
    }
  }
}
