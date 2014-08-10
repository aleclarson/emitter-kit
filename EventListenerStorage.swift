
func <= (storage: EventListenerStorage, listener: AnyEventListener) {
  storage.array.append(listener)
}

class EventListenerStorage {
  
  final lazy private(set) var array = [AnyEventListener]()
  
  final lazy private(set) var dict = [String:AnyEventListener]()
  
  subscript (key: String) -> AnyEventListener? {
    get { return dict[key] }
    set { dict[key] = newValue }
  }
  
  subscript (index: Int) -> AnyEventListener? {
    get { return array.optionalAtIndex(index) }
    set {
      if self[index] != nil {
        if newValue != nil {
          array[index] = newValue!
        } else {
          array.removeAtIndex(index)
        }
      }
    }
  }

  func clear () {
    array = []
    dict = [:]
  }
}



//
//  Helpers
//

private extension Array {
  func optionalAtIndex (index: Int) -> T? {
    return index >= 0 && index < count ? self[index] : nil
  }
}
