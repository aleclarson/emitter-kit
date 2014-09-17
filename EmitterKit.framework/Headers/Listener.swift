
import Foundation

public func += (var storage: [Listener], listener: Listener) {
  storage.append(listener)
}

public class Listener {
  
  public private(set) weak var target: AnyObject!
  
  public let once: Bool
  
  public var isListening: Bool = true {
    didSet {
      if isListening == oldValue { return }
      if isListening { startListening() }
      else { stopListening() }
    }
  }
  
  private let handler: Any! -> Void
  
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
    
    startListening()
  }
  
  deinit {
    if isListening { stopListening() }
  }
}
