
import XCTest
import EmitterKit

class NotificationListenerTests: XCTestCase {
  
  var listener: Listener!
  var event: Notifier!
  var calls = 0

  override func setUp() {
    super.setUp()
    
    event = Notifier("test")
    listener = nil
    calls = 0
  }

  func testOnce () {
    listener = event.once {
      XCTAssertNotNil($0["test"], "NotificationListener failed to receive intact NSDictionary")
      self.calls += 1
    }

    event.emit([ "test": true ])
    XCTAssertTrue(calls > 0, "Single-use NotificationListener was not called")

    event.emit([ "test": true ])
    XCTAssertTrue(calls == 1, "Single-use NotificationListener never stopped listening")
  }

  func testOn () {
    listener = event.on { _ in
      self.calls += 1
    }

    event.emit([:])
    XCTAssertTrue(calls > 0, "NotificationListener was never called")

    event.emit([:])
    XCTAssertTrue(calls > 1, "NotificationListener stopped listening after one execution")
  }

  func testOnDeinit () {
    listener = event.on { _ in
      self.calls += 1
    }
    listener = nil

    event.emit([:])
    XCTAssertTrue(calls == 0, "NotificationListener did not stop listening on deinit")
  }

  func testOnWithTarget () {

    let target = NSObject()

    listener = event.on(target) { _ in
      self.calls += 1
    }

    event.emit([:], on: target)
    XCTAssertTrue(calls > 0, "NotificationListener (with a target) was never called")

    event.emit([:], on: target)
    XCTAssertTrue(calls > 1, "NotificationListener (with a target) stopped listening after one execution")
  }
}
