
import Foundation

func WeakPointer <T: Any> (_ object: T) -> DynamicPointer<T> {
  let ptr = DynamicPointer<T>()
  ptr.weakPointer = object
  return ptr
}

func StrongPointer <T: Any> (_ object: T) -> DynamicPointer<T> {
  let ptr = DynamicPointer<T>()
  ptr.strongPointer = object
  return ptr
}

class DynamicPointer <T: AnyObject> {

  var object: T! { return strongPointer ?? weakPointer ?? nil }

  init () {}

  var strongPointer: T!

  weak var weakPointer: T!
}

/// Generate a unique identifier for an object.
/// 2nd slowest. Converts to String.
func getHash (_ object: AnyObject) -> String {
  return String(identify(object))
}

/// Generate a unique identifier for an object.
/// Fastest. Every other function relies on this one.
func identify (_ object: AnyObject) -> UInt {
  return UInt(bitPattern: ObjectIdentifier(object))
}

/// Generate a unique identifier for an object.
/// Slowest. Checks for nil and converts to String.
func getHash (_ object: AnyObject?) -> String {
  return object == nil ? "0" : String(identify(object))
}

///// Generate a unique identifier for an object.
///// 2nd fastest. Checks for nil.
func identify (_ object: AnyObject?) -> UInt {
  return object == nil ? 0 : identify(object!)
}

extension Array {
  var nilIfEmpty: [Element]! { return count > 0 ? self : nil }
}

extension Dictionary {
  var nilIfEmpty: [Key:Value]! { return count > 0 ? self : nil }
}
