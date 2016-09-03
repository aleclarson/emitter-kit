
public class Event <EventData: Any> : Emitter {

  public func on (_ handler: @escaping (EventData) -> Void) -> Listener {
    return EmitterListener(self, nil, castData(handler), false)
  }

  public func on (_ target: AnyObject, _ handler: @escaping (EventData) -> Void) -> Listener {
    return EmitterListener(self, target, castData(handler), false)
  }

  public func once (handler: @escaping (EventData) -> Void) -> Listener {
    return EmitterListener(self, nil, castData(handler), true)
  }

  public func once (target: AnyObject, _ handler: @escaping (EventData) -> Void) -> Listener {
    return EmitterListener(self, target, castData(handler), true)
  }

  public func emit (_ data: EventData) {
    super.emit(data, on: nil)
  }

  public func emit (_ data: EventData, on target: AnyObject) {
    super.emit(data, on: target)
  }

  public func emit (_ data: EventData, on targets: [AnyObject]) {
    super.emit(data, on: targets)
  }

  public override init () {
    super.init()
  }

  private func castData (_ handler: @escaping (EventData) -> Void) -> (Any!) -> Void {
    return { handler($0 as! EventData) }
  }
}
