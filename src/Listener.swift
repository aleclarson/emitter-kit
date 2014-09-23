
public func += (inout storage: [Listener], listener: Listener) {
  storage.append(listener)
}

public class Listener {
  
  public var isListening: Bool {
    get { return listening }
    set {
      if listening == newValue { return }
      listening = newValue
      if listening { startListening() }
      else { stopListening() }
    }
  }
  
  weak var target: AnyObject!
  
  let handler: Any! -> Void
  
  let once: Bool
  
  let targetID: String
  
  var listening = false
  
  func startListening () {}
  
  func stopListening () {}
  
  func trigger (data: Any!) {
    handler(data)
    if once { isListening = false }
  }
  
  init (_ target: AnyObject!, _ handler: Any! -> Void, _ once: Bool) {
    self.target = target
    self.handler = handler
    self.once = once
    
    targetID = hashify(target)
    isListening = true
  }
  
  deinit {
    isListening = false
  }
}
