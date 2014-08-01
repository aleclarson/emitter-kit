# Typed Events for Swift

This library aims to be a fresh alternative to `NSNotificationCenter` for Swift lovers.

--

### Sample code

```Swift
// Global scope

let evtError: Event<NSError>("evtError")

// Class scope

var events = [AnyEventListener]()

// Function scope

// React to an event many times (must retain the returned EventListener)
events += evtError.on { error in
  println(error.localizedDescription)
}

// React to an event one time only (no need to retain the returned EventListener)
evtError.once { error in
  println(error.localizedDescription)
}

// Broadcast an event with an NSError attached
evtError.emit(error)
```

--

### Features

- Generic `Event<>`s and `EventListener<>`s for type safety
- Broadcast an `Event` to a specific object with `evtMyEvent.emit(object)`
- Broadcast an `Event` globally with `evtMyEvent.emit()`
- `VoidEvent` and `VoidEventListener` act as substitutes for `Event<Void` and `EventListener<Void>` (which do not work as expected)
- Stop and start an `EventListener` if you prefer to not deallocate it
- Refer to any `Event<>` with `AnyEvent` and to any `EventListener<>` with `AnyEventListener`
- Get an `AnyEvent`'s current listeners with `evtMyEvent.listeners(object)`

--

**More documentation will be added at a later date!**

Crafted by Alec Larson ([@aleclarsoniv](https://twitter.com/aleclarsoniv))
