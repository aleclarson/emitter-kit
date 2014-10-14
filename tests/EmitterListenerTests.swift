
import XCTest
import EmitterKit

class EmitterListenerTests: XCTestCase {

  var event: Signal!
  
  var listener: Listener!
  
  var calls = 0

  override func setUp() {
    super.setUp()
    
    event = Signal()
    listener = nil
    calls = 0
  }

  func testOnce () {
    event.once { self.calls += 1 }
    
    event.emit()
    event.emit()
    
    XCTAssertTrue(calls == 1, "Single-use EmitterListener didn't stop listening after one execution")
  }

  func testOn () {
    listener = event.on { self.calls += 1 }

    event.emit()
    event.emit()
    
    XCTAssertTrue(calls == 2, "EmitterListener stops listening after one execution")
  }
  
  func testOnDeinit () {
    event.on { self.calls += 1 }
    event.emit(1)
    
    XCTAssertTrue(calls == 0, "EmitterListener did not stop listening on deinit")
  }
  
  func testEmitterDeinit () {
    listener = event.on {}
    event = nil
    
    XCTAssertFalse(listener.isListening, "EmitterListener did not stop listening after its Emitter turned nil")
  }
}
