
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
  
    view.once("frame") { (change: Change<NSValue>) in
      XCTAssertTrue(change.oldValue.cgRectValue == oldValue, "Change.oldValue has the wrong value")
      XCTAssertTrue(change.newValue.cgRectValue == self.view.frame, "Change.newValue has the wrong value")
      self.calls += 1
    }
    
    oldValue = view.frame
    view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    

    oldValue = view.frame
    view.frame = CGRect.zero
    
    XCTAssertTrue(calls == 1, "Single-use ChangeListener did not stop listening after being executed")
  }
  
  func testOn () {
    listener = view.on("backgroundColor") { (change: Change<UIColor>) in
      self.calls += 1
    }

    view.backgroundColor = UIColor.purple
    XCTAssertTrue(calls > 0, "ChangeListener was never called")

    view.backgroundColor = UIColor.red
    XCTAssertTrue(calls > 1, "ChangeListener stopped listening after being executed once")
  }
  
  func testOnDeinit () {
    listener = view.on("backgroundColor") { (change: Change<UIColor>) in
      self.calls += 1
    }
    listener = nil

    view.backgroundColor = UIColor.purple
    XCTAssertTrue(calls == 0, "ChangeListener did not stop listening on deinit")
  }
}
