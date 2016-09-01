
class EmitterListener : Listener {

  weak var emitter: Emitter!

  override func startListening () {
    if emitter == nil { return }
    var listeners = emitter.listeners[targetID] ?? [:]
    listeners[getHash(self)] = once ? StrongPointer(self) : WeakPointer(self)
    emitter.listeners[targetID] = listeners
  }

  override func stopListening () {
    if emitter == nil { return }
    var listeners = emitter.listeners[targetID]!
    listeners[getHash(self)] = nil
    emitter.listeners[targetID] = listeners.nilIfEmpty
  }

  init (_ emitter: Emitter, _ target: AnyObject!, _ handler: (Any!) -> Void, _ once: Bool) {
    self.emitter = emitter
    super.init(target, handler, once)
  }
}
