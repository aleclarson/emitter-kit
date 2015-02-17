
import Foundation

class Event <EventData: Any> : AnyEvent {

  // MARK: Instance Methods

  func on (handler: EventData -> Void) -> EventListener {
    return super.on(nil, castData(handler))
  }
  
  func on (target: AnyObject, _ handler: EventData -> Void) -> EventListener {
    return super.on(target, castData(handler))
  }
  
  func once (handler: EventData -> Void) -> EventListener {
    return super.once(nil, castData(handler))
  }
  
  func once (target: AnyObject, _ handler: EventData -> Void) -> EventListener {
    return super.once(target, castData(handler))
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
  
  // MARK: Constructors
  
  override init (_ name: String! = nil) {
    super.init(name)
  }
  
  // MARK: Private
  
  private func castData (handler: EventData -> Void)(data: Any!) {
    handler(data as EventData)
  }
}

class VoidEvent : AnyEvent {

  // MARK: Instance Methods
  
  func on (handler: VoidFunc) -> EventListener {
    return super.on(nil, ignoreData(handler))
  }
  
  func on (target: AnyObject, _ handler: VoidFunc) -> EventListener {
    return super.on(target, ignoreData(handler))
  }
  
  func once (handler: VoidFunc) -> EventListener {
    return super.once(nil, ignoreData(handler))
  }
  
  func once (target: AnyObject, _ handler: VoidFunc) -> EventListener {
    return super.once(target, ignoreData(handler))
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
  
  // MARK: Constructors

  override init (_ name: String! = nil) {
    super.init(name)
  }
  
  // MARK: Private
  
  private func ignoreData (handler: VoidFunc)(_: Any!) {
    handler()
  }
}

class Notification : AnyEvent {

  // MARK: Instance Methods

  func on (handler: NSDictionary -> Void) -> EventListener {
    return super.on(nil, castData(handler))
  }
  
  func on (target: AnyObject, _ handler: NSDictionary -> Void) -> EventListener {
    return super.on(target, castData(handler))
  }
  
  func once (handler: NSDictionary -> Void) -> EventListener {
    return super.once(nil, castData(handler))
  }
  
  func once (target: AnyObject, _ handler: NSDictionary -> Void) -> EventListener {
    return super.once(target, castData(handler))
  }
  
  // MARK: Constructors
  
  init (_ name: String) {
    super.init(name)
    observer = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil, usingBlock: emit)
  }
  
  // MARK: Private
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(observer)
  }
  
  private var observer: NSObjectProtocol!
  
  private func emit (notif: NSNotification!) {
    emit(notif.object, notif.userInfo)
  }
  
  private func castData (handler: NSDictionary -> Void)(data: Any!) {
    handler(data as NSDictionary)
  }
}

class AnyEvent : Printable {

  // MARK: Read-write

  var debug = false

  // MARK: Read-only

  let name: String!
  
  private(set) var listenerCount = 0
  
  var description: String {
    return "(AnyEvent { name: \(name), listenerCount: \(listenerCount) })"
  }
  
  // MARK: Instance Methods
  
  func listenersForTarget (_ target: AnyObject? = nil) -> [EventListener] {
    let thash = hashify(target)
  
    var listeners = [EventListener]()
    
    var references = targets[thash] ?? [:]
    
    for (lhash, ref) in references {
      if let listener = ref.object {
        listeners.append(listener)
      } else {
        --listenerCount
        references[lhash] = nil
      }
    }
    
    targets[thash] = references.nilIfEmpty
    
    return listeners
  }
  
  func addListener (listener: EventListener) {
    ++listenerCount
    let thash = hashify(listener.target)
    var references = targets[thash] ?? [:]
    references[hashify(listener)] = ReferenceMake(listener, isWeak: !listener.once)
    targets[thash] = references
  }
  
  func removeListener (listener: EventListener) {
    --listenerCount
    let thash = hashify(listener.target)
    if var references = targets[thash] {
      references[hashify(listener)] = nil
      targets[thash] = references.nilIfEmpty
    }
  }
  
  func clearListeners () {
    targets = [:]
  }
  
  // MARK: Private
  
  // hashify(EventListener.target) -> hashify(EventListener) -> Reference<EventListener>
  private var targets = [String:[String:Reference<EventListener>]]()
  
  private func on (target: AnyObject!, _ handler: Any! -> Void) -> EventListener {
    return EventListener(event: self, target: target, handler: handler)
  }
  
  private func once (target: AnyObject!, _ handler: Any! -> Void) -> EventListener {
    return EventListener(event: self, target: target, handler: handler, once: true)
  }
  
  private func emit (target: AnyObject!, _ data: Any?) {
    printIfDebugging(listenerCount, target, data)
    for listener in listenersForTarget(target) { listener.trigger(data) }
  }
  
  private func emit (targets: [AnyObject], _ data: Any?) {
    for target in targets { emit(target, data) }
  }
  
  private func printIfDebugging (listeners: Int, _ target: AnyObject?, _ data: Any?) {
    if !debug { return }
    println("Event: {\n  name: \(name), listeners: \(listeners), target: \(target), data: \(data)  \n}")
  }
  
  private init (_ name: String? = nil) {
    self.name = name
  }
}
