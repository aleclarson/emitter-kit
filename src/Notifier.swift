
import Foundation

public class Notifier {

  public let name: String

  public init (_ name: String) {
    self.name = name
  }

  public func on (_ handler: @escaping (NSDictionary) -> Void) -> NotificationListener {
    return NotificationListener(name, nil, false, handler)
  }

  public func on (_ target: AnyObject!, _ handler: @escaping (NSDictionary) -> Void) -> NotificationListener {
    return NotificationListener(name, target, false, handler)
  }

  @discardableResult
  public func once (_ handler: @escaping (NSDictionary) -> Void) -> NotificationListener {
    return NotificationListener(name, nil, true, handler)
  }

  @discardableResult
  public func once (_ target: AnyObject!, _ handler: @escaping (NSDictionary) -> Void) -> NotificationListener {
    return NotificationListener(name, target, true, handler)
  }

  public func emit (_ data: NSDictionary) {
    _emit(data, on: nil)
  }

  public func emit (_ data: NSDictionary, on target: AnyObject) {
    _emit(data, on: target)
  }

  public func emit (_ data: NSDictionary, on targets: [AnyObject]) {
    for target in targets {
      _emit(data, on: target)
    }
  }

  private func _emit (_ data: NSDictionary!, on target: AnyObject!) {
    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: name), object: target, userInfo: data as [NSObject : AnyObject])
  }
}
