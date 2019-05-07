
public class EventListener <T> : Listener {

  public weak var event: Event<T>!

  override func _startListening () {
    let ptr: DynamicPointer<Listener> =
      once ? StrongPointer(self) : WeakPointer(self)

    if event._listeners[_targetID] == nil {
      event._listeners[_targetID] = [ptr]
    } else {
      event._listeners[_targetID]!.append(ptr)
    }
  }

  override func _stopListening() {
    if (event._emitting) { return }
    event._listeners[_targetID] =
      event._listeners[_targetID]!.filter({
        $0.object !== self
      }).nilIfEmpty
  }

  override func _trigger (_ data: Any!) {
    _handler(data)

    // The listener will be removed by its event.
    if (self.once) { self._listening = false }
  }

  init (_ event: Event<T>, _ target: AnyObject!, _ once: Bool, _ handler: @escaping (T) -> Void) {
    self.event = event
    super.init(target, once, {
      handler($0 as AnyObject as! T)
    })
  }
}
