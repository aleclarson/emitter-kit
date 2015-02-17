
import Foundation

private var eventListenerCache = [String:[Reference<EventListener>]]()

class EventListener {
  
  let event: String
  
  let handler: Any? -> Void
  
  let once: Bool
  
  private(set) var isListening = false
  
  func start () {
    if isListening { return }
    isListening = true

    cachedRef.object = self
    cachedRef.strong = once
    var listeners = eventListenerCache[self.event] ?? []
    listeners.append(cachedRef)
    eventListenerCache[self.event] = listeners
  }
  
  func stop () {
    if !isListening { return }
    isListening = false
    
    removeEventListener(event, cachedRef)
  }
  
  deinit {
    stop()
  }

  private init (_ target: AnyObject?, _ event: String, _ handler: Any? -> Void, _ once: Bool = false) {
    self.event = event + hashify(target)
    self.handler = handler
    self.once = once
    start()
  }
  
  private let cachedRef = Reference<EventListener>()
}

extension Event {
  func on (handler: EventData -> Void) -> EventListener {
    return EventListener(nil, id, { handler($0 as EventData) })
  }
  
  func on (target: AnyObject, _ handler: EventData -> Void) -> EventListener {
    return EventListener(target, id, { handler($0 as EventData) })
  }
  
  func once (handler: EventData -> Void) -> EventListener {
    return EventListener(nil, id, { handler($0 as EventData) }, true)
  }
  
  func once (target: AnyObject, _ handler: EventData -> Void) -> EventListener {
    return EventListener(target, id, { handler($0 as EventData) }, true)
  }
}

extension VoidEvent {
  func on (handler: Void -> Void) -> EventListener {
    return EventListener(nil, id, { _ in handler() })
  }
  
  func on (target: AnyObject, _ handler: Void -> Void) -> EventListener {
    return EventListener(target, id, { _ in handler() })
  }
  
  func once (handler: Void -> Void) -> EventListener {
    return EventListener(nil, id, { _ in handler() }, true)
  }
  
  func once (target: AnyObject, _ handler: Void -> Void) -> EventListener {
    return EventListener(target, id, { _ in handler() }, true)
  }
}

extension AnyEvent {
  func listeners () -> [EventListener] {
    return listeners(target: nil)
  }
  
  func listeners (target: AnyObject) -> [EventListener] {
    return listeners(target: target)
  }

  private func listeners (target: AnyObject? = nil) -> [EventListener] {
    let event = id + hashify(target)
    var listeners = [EventListener]()
    for (i, ref) in enumerate(eventListenerCache[event] ?? []) {
      if let listener = ref.object { listeners.append(listener) }
      else { removeEventListener(event, i) }
    }
    return listeners
  }
}

private func removeEventListener (event: String, index: Int) {
  if var listeners = eventListenerCache[event] {
    listeners.removeAtIndex(index)
    eventListenerCache[event] = listeners.count > 0 ? listeners : nil
  }
}

private func removeEventListener (event: String, cachedRef: Reference<EventListener>) {
  if var listeners = eventListenerCache[event] {
    removeObject(&listeners, cachedRef)
    eventListenerCache[event] = listeners.count > 0 ? listeners : nil
  }
}



//
//  Helpers
//

/// Most useful for Array storage of dynamically weak/strong object references
class Reference <T: AnyObject> {
  
  /// Use this in most situations
  var object: T? {
    get { return strong ? _strongObj : _weakObj }
    set {
      if strong { _strongObj = newValue }
      else { _weakObj = newValue }
    }
  }
  
  /// Holds a strong reference to the object when "true"
  var strong: Bool {
    get { return _strong }
    set {
      if strong == newValue { return }
      _strong = newValue
      if _strong { _strongObj = _weakObj }
      else { _weakObj = _strongObj }
    }
  }
  
  init () {}
  
  /// True value decoupled for internal change
  /// that avoids reference swapping.
  var _strong = false
  
  /// Cannot exist when "_weakObj" exists
  var _strongObj: T? {
    didSet {
      if _strongObj != nil {
        _strong = true
        _weakObj = nil
      }
    }
  }
  
  /// Cannot exist when "_strongObj" exists
  weak var _weakObj: T? {
    didSet {
      if _weakObj != nil {
        _strong = false
        _strongObj = nil
      }
    }
  }
}

/// Returns a unique id based on the given AnyObject plus an optional String
func hashify (object: AnyObject?) -> String {
  return object != nil ? String(object!.hash!) : ""
}

func findObject<T: AnyObject>(array: [T], object: T) -> Int? {
  for (idx, element) in enumerate(array) {
    if element === object { return idx }
  }
  return nil
}

func removeObject<T: AnyObject>(inout array: [T], object: T) -> Bool {
  if let idx = findObject(array, object) {
    array.removeAtIndex(idx)
    return true
  }
  return false
}
