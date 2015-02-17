
import Foundation

public class Notification {

  public let name: String

  public init (_ name: String) {
    self.name = name
  }

  /// Creates a Listener for an NSNotification.
  public func on (handler: NSDictionary -> Void) -> NotificationListener {
    return NotificationListener(name, nil, handler, false)
  }

  /// Creates a Listener for an NSNotification with the given target.
  public func on (target: AnyObject!, _ handler: NSDictionary -> Void) -> NotificationListener {
    return NotificationListener(name, target, handler, false)
  }

  /// Creates a single-use Listener for an NSNotification.
  public func once (handler: NSDictionary -> Void) -> NotificationListener {
    return NotificationListener(name, nil, handler, true)
  }

  /// Creates a single-use Listener for an NSNotification with the given target.
  public func once (target: AnyObject!, _ handler: NSDictionary -> Void) -> NotificationListener {
    return NotificationListener(name, target, handler, true)
  }

  /// Posts an NSNotification with the given name.
  public func emit (data: NSDictionary) {
    _emit(name, nil, data)
  }

  /// Posts an NSNotification with the given name, target, and data.
  public func emit (target: AnyObject, _ data: NSDictionary) {
    _emit(name, target, data)
  }

  /// Posts an NSNotification with the given name, targets, and data.
  public func emit (targets: [AnyObject], _ data: NSDictionary) {
    for target in targets { _emit(name, target, data) }
  }
}

func _emit (name: String, target: AnyObject!, data: NSDictionary!) {
  NSNotificationCenter.defaultCenter().postNotificationName(name, object: target, userInfo: data)
}
