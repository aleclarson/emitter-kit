
# emitter-kit v5.2.2

![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EmitterKit.svg?style=flat)](https://cocoapods.org/pods/EmitterKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/EmitterKit.svg?style=flat)](http://cocoadocs.org/docsets/EmitterKit)

A replacement for `NSNotificationCenter#addObserver` and `NSObject#addObserver` that is **type-safe** and **not verbose**.

```swift
import EmitterKit

// A generic event emitter (but type-safe)!
var event = Event<T>()

// Any emitted data must be the correct type.
event.emit(data)

// This listener will only be called once.
// You are *not* required to retain it.
event.once { data: T in
  print(data)
}

// This listener won't stop listening;
// unless you stop it manually,
// or its Event<T> is deallocated.
// You *are* required to retain it.
var listener = event.on { data: T in
  print(data)
}

// Stop the listener manually.
listener.isListening = false

// Restart the listener (if it was stopped).
listener.isListening = true
```

&nbsp;

### Targeting

A **target** allows you to associate a specific `AnyObject` with an `emit` call. This is useful when emitting events associated with classes you can't add properties to (like `UIView`).

When calling `emit` with a target, you must also call `on` or `once` with the same target in order to receive the emitted event.

```Swift
let myView = UIView()
let didTouch = Event<UITouch>()

didTouch.once(myView) { touch in
  print(touch)
}

didTouch.emit(myView, touch)
```

&nbsp;

### NSNotification

The `Notifier` class helps when you are forced to use `NSNotificationCenter` (for example, if you want to know when the keyboard has appeared).

```swift
// You are **not** required to retain this after creating your listener.
var event = Notifier(UIKeyboardWillShowNotification)

// Handle NSNotifications with style!
listener = event.on { (notif: Notification) in
  print(notif.userInfo)
}
```

&nbsp;

### Key-Value Observation (KVO)

```swift
// Any NSObject descendant will work.
var view = UIView()

// "Make KVO great again!" - Donald Trump
listener = view.on("bounds") { (change: Change<CGRect>) in
  print(change)
}
```

&nbsp;

### Thread Safety

⚠️ None of the classes in EmitterKit are thread-safe!

The following actions must be done on the same thread, or you need manual locking:
- Emit an event
- Add/remove a listener
- Set the `isListening` property of a listener

&nbsp;

### v5.2.2 changelog

- Fixed protocol casting (#60)

### v5.2.1 changelog

- Fix Carthage compatibility for non iOS platforms

### v5.2.0 changelog

- Added the `Event.getListeners` method
- Listeners are now always called in the order they were added
- Event<Void>.emit() can be called without an argument
- Carthage support has been improved

### v5.1.0 changelog

- The `NotificationListener` class now takes a `Notification` instead of an `NSDictionary`.

- A `NotificationListener` without a target will now receive every `Notification` with its name, regardless of the value of `notif.object`.

### v5.0.0 changelog

- Swift 3.0 + Xcode 8.0 beta 6 support

- The `Signal` class was removed. (use `Event<Void>` instead)

- The `Emitter` abstract class was removed.

- The `EmitterListener` class was renamed `EventListener<T>`.

- The `Event<T>` class no longer has a superclass.

- The `Notification` class was renamed `Notifier` (to prevent collision with `Foundation.Notification`).

- The `on` and `once` methods of `Event<T>` now return an `EventListener<T>` (instead of just a `Listener`)

- The `on` and `once` methods of `Notifier` now return an `NotificationListener` (instead of just a `Listener`)

- The `on` and `once` methods of `NSObject` now return an `ChangeListener<T>` (instead of just a `Listener`)

- The `keyPath`, `options`, and `object` properties of `ChangeListener<T>` are now public.

- A `listenerCount: Int` computed property was added to the `Event<T>` class.

- An `event: Event<T>` property was added to the `EventListener<T>` class.

The changelog for older versions can be [found here](https://github.com/aleclarson/emitter-kit/wiki/Changelog).
