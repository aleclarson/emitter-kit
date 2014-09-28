
import Foundation

func WeakDynamicPointer <T: AnyObject> (object: T) -> DynamicPointer<T> {
  var ptr = DynamicPointer<T>()
  ptr.weakPointer = object
  return ptr
}

func StrongDynamicPointer <T: AnyObject> (object: T) -> DynamicPointer<T> {
  var ptr = DynamicPointer<T>()
  ptr.strongPointer = object
  return ptr
}

struct DynamicPointer <T: AnyObject> {

  var object: T! { return strongPointer ?? weakPointer ?? nil }
  
  init () {}
  
  var strongPointer: T!
  
  weak var weakPointer: T!
}

func getHash (object: AnyObject) -> String {
  return "\(ObjectIdentifier(object).uintValue())"
}

func getHash (object: AnyObject!) -> String {
  return object == nil ? "" : getHash(object!)
}

extension Array {
  var nilIfEmpty: [T]! { return count > 0 ? self : nil }
}

extension Dictionary {
  var nilIfEmpty: [Key:Value]! { return count > 0 ? self : nil }
}
