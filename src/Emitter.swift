
import Foundation

public class Emitter {
  
  // hashify(Listener.target) -> hashify(Listener) -> Listener
  var listeners = [String:[String:EmitterListener]]()
  
  func emit (target: AnyObject!, _ data: Any!) {
    for listener in Array((listeners[hashify(target)] ?? [:]).values) {
      listener.trigger(data)
    }
  }
  
  func emit (targets: [AnyObject], _ data: Any!) {
    for target in targets { emit(target, data) }
  }
  
  init () {}
}

/// Creates a unique ID based on the object's memory address.
func hashify (object: AnyObject?) -> String {
  return object != nil ? String(object!.hash!) : ""
}
