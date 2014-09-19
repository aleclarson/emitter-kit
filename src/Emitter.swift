
public class Emitter {
  
  // 1 - hashify(Listener.target)
  // 2 - hashify(Listener)
  // 3 - Pointer<Listener>
  var listeners = [String:[String:Pointer<Listener>]]()
  
  func emit (target: AnyObject!, _ data: Any!) {
    for listener in (listeners[hashify(target)] ?? [:]).values {
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
