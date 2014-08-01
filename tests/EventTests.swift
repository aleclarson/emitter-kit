
var evtVoid = VoidEvent("evtVoid")

var evtInt = Event<Int>("evtInt")

class EventTests {
  
  var events = [AnyEventListener]()

  init () {
  
    assert(evtVoid.id == "evtVoid")
    
    // Test without a target
    
    evtVoid.once {
      println("1: Should print only once")
    }
    
    events += evtVoid.on {
      println("2: Should print twice")
    }
    
    evtVoid.emit()
    evtVoid.emit()
    
    assert(evtVoid.listeners().count == 1)
    
    // Test with a target
    
    evtVoid.once(self) {
      println("3: Should print only once")
    }
    
    events += evtVoid.on(self) {
      println("4: Should print twice")
    }
    
    evtVoid.emit(self)
    evtVoid.emit(self)
  
    assert(evtVoid.listeners(target: self).count == 1)
    
    evtInt.once(evtInt) {
      println("5: evtInt { data: \($0) }")
    }
    
    evtInt.once(self) {
      println("6: evtInt { data: \($0) } <-- Should appear above #5")
    }
    
    evtInt.emit([self, evtInt], 420)
  }
  
}
