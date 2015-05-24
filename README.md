# emitter-kit v3.2.1 [![frozen](http://badges.github.io/stability-badges/dist/frozen.svg)](https://nodejs.org/api/documentation.html#documentation_stability_index)

&nbsp;

This library provides these 5 major classes:

&nbsp;&nbsp;&nbsp;&nbsp;
[**Event**](#event) -- A type-safe event emitter.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Signal**](#signal) -- An event emitter that doesn't pass any data.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Listener**](#listener) -- An event listener!

&nbsp;&nbsp;&nbsp;&nbsp;
[**Notification**](#notification) -- Backwards-compatibility with `NSNotification`.

&nbsp;&nbsp;&nbsp;&nbsp;
[**Change**](#change) -- Key-value observation made easy.

&nbsp;

---

### Motivation

`NSNotification` & `NSNotificationCenter` are rather verbose and fail to provide type-safety. This library aims to streamline your work with event emitters & listeners while programming with Swift. It aims to stay as simple as possible without removing powerful features.

&nbsp;

---

### **Event**

An `Event` emits data. Its generic parameter specifies what type of data it emits! This is awesome.

All listeners are removed when an `Event` is deallocated.

```Swift
let didLogin = Event<User>()

didLogin.once { user in
  println("Successfully logged in as \(user.name)!")
}

didLogin.emit(user)
```

`Event` is a subclass of `Emitter`.

I tend to use `Event`s as properties of my Swift classes, when it makes sense.

```Swift   
class MyScrollView : UIScrollView, UIScrollViewDelegate {
  let didScroll = Event<CGPoint>()
  
  override init () {
    super.init()
    delegate = self
  }
  
  func scrollViewDidScroll (scrollView: UIScrollView) {
    didScroll.emit(scrollView.contentOffset)
  }
}
```

Otherwise, I can use a **target** to associate an `Event` with a specific `AnyObject`. This is useful for classes I cannot add properties to, like `UIView` for example.

```Swift
let myView = UIView()
let didTouch = Event<UITouch>()

didTouch.once(myView) {
  println("We have a winner! \($0)")
}

didTouch.emit(myView, touch)
```

&nbsp;

---

### **Signal**

A `Signal` is a subclass of `Emitter` that cannot pass data.

```Swift
let didLogout = Signal()

didLogout.once {
  println("Logged out successfully... :(")
}

didLogout.emit()
```

&nbsp;

---

### **Notification**

`Notification` wraps around `NSNotification` to provide backwards-compatibility with Apple's frameworks (e.g. `UIKeyboardWillShowNotification`) and third party frameworks. 

Use it to create `NotificationListener`s that will remove themselves when deallocated. Now, you no longer have to call `removeObserver()` in your deinit phase!

You **do not** need to retain a `Notification` for your listener to work correctly. This is one reason why `Notification` does not subclass `Emitter`.

```Swift
Notification(UIKeyboardWillShowNotification).once { data in
  println("keyboard showing. data: \(data)")
}
```

&nbsp;

---

### **Listener**

A `Listener` represents a closure that will be executed when an `Emitter` emits. 

When a `Listener` is constructed, it starts listening immediately.

Toggle on and off by setting the `isListening: Bool` property.

If a `Listener`'s `once: Bool` property `== true`, it will stop listening after it executes once.

**Important:** Remember to retain a `Listener` if `once == false`! Make a `[Listener]` property and put it there.

```Swift
var listeners = [Listener]()

// Retain that sucka
listeners += mySignal.on {
  println("beep")
}

// Single-use Listeners retain themselves ;)
mySignal.once {
  println("boop")
}
```

&nbsp;

---

### **Change**

Every `NSObject` is bestowed an `on()`, `once()`, and `removeListeners()` instance method.

This makes traditional Objective-C key-value observation much prettier on the eyes while programming with Swift.

```Swift
let myView = UIView()
let myProperty = "layer.bounds" // supports dot-notation!

listeners += myView.on(myProperty) { 
  (values: Change<NSValue>) in
  println(values)
}
```

[Check out the `Change` class](https://github.com/aleclarson/emitter-kit/blob/master/src/ChangeListener.swift#L36-L56) to see what wonders it contains. It even implements the `Printable` protocol for easy debugging!

-

##### NSKeyValueObservingOptions

The `NSKeyValueObservingOptions` you know and love are also supported! 

Valid values are `.Old`, `.New`, `.Initial`, `.Prior`, and `nil`.

```Swift
myView.once("backgroundColor", .Prior | .Old | .New) { 
  (change: Change<UIColor>) in
  println(change)
}
```

If you don't pass a value at all, it defaults to `.Old | .New`.

-

##### Clean-Up

To prevent memory leaks, you must call `removeListeners(listeners)` before the `NSObject` is deallocated.

If your object subclasses `UIView`, take advantage of `willMoveToWindow()` as the time to remove your change listeners.

Otherwise, the `deinit` statement is also an ideal spot for clean-up.

---

&nbsp;

[![donate](http://img.shields.io/gratipay/aleclarson.svg)](https://gratipay.com/aleclarson/)

&nbsp;
