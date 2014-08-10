
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    window = UIWindow(frame: CGRectZero)
    window!.rootViewController = UIViewController()
    window!.makeKeyAndVisible()
    EventTests()
    return true
  }
}

