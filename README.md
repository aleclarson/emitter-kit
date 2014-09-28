<img src="http://i.imgur.com/pZqM562.jpg"/>

EmitterKit is a cleaner alternative to [**NSNotificationCenter**](http://nshipster.com/nsnotification-and-nsnotificationcenter/).

- No more typecasting data in your callbacks
- No more `removeObserver()` in your class's `deinit` method
- Backwards-compatible with `NSNotificationCenter` (like `UIKeyboardWillShowNotification`)
- Key-value observation for `NSObject`s
- Simpler syntax

---

### **Table of Contents**

[Emitter](#emitter)

&nbsp;&nbsp;&nbsp;&nbsp;[Associated Objects](#associated-objects)

[Notification](#notification)

[Listener](#listener)

[Key-Value Observation](#key-value-observation)

[Installing](#installing)

---

### **Emitter**

An `Emitter` enables one-to-many communication for a specific event. It is an abstract class, so you can't initialize one yourself.

Every `Emitter` has `emit()`, `on()`, and `once()` methods.

`emit` notifies any `Listener` that is listening to it.

`on` creates a `Listener` that listens to it.

`once` creates a `Listener` that listens to it, but stops after one time.

`Emitter` has two bad-ass subclasses, `Signal` and `Event`.

Use an `Event` to pass any type of data, tuples included! This saves you the hassle of typecasting your data in your callbacks all the time.

```Swift
let didLogin = Event<User>()

didLogin.once { user in
  println("You are our 1,000,000th visitor!")
}

didLogin.emit(user)
```

A `Signal` keeps it simple. No data. Just a signal. This exists because `Event<Void>` doesn't work as expected.

```Swift
let didLogout = Signal()

didLogout.once {
  println("Sending information to NSA...")
}

didLogout.emit()
```

Naturally, I use `Emitter`s as properties in my own classes. It's like Javascript for iOS!™

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

---

### **Associated Objects**

If I need to associate a `UIView` (for example) with an `Emitter` or `Listener`, I can simply pass an `AnyObject` to `emit()`, `on()`, or `once()` as the first parameter.

```Swift
let myView = UIView()
let didTouch = Event<UITouch>()

didTouch.once(myView) {
  println("Ding ding ding! \($0)")
}

didTouch.emit(myView, touch)
```

This can become especially handy with `UIApplicationWillResignActiveNotification` (for example) because the `NSNotification.object` will be `UIApplication.sharedApplication()`. So you need to call it like:

```Swift
Notification(UIApplicationWillResignActiveNotification).on(UIApplication.sharedApplication()) { 
  _ in println("Where you going?")
}
```

`String`s can also be used instead of `AnyObject`s. This can be useful for image urls, for example.

```Swift
let didLoadImage = Event<NSData>()
let url = "https://i.imgur.com/iF7scP2.jpg"
didLoadImage.emit(url, imageData)
didLoadImage.once(url) {}
```

---

### **Notification**


`Notification` has the same methods as `Emitter` does, but runs on top of `NSNotificationCenter`. This provides the benefits of EmitterKit even when working with Apple's frameworks, like `UIKeyboardWillShowNotification`.

```Swift
Notification(UIKeyboardWillShowNotification).once { data in
  println("keyboard showing. data: \(data)")
}
```

Unlike `Emitter`, a `Notification` does **not** need to be retained to work as expected.

`Notification` removes the need for `NSNotificationCenter.defaultCenter().removeObserver()` in your class's deinit method. How cool is that? I'd give it about a 5 out of 10.

---

### **Listener**

A `Listener` represents a closure. It's an abstract class, so you can't initialize it yourself.

Enable/disable a `Listener` with its `isListening` boolean property. This property is automatically set to `true` when the `Listener` is allocated.

Any `Listener` created with a `once()` method is retained for you! Pretty slick.

**NOTE:** Any `Listener` created with an `on()` method **must** be retained by you. Use a `Listener` or `[Listener]` property in your class! 

---

### **Key-Value Observation**

Every `NSObject` is extended with `on()` and `once()` methods. Use these when you want to know when a KVO-compatible property changes its value!

When using these methods, you are required to supply a `String` which represents the property. Dot-notation syntax is allowed! (e.g. `"layer.bounds"`)

This runs on top of the `NSKeyValueObserving` protocol. **But**, you no longer need to call `NSObject.removeObserver()` in your class's deinit method! Score!

Your callback is passed a `Change`, a generic class that has an `oldValue`, `newValue`, and `keyPath`.

```Swift
var listeners = [Listener]()
let myView = UIView()

listeners += myView.on("bounds") { (values: Change<NSValue>) in
  println(values)
}

myView.once("backgroundColor") { (values: Change<UIColor>) in
  println(values)
}
```

---

### **Installing**

EmitterKit is not yet available on CocoaPods. Instead, drag `EmitterKit.xcodeproj` into your Xcode project as a submodule. Then, setup the target as shown in [this image](http://i.imgur.com/1r01y80.jpg).

---

Crafted by Alec Larson [@aleclarsoniv](https://twitter.com/aleclarsoniv)
