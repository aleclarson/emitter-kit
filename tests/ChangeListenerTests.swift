
import UIKit
import XCTest
import EmitterKit

class ChangeListenerTests: XCTestCase {

  var view: UIView!
  var listener: Listener!
  var calls = 0

  override func setUp() {
    super.setUp()
    
    view = UIView()
    listener = nil
    calls = 0
  }
  
  func testOnce () {
    var oldValue: CGRect!
  
    view.once("bounds") { (change: Change<NSValue>) in
      XCTAssertTrue(change.oldValue.CGRectValue() == oldValue, "Change.oldValue has the wrong value")
      XCTAssertTrue(change.newValue.CGRectValue() == self.view.bounds, "Change.newValue has the wrong value")
      self.calls += 1
    }
    
    oldValue = view.bounds
    view.bounds = CGRectMake(0, 0, 100, 100)
    
    oldValue = view.bounds
    view.bounds = CGRectZero
    
    XCTAssertTrue(calls == 1, "Single-use ChangeListener did not stop listening after being executed")
  }
  
  func testOn () {
    listener = view.on("backgroundColor") { (change: Change<UIColor>) in self.calls += 1 }
    view.backgroundColor = UIColor.purpleColor()
    view.backgroundColor = UIColor.redColor()
    
    XCTAssertTrue(calls == 2, "ChangeListener stopped listening after being executed once")
  }
  
  func testOnDeinit () {
    view.on("backgroundColor") { (change: Change<UIColor>) in self.calls += 1 }
    view.backgroundColor = UIColor.purpleColor()
    
    XCTAssertTrue(calls == 0, "NotificationListener did not stop listening on deinit")
  }
}
