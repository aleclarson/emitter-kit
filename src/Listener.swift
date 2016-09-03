
public func += (storage: inout [Listener], listener: Listener) {
  storage.append(listener)
}

open class Listener {

  open var isListening: Bool {
    get { return listening }
    set {
      if listening == newValue { return }
      listening = newValue
      if listening { startListening() }
      else { stopListening() }
    }
  }

  weak var target: AnyObject!

  let handler: (Any!) -> Void

  let once: Bool

  let targetID: String

  var listening = false

  func startListening () {}

  func stopListening () {}

  func trigger (_ data: Any!) {
    handler(data)
    if once { isListening = false }
  }

  init (_ target: AnyObject!, _ handler: @escaping (Any!) -> Void, _ once: Bool) {

    targetID = (target as? String) ?? getHash(target)

    if !(target is String) { self.target = target }

    self.handler = handler

    self.once = once

    isListening = true
  }

  deinit {
    isListening = false
  }
}
