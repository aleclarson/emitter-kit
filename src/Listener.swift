
import Foundation

class Listener {

  // MARK: Read-only

  unowned let emitter: Emitter
  
  private(set) weak var target: AnyObject!
  
  let once: Bool
  
  var isListening: Bool = true {
    didSet {
      if isListening == oldValue { return }
      if isListening { emitter.addListener(self) }
      else { emitter.removeListener(self) }
    }
  }
  
  // MARK: Instance Methods
  
  /// 💀 This can crash the program if passed the wrong type of data.
  /// I do not recommend using this.
  func trigger (data: Any!) {
    handler(data)
    if once { isListening = false }
  }
  
  // MARK: Constructors

  init (emitter: Emitter, target: AnyObject!, handler: Any! -> Void, once: Bool = false) {
    self.emitter = emitter
    self.target = target
    self.handler = handler
    self.once = once
    
    emitter.addListener(self)
  }
  
  convenience init (emitter: Emitter, handler: Any! -> Void, once: Bool = false) {
    self.init(emitter: emitter, target: nil, handler: handler, once: once)
  }
  
  // MARK: Private
  
  deinit {
    isListening = false
    if emitter.debug { println("Listener.deinit { target: \(target), emitter: \(emitter) }") }
  }
  
  private let handler: Any! -> Void
}

func += (storage: ListenerStorage, listener: Listener) {
  storage.array.append(listener)
}

class ListenerStorage {

  var count: Int { return array.count + dict.count }
  
  final lazy private(set) var array = [Listener]()
  
  final lazy private(set) var dict = [String:Listener]()
  
  subscript (key: String) -> Listener? {
    get { return dict[key] }
    set { dict[key] = newValue }
  }
  
  subscript (index: Int) -> Listener? {
    get {
      return index >= 0 && index < array.count ? array[index] : nil
    }
    set {
      if self[index] != nil {
        if newValue != nil {
          array[index] = newValue!
        } else {
          array.removeAtIndex(index)
        }
      }
    }
  }

  func removeAllListeners () {
    for listener in array { listener.isListening = false }
    for (_, listener) in dict { listener.isListening = false }
    array = []
    dict = [:]
  }
  
  deinit {
    removeAllListeners()
  }
}
