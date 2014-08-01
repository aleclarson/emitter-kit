### Generic Events for Swift

This library aims to be a fresh alternative to `NSNotificationCenter` for Swift lovers. It adds `Event`, `EventListener`, `AnyEvent`, `AnyEventListener`, `VoidEvent`, and `VoidEventListener`.

--

#### In a nutshell

This library fixes three major annoyances I've had with `NSNotificationCenter`:

- Don't have to cast the event data to its appropriate type

- Don't have to call `NSNotificationCenter.removeObserver()` before your class is deallocated

- Observing just once is really easy

- More concise syntax

--

#### Sample code

```Swift
let evtError = Event<NSError>()

class MyClass {

  var events = [AnyEventListener]()

  init () {

    events += evtError.on { error in
      println(error.localizedDescription)
    }
    
    evtError.once { error in
      println(error.localizedDescription)
    }
    
    evtError.emit(error)
  
  }

}
```

--

#### How to use

`Event` and `EventListener` are generic. This is great for type-safety and it reduces the need for type-casting since the response type is static.

```Swift
let myEvent = Event<(Int, Int, Int)>()
let myListener = myEvent.on {
  println($0 + $1 + $2)
}
```

An `Event` can send data to its listeners with confidence they know what's coming. Additionally, you can associate a specific `AnyObject` when you trigger an event.

```Swift
myEvent.emit() // Without a target
myEvent.emit(myView) // With a target
```

If you want to communicate an event without any data, `VoidEvent` and `VoidEventListener` are here for you.

```Swift
let myEvent = VoidEvent()
let myListener = myEvent.on {
  println("No arguments necessary!")
}
```

If you only need to react to the event once, it's easy!

```Swift
myEvent.once(myView) {
  println("Only called once!")
}
```

When you want to treat `Event`s or `EventListener`s with different data types as equals (in an `Array` for example), you can use `AnyEvent` and `AnyEventListener`.

Get an `Array` of an `AnyEvent`'s active listeners with `myEvent.listeners(myView)`.

--

#### Related links

[Thread on Apple's Swift forum](https://devforums.apple.com/thread/238909)

[Thread on Swift subreddit](http://www.reddit.com/r/swift/comments/2cbh3b/generic_events_for_swift/)

--

Crafted by Alec Larson ([@aleclarsoniv](https://twitter.com/aleclarsoniv))
