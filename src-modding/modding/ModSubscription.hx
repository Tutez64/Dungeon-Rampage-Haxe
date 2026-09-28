package modding;

/** What every `ModContext.on*` returns. `cancel` stops the handler; a second call does nothing. */
@:allow(modding.Host)
class ModSubscription {
	public var active(default, null):Bool = true;

	var owner:String;

	var event:String;

	var call:Dynamic->Void;

	function new(owner:String, event:String, call:Dynamic->Void) {
		this.owner = owner;
		this.event = event;
		this.call = call;
	}

	public function cancel():Void {
		if (!active)
			return;
		active = false;
		Host.unlisten(this);
	}
}
