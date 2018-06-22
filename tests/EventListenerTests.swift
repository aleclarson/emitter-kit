
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
  
  func testOnStopBeforeEmit () {
    listener = event.on {
      self.calls += 1
    }
    listener.isListening = false

    event.emit()
    XCTAssertTrue(calls == 0, "'EventListener.isListening = false' has no effect")
  }

  // The listener is stopped while being triggered.
  func testOnStopDuringTrigger () {
    listener = event.on {
      self.calls += 1
      self.listener.isListening = false
    }

    event.emit()
    event.emit()
    XCTAssertTrue(calls == 1, "EventListener failed to remove itself during an emit")
  }

  // The listener is stopped during an emit, but before it is triggered.
  func testOnStopBeforeTrigger () {
    let before = event.on {
      self.calls += 1
      self.listener.isListening = false
    }
    listener = event.on {
      self.calls += 1
    }

    event.emit()
    XCTAssertTrue(calls == 1, "EventListener was triggered even though it was stopped")
  }
  
  func testEmitterDeinit () {
    listener = event.on {}
    event = nil

    XCTAssertFalse(listener.isListening, "EventListener did not stop listening after its Emitter turned nil")
  }
}
