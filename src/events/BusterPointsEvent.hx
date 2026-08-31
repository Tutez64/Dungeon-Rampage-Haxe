package events;

class BusterPointsEvent extends GameObjectEvent {
	public static inline final BUSTER_POINTS_UPDATE = "BusterPointEvent_BUSTER_POINTS_UPDATE";

	public var busterPoints:UInt = 0;

	public var maxBusterPoints:UInt = 0;

	public function new(type:String, id:UInt, busterPoints:UInt, maxBusterPoints:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.busterPoints = busterPoints;
		this.maxBusterPoints = maxBusterPoints;
		super(type, id, bubbles, cancelable);
	}
}
