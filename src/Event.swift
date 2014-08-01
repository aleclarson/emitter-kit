
class AnyEvent {
  
  let id: String
  
  required init (_ id: String) {
    if takenEventIDs[id] {
      println("Event ID \"\(id)\" is already taken.")
      fatalError("Error. See your console for details.")
    }
    
    self.id = id
    
    takenEventIDs[id] = true
  }
}

class VoidEvent : AnyEvent {

  init (_ id: String) {
    super.init(id)
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

  init (_ id: String) {
    super.init(id)
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
