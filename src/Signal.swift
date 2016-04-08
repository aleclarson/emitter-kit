
public class Signal : Emitter {

  @warn_unused_result
  public func on (handler: Void -> Void) -> Listener {
    return EmitterListener(self, nil, { _ in handler() }, false)
  }
  
  @warn_unused_result
  public func on (target: AnyObject, _ handler: Void -> Void) -> Listener {
    return EmitterListener(self, target, { _ in handler() }, false)
  }
  
  @warn_unused_result
  public func once (handler: Void -> Void) -> Listener {
    return EmitterListener(self, nil, { _ in handler() }, true)
  }
  
  @warn_unused_result
  public func once (target: AnyObject, _ handler: Void -> Void) -> Listener {
    return EmitterListener(self, target, { _ in handler() }, true)
  }
  
  public func emit () {
    super.emit(nil, nil)
  }
  
  public func emit (target: AnyObject) {
    super.emit(target, nil)
  }
  
  public func emit (targets: [AnyObject]) {
    super.emit(targets, nil)
  }
  
  public override init () {
    super.init()
  }
}
