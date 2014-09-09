
import Foundation

class Event <EventData: Any> : Emitter {

  // MARK: Instance Methods

  func on (handler: EventData -> Void) -> Listener {
    return super.on(nil, castData(handler))
  }
  
  func on (target: AnyObject, _ handler: EventData -> Void) -> Listener {
    return super.on(target, castData(handler))
  }
  
  func once (handler: EventData -> Void) -> Listener {
    return super.once(nil, castData(handler))
  }
  
  func once (target: AnyObject, _ handler: EventData -> Void) -> Listener {
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

class Signal : Emitter {

  // MARK: Instance Methods
  
  func on (handler: Void -> Void) -> Listener {
    return super.on(nil, ignoreData(handler))
  }
  
  func on (target: AnyObject, _ handler: Void -> Void) -> Listener {
    return super.on(target, ignoreData(handler))
  }
  
  func once (handler: Void -> Void) -> Listener {
    return super.once(nil, ignoreData(handler))
  }
  
  func once (target: AnyObject, _ handler: Void -> Void) -> Listener {
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
  
  private func ignoreData (handler: Void -> Void)(_: Any!) {
    handler()
  }
}

class Notification : Emitter {

  // MARK: Instance Methods

  func on (handler: NSDictionary -> Void) -> Listener {
    return super.on(nil, castData(handler))
  }
  
  func on (target: AnyObject, _ handler: NSDictionary -> Void) -> Listener {
    return super.on(target, castData(handler))
  }
  
  func once (handler: NSDictionary -> Void) -> Listener {
    return super.once(nil, castData(handler))
  }
  
  func once (target: AnyObject, _ handler: NSDictionary -> Void) -> Listener {
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
    handler((data ?? [:]) as NSDictionary)
  }
}

class Emitter : Printable {

  // MARK: Read-write

  /// If true, prints to the console when `emit` is called or a Listener deinits
  var debug = false

  // MARK: Read-only

  /// Helps you identify an Emitter when debugging
  let name: String!
  
  private(set) var listenerCount = 0
  
  var description: String {
    return "(Emitter { name: \(name), listenerCount: \(listenerCount) })"
  }
  
  // MARK: Instance Methods
  
  func listenersForTarget (_ target: AnyObject? = nil) -> [Listener] {
    return Array((targets[hashify(target)] ?? [:]).values)
  }
  
  func addListener (listener: Listener) {
    let tid = hashify(listener.target)
    var listeners = targets[tid] ?? [:]
    listeners[hashify(listener)] = listener
    targets[tid] = listeners
    ++listenerCount
  }
  
  func removeListener (listener: Listener) {
    let tid = hashify(listener.target)
    if var listeners = targets[tid] {
      let lid = hashify(listener)
      if listeners[lid] != nil {
        listeners[hashify(listener)] = nil
        targets[tid] = listeners.count > 0 ? listeners : nil
        --listenerCount
      }
    }
  }
  
  func removeAllListeners () {
    for (_, listeners) in targets {
      for (_, listener) in listeners {
        listener.isListening = false
      }
    }
  }
  
  // MARK: Private
  
  // hashify(Listener.target) -> hashify(Listener) -> Listener
  private var targets = [String:[String:Listener]]()
  
  private func on (target: AnyObject!, _ handler: Any! -> Void) -> Listener {
    return Listener(emitter: self, target: target, handler: handler)
  }
  
  private func once (target: AnyObject!, _ handler: Any! -> Void) -> Listener {
    return Listener(emitter: self, target: target, handler: handler, once: true)
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
    println("Emitter.emit(): {\n  name: \(name), listeners: \(listeners), target: \(target), data: \(data)  \n}")
  }
  
  private init (_ name: String? = nil) {
    self.name = name
  }
}

/// Creates a unique ID based on the object's memory address.
private func hashify (object: AnyObject?) -> String {
  return object != nil ? String(object!.hash!) : ""
}
