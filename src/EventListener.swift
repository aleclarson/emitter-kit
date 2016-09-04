
public class EventListener <T> : Listener {

  public weak var event: Event<T>!

  override func _startListening () {
    if self.event == nil { return }
    var listeners = self.event._listeners[_targetID] ?? [:]
    listeners[getHash(self)] = once ? StrongPointer(self) : WeakPointer(self)
    self.event._listeners[_targetID] = listeners
  }

  override func _stopListening () {
    if self.event == nil { return }
    var listeners = self.event._listeners[_targetID]!
    listeners[getHash(self)] = nil
    self.event._listeners[_targetID] = listeners.nilIfEmpty
  }

  init (_ event: Event<T>, _ target: AnyObject!, _ once: Bool, _ handler: @escaping (T) -> Void) {
    self.event = event
    super.init(target, once, {
      handler($0 as! T)
    })
  }
}
