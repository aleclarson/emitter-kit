
import Foundation

private var registeredEvents = [String:AnyEvent]()

class AnyEvent {

  let id: String
  
  class func events () -> [String:AnyEvent] {
    return registeredEvents
  }
  
  private init (_ id: String) {
    if registeredEvents[id] != nil { fatalError("Event ID must be unique.") }
    self.id = id
    registeredEvents[id] = self
  }
  
  private func emit (target: AnyObject?, _ data: Any?) {
    for listener in listeners(target: target) {
      listener.handler(data: data, target: target)
      if listener.once { listener.stop() }
    }
  }
  
  private func emit (targets: [AnyObject], _ data: Any?) {
    for target in targets { emit(target, data) }
  }
}

class VoidEvent : AnyEvent {

  init () {
    super.init(NSUUID().UUIDString)
  }

  override init (_ id: String) {
    super.init(id)
  }
  
  func emit () {
    super.emit(nil, nil)
  }
  
  func emit (target: AnyObject) {
    super.emit(target, nil)
  }
  
  func emit (targets: [AnyObject]) {
    super.emit(targets, nil)
  }
  
  func on (handler: Void -> Void) -> VoidEventListener {
    return VoidEventListener(nil, id, handler)
  }
  
  func on (target: AnyObject, _ handler: Void -> Void) -> VoidEventListener {
    return VoidEventListener(target, id, handler)
  }
  
  func once (handler: Void -> Void) -> VoidEventListener {
    return VoidEventListener(nil, id, handler, true)
  }
  
  func once (target: AnyObject, _ handler: Void -> Void) -> VoidEventListener {
    return VoidEventListener(target, id, handler, true)
  }
}

class Event <EventData: Any> : AnyEvent {

  init () {
    super.init(NSUUID().UUIDString)
  }

  override init (_ id: String) {
    super.init(id)
  }
  
  func emit (data: EventData) {
    super.emit(nil, data)
  }

  func emit (target: AnyObject, _ data: EventData) {
    super.emit(target, data)
  }
  
  func emit (targets: [AnyObject], _ data: EventData) {
    super.emit(targets, data)
  }
  
  func on (handler: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(nil, id, handler)
  }
  
  func on (target: AnyObject, _ handler: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(target, id, handler)
  }
  
  func once (handler: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(nil, id, handler, true)
  }
  
  func once (target: AnyObject, _ handler: EventData -> Void) -> EventListener<EventData> {
    return EventListener<EventData>(target, id, handler, true)
  }
}
