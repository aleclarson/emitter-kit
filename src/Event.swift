
public class Event <T> {

  public var listenerCount: Int { return _listeners.count }

  public init () {}

  public func on (_ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, false, handler)
  }

  public func on (_ target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, false, handler)
  }

  @discardableResult
  public func once (handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, true, handler)
  }

  @discardableResult
  public func once (target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, true, handler)
  }

  public func emit (_ data: T) {
    _emit(data, on: "0")
  }

  public func emit (_ data: T, on target: AnyObject) {
    _emit(data, on: (target as? String) ?? getHash(target))
  }

  public func emit (_ data: T, on targets: [AnyObject]) {
    for target in targets {
      _emit(data, on: (target as? String) ?? getHash(target))
    }
  }

  // 1 - getHash(Listener.target)
  // 2 - getHash(Listener)
  // 3 - DynamicPointer<Listener>
  var _listeners = [String:[String:DynamicPointer<Listener>]]()

  private func _emit (_ data: Any!, on targetID: String) {
    if let listeners = _listeners[targetID] {
      for (_, listener) in listeners {
        listener.object._trigger(data)
      }
    }
  }

  deinit {
    for (_, listeners) in _listeners {
      for (_, listener) in listeners {
        listener.object._listening = false
      }
    }
  }
}
