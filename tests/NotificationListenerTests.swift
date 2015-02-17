
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
    
    XCTAssertTrue(calls == 2, "NotificationListener listening after one execution")
  }
  
  func testOnDeinit () {
    event.on { _ in self.calls += 1 }
    event.emit([:])
    
    XCTAssertTrue(calls == 0, "NotificationListener did not stop listening on deinit")
  }
}



