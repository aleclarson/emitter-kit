# emitter-kit v3.2.0 [[![frozen](http://badges.github.io/stability-badges/dist/frozen.svg)](http://github.com/badges/stability-badges "Frozen")](https://nodejs.org/api/documentation.html#documentation_stability_index) [![donate](http://img.shields.io/gratipay/aleclarson.svg "Donate")](https://gratipay.com/aleclarson/)

**What?** Type-safe event handling in a simple & concise framework. And more!

**Why?** The `NSNotification` framework isn't my cup of tea. Things could be easier.

**Compatibility:** `v3.2.0` only works with Swift 1.2

**Note:** This framework is currently unmaintained (I'm not using Swift anymore). If something stops working, please submit a pull request and I'll figure things out when I have the free time (of which I have none right now).

**By:** [@aleclarsoniv](https://twitter.com/aleclarsoniv)

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

---

### **Signal**

A `Signal` is essentially an `Event` that can't pass data. Convenient, huh?

This is a subclass of `Emitter`, too.

```Swift
let didLogout = Signal()

didLogout.once {
  println("Logged out successfully... :(")
}

didLogout.emit()
```

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

---

### **Key-Value Observation**

EmitterKit adds `on()`, `once()`, and `removeListeners()` instance methods to every `NSObject`.

```Swift
let myView = UIView()
let myProperty = "layer.bounds" // supports dot-notation!

listeners += myView.on(myProperty) { 
  (values: Change<NSValue>) in
  println(values)
}
```

[Check out the `Change` class](https://github.com/aleclarson/emitter-kit/blob/master/src/ChangeListener.swift#L36-L56) to see what wonders it contains. It implements the `Printable` protocol for easy debugging!

The `NSKeyValueObservingOptions` you know and love are also supported! Valid values are `.Old`, `.New`, `.Initial`, `.Prior`, and `nil`. If you don't pass a value at all, it defaults to `.Old | .New`.

```Swift
myView.once("backgroundColor", .Prior | .Old | .New) { 
  (change: Change<UIColor>) in
  println(change)
}
```

It runs on top of traditional KVO techniques, so everything works as expected!

**WARNING:** If you use these methods, you must call `removeListeners(myListenerArray)` before your `NSObject` deinits. Otherwise, your program will crash. I suggest making a subclass of `UIView`, overriding `willMoveToWindow()`, and putting `removeListeners()` in there. That's not always ideal if you're not working with a `UIView`, but that's all I use it for right now, so I can't help you in other cases.
