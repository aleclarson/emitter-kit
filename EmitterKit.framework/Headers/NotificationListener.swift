
import Foundation

public class NotificationListener : Listener {
  
  public let name: String
  
  var observer: NSObjectProtocol!

  override func startListening() {
    observer = NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil, usingBlock: trigger)
  }
  
  override func stopListening() {
    NSNotificationCenter.defaultCenter().removeObserver(observer)
  }
  
  func trigger (notif: NSNotification!) {
    if target === notif.object { trigger(notif.userInfo) }
  }
  
  init (_ name: String, _ target: AnyObject!, _ handler: NSDictionary -> Void, _ once: Bool) {
    self.name = name
    super.init(target, { handler(($0 as? NSDictionary) ?? [:]) }, once)
  }
}
