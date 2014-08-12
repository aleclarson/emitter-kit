## Generic Events for Swift

This library is an alternative to [`NSNotificationCenter`](http://nshipster.com/nsnotification-and-nsnotificationcenter/). It works with **Xcode 6 Beta 5**!

&nbsp;&nbsp;&nbsp; [**Benefits**](#benefits)

&nbsp;&nbsp;&nbsp; [**Example**](#example)

&nbsp;&nbsp;&nbsp; **Events**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [Event](#event)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [VoidEvent](#voidevent)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [AnyEvent](#anyevent)

&nbsp;&nbsp;&nbsp; **Event Listeners**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [EventListener](#eventlistener)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [EventListenerStorage](#eventlistenerstorage)

---

### Benefits

- Event data is automatically casted to the expected type! :v:

- No need for `NSNotificationCenter.removeObserver()` in your class's `deinit`!

- Built-in support for one-time event handling!

- Less typing, more swifting!

---

### Example

```Swift
let evtError = Event<NSError>()

class MyClass {

  let events = EventListenerStorage()

  init () {

    events <= evtError.on {
      println($0.localizedDescription)
    }
    
    evtError.once {
      println($0.localizedDescription)
    }
    
    evtError.emit(error)
  
  }

}
```

---

### Event

Every `Event` has its own `EventData` type that must be of `Any` type. Here are some examples:

```Swift
Event<Any>()
Event<UIView>()
Event<String?>()
Event<(Int, Int, Int)>()
```

You will normally want to declare an `Event` as a constant and in the global scope. 

`Event` is a subclass of [`AnyEvent`]().

#### Constructors

`init ()`

> Initializes an `Event` with a random `id`

`init (String)`

> Initializes an `Event` with the given `id`

#### Methods

`func emit (EventData)`

> Sends data to all `EventListener`s (if any exist)

`func emit (AnyObject, EventData)`

> Sends data to all `EventListener`s (if any exist) with the same target

`func emit ([AnyObject], EventData)`

> Sends data to all `EventListener`s (if any exist) with one of the given targets

`func on (EventData -> Void) -> EventListener`

> Creates a new `EventListener` for this `Event`. **Must be retained!**

`func on (AnyObject, EventData -> Void) -> EventListener`

> Creates a new `EventListener` with a target. **Must be retained!**

`func once (EventData -> Void) -> EventListener`

> Creates a new `EventListener` that reacts to this `Event` only one time. Doesn't need to be retained.

`func once (AnyObject, EventData -> Void) -> EventListener`

> Creates a new `EventListener` with a target that reacts to this `Event` only one time. Doesn't need to be retained.

---

### VoidEvent

If no data needs to be passed, a `VoidEvent` does the job well!

`VoidEvent` is a subclass of [`AnyEvent`]().

#### Constructors

`init ()`

> Initializes a `VoidEvent` with a random `id`

`init (String)`

> Initializes a `VoidEvent` with the given `id`

#### Methods

`func emit ()`

> Notify all `EventListener`s (if any exist)

`func emit (AnyObject)`

> Notify all `EventListener`s (if any exist) with the same target

`func emit ([AnyObject])`

> Notify all `EventListener`s (if any exist) with one of the given targets

`func on (Void -> Void) -> EventListener`

> Creates a new `EventListener` for this `VoidEvent`. **Must be retained!**

`func on (AnyObject, Void -> Void) -> EventListener`

> Creates a new `EventListener` with a target. **Must be retained!**

`func once (Void -> Void) -> EventListener`

> Creates a new `EventListener` that reacts to this `VoidEvent` only one time. Doesn't need to be retained.

`func once (AnyObject, Void -> Void) -> EventListener`

> Creates a new `EventListener` with a target that reacts to this `VoidEvent` only one time. Doesn't need to be retained.

#### Why can't I just use `Event<Void>`?

Good question! If you try doing that, Swift forces you to type `myEvent.emit(())`. This obviously sucks, so `VoidEvent` is here to save the day!

---

### AnyEvent

`AnyEvent` is an abstract class. It allows you to treat `Event`s with different `EventData` types (and `VoidEvent`s) as the same types. One good use of this is with `Array`s and `Dictionary`s.

#### Properties

`let id: String`

> The unique identifier

#### Methods

`class func events () -> [String:AnyEvent]`

> Returns a `Dictionary` of all existing events

`func listeners () -> [EventListener]`

> All `EventListener`s for this `AnyEvent`

`func listeners (AnyObject) -> [EventListener]`

> All `EventListener`s for this `AnyEvent` with the same target

---

### EventListener

You construct an `EventListener` when you call an `Event`'s `on()` or `once()` method.

#### Properties

`let event: String`

> The `Event`'s `id` (plus the `target`'s unique identifier if it exists)

`let handler: Any? -> Void`

> The closure to execute when the `Event` is emitted

`let once: Bool`

> Equal to `true` if the `EventListener` destroys itself after one time

`let isListening: Bool`

> Equal to `true` if the `EventListener` will react to the next `Event`

#### Methods

`func start ()`

> Attaches the `EventListener` to its `Event`. Does nothing if `isListening` is `true`.

`func stop ()`

> Detaches the `EventListener` from its `Event`. Does nothing if `isListening` is `false`.

---

### EventListenerStorage

A nice place to retain the `EventListener`s returned from `Event`'s `on()` method.

#### Properties

`let array: [EventListener]`

> The `EventListener`s retained under an `Int`

`let dict: [String:EventListener]`

> The `EventListener`s retained under a `String`

#### Methods

`subscript (String) -> EventListener?`

> Use `events["my event"]` when you need to reference the `EventListener` at a later time. Both getting and setting are safe to do.

`subscript (Int) -> EventListener?`

> Use `events[0]` to safely get the first `EventListener` you added to `array`. You can also overwrite an `EventListener` with `events[0] = ...`. **Please note:** A crash occurs if you try to use an `Int` that is out of bounds.

`func clear ()`

> Deallocates all `EventListener`s in `array` and `dict`

#### Operators

`func <= (EventListenerStorage, EventListener)`

> Appends the `EventListener` to the end of `array`. You'll probably use this most often.

---

Crafted by Alec Larson [@aleclarsoniv](https://twitter.com/aleclarsoniv)
