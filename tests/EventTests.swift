
var evtVoid = VoidEvent("evtVoid")

var evtInt = Event<Int>("evtInt")

var evtStringOptional = Event<String?>("evtStringOptional")

class EventTests {
  
  var events = EventListenerStorage()

  init () {
  
    // Test Event properties
  
      assert(evtVoid.id == "evtVoid")
    
    // Test without a target
    
      evtVoid.once {
        println("1: Should print only once")
      }
      
      events <= evtVoid.on {
        println("2: Should print twice")
      }
      
      evtVoid.emit()
      evtVoid.emit()
      
      assert(evtVoid.listeners().count == 1)
    
    // Test with a target
    
      evtVoid.once(self) {
        println("3: Should print only once")
      }
        
      events["myEvent"] = evtVoid.on(self) {
        println("4: Should print twice")
      }
    
      evtVoid.emit(self)
      evtVoid.emit(self)
  
      assert(evtVoid.listeners(self).count == 1)
    
    // Test with a required data type
    
      evtInt.once(evtInt) {
        println("5: evtInt { data: \($0) }")
      }
      
      evtInt.once(self) {
        println("6: evtInt { data: \($0) } <-- Should appear above #5")
      }
      
      evtInt.emit([self, evtInt], 420)
    
    // Test with an optional data type
    
      events <= evtStringOptional.on {
        println("7: evtStringOptional { data: \($0) }")
      }
      
      evtStringOptional.emit(nil)
      
      evtStringOptional.emit("Hello world")
    
    // Test EventListenerStorage subscripts
    
      let a = events[0]!
      println("8: events[0] exists")
    
      let b = events["myEvent"]!
      println("9: events[\"myEvent\"] exists")
    
    // Test EventListener properties
    
      assert(a.isListening)
      assert(!a.once)
      println("10: EventListener.event = \(a.event)")
    
      b.stop()
      assert(!b.isListening)
      println("11: EventListener.event = \(b.event)")
    
      b.start()
      assert(b.isListening)
  }
  
}
