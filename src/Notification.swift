
import Foundation

open class Notification {

  open let name: String

  public init (_ name: String) {
    self.name = name
  }

  /// Creates a Listener for an NSNotification.
  open func on (_ handler: @escaping (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, nil, handler, false)
  }

  /// Creates a Listener for an NSNotification with the given target.
  open func on (_ target: AnyObject!, _ handler: @escaping (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, target, handler, false)
  }

  /// Creates a single-use Listener for an NSNotification.
  open func once (_ handler: @escaping (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, nil, handler, true)
  }

  /// Creates a single-use Listener for an NSNotification with the given target.
  open func once (_ target: AnyObject!, _ handler: @escaping (NSDictionary) -> Void) -> Listener {
    return NotificationListener(name, target, handler, true)
  }

  /// Posts an NSNotification with the given name.
  open func emit (_ data: NSDictionary) {
    _emit(data, on: nil)
  }

  /// Posts an NSNotification with the given name, target, and data.
  open func emit (_ data: NSDictionary, on target: AnyObject) {
    _emit(data, on: target)
  }

  /// Posts an NSNotification with the given name, targets, and data.
  open func emit (_ targets: [AnyObject], _ data: NSDictionary) {
    for target in targets { _emit(data, on: target) }
  }

  func _emit (_ data: NSDictionary!, on target: Any!) {
    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: name), object: target, userInfo: data as [NSObject : AnyObject])
  }
}
