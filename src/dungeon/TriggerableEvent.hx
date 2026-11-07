package dungeon;

class TriggerableEvent {
	public var triggerableId:UInt = 0;

	public var eventName:String;

	public function new(id:UInt, evtName:String) {
		triggerableId = id;
		eventName = evtName;
	}
}
