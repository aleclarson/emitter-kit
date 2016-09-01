
import Foundation

open class Notification {

  open let name: String

  public init (_ name: String) {
    self.name = name
  }

  /// Creates a Listener for an NSNotification.
  open func on (_ handler: (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, nil, handler, false)
  }

  /// Creates a Listener for an NSNotification with the given target.
  open func on (_ target: AnyObject!, _ handler: (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, target, handler, false)
  }

  /// Creates a single-use Listener for an NSNotification.
  open func once (_ handler: (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, nil, handler, true)
  }

  /// Creates a single-use Listener for an NSNotification with the given target.
  open func once (_ target: AnyObject!, _ handler: (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, target, handler, true)
  }

  /// Posts an NSNotification with the given name.
  open func emit (_ data: NSDictionary) {
    _emit(nil, data)
  }

  /// Posts an NSNotification with the given name, target, and data.
  open func emit (_ target: AnyObject, _ data: NSDictionary) {
    _emit(target, data)
  }

  /// Posts an NSNotification with the given name, targets, and data.
  open func emit (_ targets: [AnyObject], _ data: NSDictionary) {
    for target in targets { _emit(target, data) }
  }

  func _emit (_ target: AnyObject!, _ data: NSDictionary!) {
    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: name), object: target, userInfo: data as [NSObject : AnyObject])
  }
}
