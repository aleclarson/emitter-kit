# Changelog

#### October 7, 2014

`Signal` and `Event` now support associated `String`s!

```Swift
let didTouch = Signal()

didTouch.once("ended") {
  println("TOUCH ENDED!")
}

didTouch.emit("began") // This will not call anything.

didTouch.emit("ended") // This will call our one-time listener!
```

I use this to know when an external image is finished loading via HTTP!

```Swift
let didLoadImage = Event<Image>()

let url = "https://i.imgur.com/j6dDXns.jpg"

didLoadImage.once(url) { image in
  println("Done loading.")
}

didLoadImage.emit(url, Image())
```
