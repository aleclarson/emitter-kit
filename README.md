<img src="http://i.imgur.com/pZqM562.jpg"/>

EmitterKit is a cleaner alternative to [**NSNotificationCenter**](http://nshipster.com/nsnotification-and-nsnotificationcenter/).

- No more typecasting data in your callbacks
- No more `removeObserver()` in your class's `deinit` method
- Backwards-compatible with `NSNotificationCenter` (like `UIKeyboardWillShowNotification`)
- Key-value observation for `NSObject`s
- Simpler syntax

---

### **Emitter**

An `Emitter` enables one-to-many communication for a specific event. It is an abstract class, so you can't initialize one yourself. Instead, use a `Signal` or `Event`.

```Swift
// Event

let didLogin = Event<User>()

didLogin.once { user in
  println("Successfully logged in as \(user.name)!")
}

didLogin.emit(user)

// Signal

let didLogout = Signal()

didLogout.once {
  println("Logged out successfully... :(")
}

didLogout.emit()
```

Usually, I use `Emitter`s as properties in my own classes.

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

I can associate an `AnyObject` with an event when calling `on()` or `once()`. This is useful for classes I cannot add properties to (e.g. `UIView`).

```Swift
let myView = UIView()
let didTouch = Event<UITouch>()

didTouch.once(myView) {
  println("We have a winner! \($0)")
}

didTouch.emit(myView, touch)
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

A `Listener` represents a closure. It's an abstract class, so you can't initialize it yourself.

Enable/disable a `Listener` with its `isListening` boolean property. This property is automatically set to `true` when the `Listener` is allocated.

**Important:** You must retain the `Listener` returned from any `on()` method. Make a `[Listener]` property and put it there. If you create a `Listener` with `once()`, you do not have to worry.

```Swift
var listeners = [Listener]()

// Retain that sucka
listeners += mySignal.on {
  println("beep")
}

// Don't bother!
mySignal.once {
  println("boop")
}
```

---

### **Key-Value Observation**

If you want to know when an `NSObject`'s property changes, just call its `on()` or `once()` method!

You must provide a `String` representing the property you wish to observe. Dot-notation syntax is allowed! (e.g. `"layer.bounds"`)

Your callback is passed a `Change`. This is a generic class that has an `oldValue`, `newValue`, and `keyPath`.

```Swift
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

Instead, drag `EmitterKit.xcodeproj` into your Xcode project as a submodule. Then, setup the target as shown in [this image](http://i.imgur.com/1r01y80.jpg).

---

Crafted by Alec Larson [@aleclarsoniv](https://twitter.com/aleclarsoniv)
