
import Foundation

func WeakPointer <T: AnyObject> (object: T) -> DynamicPointer<T> {
  let ptr = DynamicPointer<T>()
  ptr.weakPointer = object
  return ptr
}

func StrongPointer <T: AnyObject> (object: T) -> DynamicPointer<T> {
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
func getHash (object: AnyObject) -> String {
  return "\(identify(object))"
}

/// Generate a unique identifier for an object.
/// Fastest. Every other function relies on this one.
func identify (object: AnyObject) -> UInt {
  return ObjectIdentifier(object).uintValue
}

/// Generate a unique identifier for an object.
/// Slowest. Checks for nil and converts to String.
func getHash (object: AnyObject!) -> String {
  return "\(identify(object))"
}

/// Generate a unique identifier for an object.
/// 2nd fastest. Checks for nil.
func identify (object: AnyObject!) -> UInt {
  return object != nil ? identify(object!) : 0
}

extension Array {
  var nilIfEmpty: [Element]! { return count > 0 ? self : nil }
}

extension Dictionary {
  var nilIfEmpty: [Key:Value]! { return count > 0 ? self : nil }
}
