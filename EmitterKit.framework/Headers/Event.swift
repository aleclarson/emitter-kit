
public class Event <EventData: Any> : Emitter {

  public func on (handler: EventData -> Void) -> EmitterListener {
    return EmitterListener(self, nil, castData(handler), false)
  }
  
  public func on (target: AnyObject, _ handler: EventData -> Void) -> EmitterListener {
    return EmitterListener(self, target, castData(handler), false)
  }
  
  public func once (handler: EventData -> Void) -> EmitterListener {
    return EmitterListener(self, nil, castData(handler), true)
  }
  
  public func once (target: AnyObject, _ handler: EventData -> Void) -> EmitterListener {
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
  
  private func castData (handler: EventData -> Void)(data: Any!) {
    handler(data as EventData)
  }
}
