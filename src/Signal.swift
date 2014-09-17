
public class Signal : Emitter {

  public func on (handler: Void -> Void) -> EmitterListener {
    return EmitterListener(self, nil, ignoreData(handler), false)
  }
  
  public func on (target: AnyObject, _ handler: Void -> Void) -> EmitterListener {
    return EmitterListener(self, target, ignoreData(handler), false)
  }
  
  public func once (handler: Void -> Void) -> EmitterListener {
    return EmitterListener(self, nil, ignoreData(handler), true)
  }
  
  public func once (target: AnyObject, _ handler: Void -> Void) -> EmitterListener {
    return EmitterListener(self, target, ignoreData(handler), true)
  }
  
  public func emit () {
    super.emit(nil, nil)
  }
  
  public func emit (target: AnyObject) {
    super.emit(target, nil)
  }
  
  public func emit(targets: [AnyObject]) {
    super.emit(targets, nil)
  }
  
  public override init () {
    super.init()
  }
  
  func ignoreData (handler: Void -> Void)(_: Any!) {
    handler()
  }
}
