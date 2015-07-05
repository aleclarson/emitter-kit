
import XCTest
import EmitterKit

class NotificationListenerTests: XCTestCase {
  
  var listener: Listener!
  var event: Notification!
  var calls = 0

  override func setUp() {
    super.setUp()
    
    event = Notification("test")
    listener = nil
    calls = 0
  }
  
  func testOnce () {
    listener = event.once {
      XCTAssertNotNil($0["test"], "NotificationListener failed to receive intact NSDictionary")
      self.calls += 1
    }
    
    event.emit([ "test": true ])
    event.emit([ "test": true ])
    
    XCTAssertTrue(calls == 1, "Single-use NotificationListener did not stop listening after being executed")
  }

  func testOn () {
    listener = event.on { _ in self.calls += 1 }

    event.emit([:])
    event.emit([:])
    
    XCTAssertTrue(calls == 2, "NotificationListener stopped listening after one execution")
  }

  func testOnDeinit () {
    event.on { _ in self.calls += 1 }
    event.emit([:])
    
    XCTAssertTrue(calls == 0, "NotificationListener did not stop listening on deinit")
  }

  func testOnWithTarget () {

    let target = [:]

    listener = event.on(target) { _ in self.calls += 1 }

    event.emit(target, [:])
    event.emit(target, [:])

    XCTAssertTrue(calls == 2, "NotificationListener (with a target) stopped listening after one execution")
  }
}
