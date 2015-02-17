
import XCTest
import EmitterKit

class PerformanceTests : XCTestCase {

  var listeners = [Listener]()

  override func setUp() {
    super.setUp()
    listeners = []
  }

  func testNotificationPerformance () {
    let n = Notification("test1")

    for _ in 0...99 {
      self.listeners += n.on { _ in }
    }

    measureBlock {
      for _ in 0...99 {
        n.emit([:])
      }
    }
  }

  func testEmitterPerformance () {
    let e = Event<NSDictionary>()

    for _ in 0...99 {
      self.listeners += e.on { _ in }
    }

    measureBlock {
      for _ in 0...99 {
        e.emit([:])
      }
    }
  }
}
