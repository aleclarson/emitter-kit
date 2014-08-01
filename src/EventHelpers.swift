
import Foundation

extension Optional {
  func unwrap (defaultValue: @auto_closure () -> T) -> T {
    return self ? self! : defaultValue()
  }
}

/// Returns a unique id based on the given AnyObject plus an optional String
func hashify (object: AnyObject?) -> String {
  return object.getLogicValue() ? String(object!.hash) : ""
}

func findObject<T: AnyObject>(array: [T], object: T) -> Int? {
  for (idx, element) in enumerate(array) {
    if element === object { return idx }
  }
  return nil
}

func removeObject<T: AnyObject>(inout array: [T], object: T) -> Bool {
  if let idx = findObject(array, object) {
    array.removeAtIndex(idx)
    return true
  }
  return false
}

/// Most useful for Array storage of dynamically weak/strong object references
class Reference <T: AnyObject> {
  
  /// Use this in most situations
  var object: T? {
    get { return strong ? _strongObj : _weakObj }
    set {
      if strong { _strongObj = newValue }
      else { _weakObj = newValue }
    }
  }
  
  /// Holds a strong reference to the object when "true"
  var strong: Bool {
    get { return _strong }
    set {
      if strong == newValue { return }
      _strong = newValue
      if _strong { _strongObj = _weakObj }
      else { _weakObj = _strongObj }
    }
  }
  
  init () {}
  
  /// True value decoupled for internal change
  /// that avoids reference swapping.
  var _strong = false
  
  /// Cannot exist when "_weakObj" exists
  var _strongObj: T? {
    didSet {
      if _strongObj {
        _strong = true
        _weakObj = nil
      }
    }
  }
  
  /// Cannot exist when "_strongObj" exists
  weak var _weakObj: T? {
    didSet {
      if _weakObj {
        _strong = false
        _strongObj = nil
      }
    }
  }
}
