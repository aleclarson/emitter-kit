
import Foundation

class EventListener {

  // MARK: Read-only

  unowned let event: AnyEvent
  
  private(set) weak var target: AnyObject!
  
  let once: Bool
  
  var isListening: Bool = true {
    didSet {
      if isListening == oldValue { return }
      if isListening { event.addListener(self) }
      else { event.removeListener(self) }
    }
  }
  
  // MARK: Instance Methods
  
  func trigger (data: Any!) {
    handler(data)
    if once { isListening = false }
  }
  
  // MARK: Constructors

  init (event: AnyEvent, target: AnyObject!, handler: Any! -> Void, once: Bool = false) {
    self.event = event
    self.target = target
    self.handler = handler
    self.once = once
    
    event.addListener(self)
  }
  
  convenience init (event: AnyEvent, handler: Any! -> Void, once: Bool = false) {
    self.init(event: event, target: nil, handler: handler, once: once)
  }
  
  // MARK: Private
  
  deinit {
    isListening = false
    if event.debug { println("EventListener.deinit { target: \(target), event: \(event) }") }
  }
  
  private let handler: Any! -> Void
}
