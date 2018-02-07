
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

  init (_ event: Event<T>, _ target: AnyObject!, _ once: Bool, _ handler: @escaping (T) -> Void) {
    self.event = event
    super.init(target, once, {
      handler($0 as! T)
    })
  }
}
