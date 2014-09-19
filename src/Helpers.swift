
import Foundation

func WeakPointer <T: AnyObject> (object: T) -> Pointer<T> {
  var ptr = Pointer<T>()
  ptr.weakPointer = object
  return ptr
}

func StrongPointer <T: AnyObject> (object: T) -> Pointer<T> {
  var ptr = Pointer<T>()
  ptr.strongPointer = object
  return ptr
}

struct Pointer <T: AnyObject> {

  var object: T! { return strongPointer ?? weakPointer ?? nil }
  
  init () {}
  
  var strongPointer: T!
  
  weak var weakPointer: T!
}

/// Creates a unique ID based on the object's memory address.
func hashify (object: AnyObject?) -> String {
  return object != nil ? String(object!.hash!) : ""
}

extension Array {
  var nilIfEmpty: [T]! { return count > 0 ? self : nil }
}

extension Dictionary {
  var nilIfEmpty: [Key:Value]! { return count > 0 ? self : nil }
}
