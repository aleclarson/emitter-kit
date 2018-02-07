
public class Event <T> {

  @available(*, deprecated, message: "This property is not accurate; please use 'getListeners().count' instead.")
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

  public func getListeners (_ target: AnyObject?) -> [Listener] {
    let targetID = (target as? String) ?? getHash(target)
    return _listeners[targetID]?.map({ $0.object }) ?? []
  }

  // key == getHash(listener.target)
  var _listeners = [String:[DynamicPointer<Listener>]]()

  // Avoid unnecessary removal if a listener is stopped during emit.
  var _emitting = false

  private func _emit (_ data: Any!, on targetID: String) {
    if _listeners[targetID] != nil {
      _emitting = true
      _listeners[targetID] = _listeners[targetID]!.filter({
        if let listener = $0.object {
          if (listener._listening) {
            listener._trigger(data)
            return listener._listening
          }
        }
        return false
      }).nilIfEmpty
      _emitting = false
    }
  }

  deinit {
    for (_, listeners) in _listeners {
      for listener in listeners {
        listener.object?._listening = false
      }
    }
  }
}

public extension Event where T == Void {

  func emit () {
    _emit((), on: "0")
  }

  func emit (on target: AnyObject) {
    _emit((), on: (target as? String) ?? getHash(target))
  }

  func emit (on targets: [AnyObject]) {
    for target in targets {
      _emit((), on: (target as? String) ?? getHash(target))
    }
  }
}
