
import Foundation

extension NSNotification {
  /// Creates a Listener for an NSNotification.
  public func on (name: String, handler: NSDictionary -> Void) -> NSNotificationListener {
    return NSNotificationListener(name, nil, handler, false)
  }

  /// Creates a Listener for an NSNotification with the given target.
  public func on (name: String, target: AnyObject!, handler: NSDictionary -> Void) -> NSNotificationListener {
    return NSNotificationListener(name, target, handler, false)
  }

  /// Creates a single-use Listener for an NSNotification.
  public func once (name: String, handler: NSDictionary -> Void) -> NSNotificationListener {
    return NSNotificationListener(name, nil, handler, true)
  }

  /// Creates a single-use Listener for an NSNotification with the given target.
  public func once (name: String, target: AnyObject!, handler: NSDictionary -> Void) -> NSNotificationListener {
    return NSNotificationListener(name, target, handler, true)
  }

  /// Posts an NSNotification with the given name.
  public func emit (name: String, data: NSDictionary) {
    _emit(name, nil, data)
  }

  /// Posts an NSNotification with the given name, target, and data.
  public func emit (name: String, target: AnyObject, data: NSDictionary) {
    _emit(name, target, data)
  }

  /// Posts an NSNotification with the given name, targets, and data.
  public func emit (name: String, targets: [AnyObject], data: NSDictionary) {
    for target in targets { _emit(name, target, data) }
  }
}

func _emit (name: String, target: AnyObject!, data: NSDictionary!) {
  NSNotificationCenter.defaultCenter().postNotificationName(name, object: target, userInfo: data)
}
