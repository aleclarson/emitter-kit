
public class Event <EventData: Any> : Emitter {

  public func on (handler: EventData -> Void) -> Listener {
    return EmitterListener(self, nil, castData(handler), false)
  }
  
  public func on (target: AnyObject, _ handler: EventData -> Void) -> Listener {
    return EmitterListener(self, target, castData(handler), false)
  }
  
  public func once (handler: EventData -> Void) -> Listener {
    return EmitterListener(self, nil, castData(handler), true)
  }
  
  public func once (target: AnyObject, _ handler: EventData -> Void) -> Listener {
    return EmitterListener(self, target, castData(handler), true)
  }
  
  public func emit (data: EventData) {
    super.emit(nil, data)
  }

  public func emit (target: AnyObject, _ data: EventData) {
    super.emit(target, data)
  }
  
  public func emit (targets: [AnyObject], _ data: EventData) {
    super.emit(targets, data)
  }
  
  public override init () {
    super.init()
  }
  
  private func castData (handler: EventData -> Void) -> Any! -> Void {
    return { handler($0 as! EventData) }
  }
}
