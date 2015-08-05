# emitter-kit v4.0.1 [![frozen](http://badges.github.io/stability-badges/dist/frozen.svg)](https://nodejs.org/api/documentation.html#documentation_stability_index)

&nbsp;

This library provides these 5 major classes:

&nbsp;&nbsp;&nbsp;&nbsp;
[**Event**](https://github.com/aleclarson/emitter-kit/wiki/Events-&-Signals)
: A type-safe event emitter.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Signal**](https://github.com/aleclarson/emitter-kit/wiki/Events-&-Signals#signal)
: An event emitter that doesn't pass any data.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Listener**](https://github.com/aleclarson/emitter-kit/wiki/Event-Listeners)
: An event listener!

&nbsp;&nbsp;&nbsp;&nbsp;
[**Notification**](https://github.com/aleclarson/emitter-kit/wiki/Notifications)
: Backwards-compatibility with `NSNotification`.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Change**](https://github.com/aleclarson/emitter-kit/wiki/Observing-Changes)
: Key-value observation made easy.

&nbsp;

-

### Motivation

`NSNotification` & `NSNotificationCenter` are rather verbose and fail to provide type-safety. This library aims to streamline your work with event emitters & listeners while programming with Swift. It aims to stay as simple as possible without removing powerful features.

&nbsp;

-

### Changelog

This is a list of notable changes in each version of **emitter-kit**. Many versions include unlisted bug fixes and refactoring. Some changes may not be listed (unintentionally).

#### v4.0.1

- Xcode 7.0 Beta 4 compatible

#### v4.0.0

- Swift 2.0 compatible

#### v3.2.1

- Swift 1.3 compatible

#### v3.2.0

- Swift 1.2 compatible

#### v3.1.0

- Added `isPrior: Boolean` to the `Change` class.

#### v3.0.0

- Added `NotificationListener`, `EmitterListener`, and `ChangeListener` (all subclasses of `Listener`).

- Added `Change`, a generic class with an `oldValue`, a `newValue`, and a `keyPath`.

- All `NSObject`s have an `on()` and `once()` method for KVO!

- `Notification` does not subclass `Emitter` anymore.

- `Notification` now has `emit` methods that create `NSNotification`s under the hood.

- `Notification` no longer need to be retained.

- Removed `emitter.removeAllListeners()`.

- Removed `emitter.listenersForTarget(target: AnyObject)`.

- Removed `ListenerStorage` completely. Try using an `[Listener]` or `[String:Listener]`.

- Removed many exposed internal functions.

#### v2.0.0

- Renamed `VoidEvent` to `Signal`.

- Renamed `AnyEvent` to `Emitter`.

- Renamed `EventListener` to `Listener`.

- Renamed `EventListenerStorage` to `ListenerStorage`.

- Renamed `emitter.clearListeners()` to `emitter.removeAllListeners()`.

#### v1.0.0

- Xcode 6.0 Beta 5 compatible

&nbsp;
