
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
    for listener in (target != nil ? listeners(target!) : listeners()) {
      listener.handler(data)
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
}
