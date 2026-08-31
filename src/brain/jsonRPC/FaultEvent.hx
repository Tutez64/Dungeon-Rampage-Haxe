package brain.jsonRPC;

import flash.events.ErrorEvent;

class FaultEvent extends ErrorEvent {
	public static inline final Fault = "fault";

	public var fault:Error;

	public function new(err:Error) {
		this.fault = err;
		super("fault", true, true, err.message);
	}
}
