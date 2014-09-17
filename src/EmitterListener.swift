
public class EmitterListener : Listener {
    
  public unowned let emitter: Emitter
  
  override func startListening () {
    let tid = hashify(target)
    var listeners = emitter.listeners[tid] ?? [:]
    listeners[hashify(self)] = self
    emitter.listeners[tid] = listeners
  }
  
  override func stopListening () {
    let targetID = hashify(target)
    if var listeners = emitter.listeners[targetID] {
      let listenerID = hashify(self)
      if listeners[listenerID] != nil {
        listeners[listenerID] = nil
        emitter.listeners[targetID] = listeners.count > 0 ? listeners : nil
      }
    }
  }
  
  init (_ emitter: Emitter, _ target: AnyObject!, _ handler: Any! -> Void, _ once: Bool) {
    self.emitter = emitter
    super.init(target, handler, once)
  }
}
