<img src="http://i.imgur.com/3e9ToKJ.jpg"/>

**EmitterKit** is a cleaner alternative to [**NSNotificationCenter**](http://nshipster.com/nsnotification-and-nsnotificationcenter/).

-

#### **Emitter**

The abstract class for all event types. You should never have to use this class directly.

-

#### **Event**

A generic `Emitter` for any data type.

```Swift
let didLogin = Event<User>()

didLogin.once { user in
  println("Successfully logged in as \(user.name)!")
}

didLogin.emit(user)
```

When an `Event` is deallocated, its `Listener`s are removed.

-

### **Signal**

An `Emitter` that does not pass data.

```Swift
let didLogout = Signal()

didLogout.once {
  println("Logged out successfully... :(")
}

didLogout.emit()
```

-

### **Notification**

An `Emitter` for backwards compatibility with `NSNotificationCenter`.

```Swift
let willShowKeyboard = Notification(UIKeyboardWillShowNotification)

willShowKeyboard.once { data in
  println("keyboard showing. data: \(data)")
}
```

You're not allowed to `emit` a `Notification` yourself. This class is strictly for backwards compatibility with `NSNotificationCenter`. Note that `NSNotificationCenter.defaultCenter()` is always used here.

-

### **Listener**

Represents a closure that will be called when its `emitter` emits.

Although you can call `Listener`'s initializers, you'll probably want to use the `on()` and `once()` methods on any `Emitter` instance.

-

### **ListenerStorage**

Retains `Listeners` that can be called more than once.

Create a `ListenerStorage` if you ever call `myEmitter.on()`. This will ensure your `Listener` does not get released until the `Emitter` or `ListenerStorage` is released.

```Swift
class MyClass {
  
  let events = ListenerStorage()
  
  let view = MyView()
  
  init () {
    
    events += view.didTap.on {
      println("Tapped the view!")
    }
  
  }
}
```

Now you're not forced to call `NSNotificationCenter.removeObserver()` in your class's `deinit`. Instead, when your class instance is deallocated, the `ListenerStorage` removes its listeners for you. Note that when an `Event` is deallocated, all of its listeners will be removed, also.

-

#### Associated objects

For my own Swift classes, I prefer to keep `Emitter`s as properties. But for classes that I can't do that (like `UIView` for example), it's really easy to associate the `UIView` with my `Emitter`.

```Swift
let didTap = Event<UITouch>()

let myView = UIView(frame: CGRectMake(0, 0, 100, 100))

didTap.once(myView) { touch in
  println("tapped myView!")
}

didTap.emit(myView, touch)
```

You can emit to many targets at the same time, if you need to.

```Swift
didTap.emit([myView, myOtherView, thatViewToo], touch)
```

-

Crafted by Alec Larson [@aleclarsoniv](https://twitter.com/aleclarsoniv)
