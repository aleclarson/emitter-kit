
public class Emitter {
  
  // 1 - getHash(Listener.target)
  // 2 - getHash(Listener)
  // 3 - DynamicPointer<Listener>
  var listeners = [String:[String:DynamicPointer<Listener>]]()
  
  func emit (target: AnyObject!, _ data: Any!) {
    for listener in (listeners[getHash(target)] ?? [:]).values {
      listener.object.trigger(data)
    }
  }
  
  func emit (targets: [AnyObject], _ data: Any!) {
    for target in targets {
      emit(target, data)
    }
  }
  
  init () {}
  
  deinit {
    for (_, listeners) in self.listeners {
      for (_, listener) in listeners {
        listener.object.listening = false
      }
    }
  }
}
