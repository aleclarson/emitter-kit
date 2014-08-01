
//
// This is Event.swift, EventListener.swift, and EventHelpers.swift concatenated together
// for easier use with projects and to take advantage of 'private' helpers.
//

import Foundation

class AnyEvent {

  let id: String
  
  init (id: String = NSUUID().UUIDString) {
    if takenEventIDs[id] {
      println("Event ID \"\(id)\" is already taken.")
      fatalError("Error. See your console for details.")
    }
    
    self.id = id
    
    takenEventIDs[id] = true
  }
}

class VoidEvent : AnyEvent {

  init () {
    super.init()
  }

  init (id: String) {
    super.init(id: id)
  }
  
  func emit () {
    emitAnyEvent(self, nil, nil)
  }
  
  func emit (target: AnyObject) {
    emitAnyEvent(self, target, nil)
  }
  
  func emit (targets: [AnyObject]) {
    emitAnyEvent(self, targets, nil)
  }
  
  func on (onNewEvent: Void -> Void) -> VoidEventListener {
    return VoidEventListener(nil, id, onNewEvent)
  }
  
  func on (target: AnyObject, _ onNewEvent: Void -> Void) -> VoidEventListener {
    return VoidEventListener(target, id, onNewEvent)
  }
  
  func once (onNewEvent: Void -> Void) -> VoidEventListener {
    return VoidEventListener(nil, id, onNewEvent, true)
  }
  
  func once (target: AnyObject, _ onNewEvent: Void -> Void) -> VoidEventListener {
    return VoidEventListener(target, id, onNewEvent, true)
  }
}

class Event <EventData: Any> : AnyEvent {

  init () {
    super.init()
  }

  init (id: String) {
    super.init(id: id)
  }
  
  func emit (data: EventData) {
    emitAnyEvent(self, nil, data)
  }

  func emit (target: AnyObject, _ data: EventData) {
    emitAnyEvent(self, target, data)
  }
  
  func emit (targets: [AnyObject], _ data: EventData) {
    emitAnyEvent(self, targets, data)
  }
  
  func on (onNewEvent: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(nil, id, onNewEvent)
  }
  
  func on (target: AnyObject, _ onNewEvent: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(target, id, onNewEvent)
  }
  
  func once (onNewEvent: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(nil, id, onNewEvent, true)
  }
  
  func once (target: AnyObject, _ onNewEvent: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(target, id, onNewEvent, true)
  }
}

private var takenEventIDs = [String:Bool]()
  
private func emitAnyEvent (event: AnyEvent, target: AnyObject?, data: Any?) {
  for listener in event.listeners(target: target) {
    listener.onNewEvent(data: data, target: target)
    if listener.once {
      listener.stop()
    }
  }
}

private func emitAnyEvent (event: AnyEvent, targets: [AnyObject], data: Any?) {
  for target in targets {
    emitAnyEvent(event, target, data)
  }
}

class AnyEventListener {
  
  let event: String
  
  let onNewEvent: (data: Any?, target: AnyObject?) -> Void
  
  let once: Bool
  
  private(set) var isListening = false
  
  func start () {
    if isListening { return }
    isListening = true

    cachedRef.object = self
    cachedRef.strong = once
    var listeners = eventListenerCache[self.event].unwrap([])
    listeners += cachedRef
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

  private init (_ target: AnyObject?, _ event: String, _ onNewEvent: (data: Any?, target: AnyObject?) -> Void, _ once: Bool = false) {
    self.event = event + hashify(target)
    self.onNewEvent = onNewEvent
    self.once = once
    start()
  }
  
  private let cachedRef = Reference<AnyEventListener>()
}

class VoidEventListener : AnyEventListener {
  
  init (_ target: AnyObject?, _ event: String, _ onNewEvent: (target: AnyObject?) -> Void, _ once: Bool = false) {
    super.init(target, event, { _, target in onNewEvent(target: target) }, once)
  }
  
  init (_ target: AnyObject?, _ event: String, _ onNewEvent: Void -> Void, _ once: Bool = false) {
    super.init(target, event, { _, _ in onNewEvent() }, once)
  }
  
}

class EventListener <EventData: Any> : AnyEventListener {
  
  init (_ target: AnyObject?, _ event: String, _ onNewEvent: (data: EventData, target: AnyObject?) -> Void, _ once: Bool = false) {
    super.init(target, event, { data, target in onNewEvent(data: data as EventData, target: target) }, once)
  }
  
  init (_ target: AnyObject?, _ event: String, _ onNewEvent: (data: EventData) -> Void, _ once: Bool = false) {
    super.init(target, event, { data, _ in onNewEvent(data: data as EventData) }, once)
  }
  
}

extension AnyEvent {

  func listeners <Listener : AnyEventListener> (target: AnyObject? = nil) -> [Listener] {
    let event = id + hashify(target)
    return eventListenerCache[event].unwrap([]).reduce([], combine: {
      (var results, ref) in
      
      if let listener = ref.object {
        results += listener as Listener
      }
      
      else {
        removeEventListener(event, ref)
      }
    
      return results
    })
  }

}

private var eventListenerCache = [String:[Reference<AnyEventListener>]]()

private func removeEventListener (event: String, cachedRef: Reference<AnyEventListener>) {
  if var listeners = eventListenerCache[event] {
    removeObject(&listeners, cachedRef)
    eventListenerCache[event] = listeners.count > 0 ? listeners : nil
  }
}

private extension Optional {
  func unwrap (defaultValue: @auto_closure () -> T) -> T {
    return self ? self! : defaultValue()
  }
}

/// Returns a unique id based on the given AnyObject plus an optional String
private func hashify (object: AnyObject?) -> String {
  return object.getLogicValue() ? String(object!.hash) : ""
}

private func findObject<T: AnyObject>(array: [T], object: T) -> Int? {
  for (idx, element) in enumerate(array) {
    if element === object { return idx }
  }
  return nil
}

private func removeObject<T: AnyObject>(inout array: [T], object: T) -> Bool {
  if let idx = findObject(array, object) {
    array.removeAtIndex(idx)
    return true
  }
  return false
}

/// Most useful for Array storage of dynamically weak/strong object references
private class Reference <T: AnyObject> {
  
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
      if _strongObj {
        _strong = true
        _weakObj = nil
      }
    }
  }
  
  /// Cannot exist when "_strongObj" exists
  weak var _weakObj: T? {
    didSet {
      if _weakObj {
        _strong = false
        _strongObj = nil
      }
    }
  }
}
