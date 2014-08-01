
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
