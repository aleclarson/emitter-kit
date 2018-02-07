
import XCTest
import EmitterKit

class EventListenerTests: XCTestCase {

  var event: Event<Void>!

  var listener: Listener!
  
  var calls = 0

  override func setUp() {
    super.setUp()

    event = Event()
    listener = nil
    calls = 0
  }

  func testCallOrder () {
    var calls = [Int]()
    let listeners = [Int](0..<5).map {
      (i) in event.on { calls.append(i) }
    }

    event.emit()
    XCTAssertEqual(calls, [0, 1, 2, 3, 4])
  }

  func testOnce () {
    event.once {
      self.calls += 1
    }

    event.emit()
    XCTAssertTrue(calls > 0, "Single-use EventListener was not called")

    event.emit()
    XCTAssertTrue(calls == 1, "Single-use EventListener never stopped listening")
  }

  func testOn () {
    listener = event.on {
      self.calls += 1
    }

    event.emit()
    XCTAssertTrue(calls > 0, "EventListener was never called")

    event.emit()
    XCTAssertTrue(calls > 1, "EventListener stopped listening after one execution")
  }
  
  func testOnDeinit () {
    listener = event.on {
      self.calls += 1
    }
    listener = nil

    event.emit()
    XCTAssertTrue(calls == 0, "EventListener did not stop listening on deinit")
  }
  
  func testEmitterDeinit () {
    listener = event.on {}
    event = nil
    
    XCTAssertFalse(listener.isListening, "EventListener did not stop listening after its Emitter turned nil")
  }
}
