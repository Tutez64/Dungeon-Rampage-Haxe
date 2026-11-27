package events;

import distributedObjects.MatchMaker;
import flash.events.Event;

class MatchMakerLoadedEvent extends Event {
	public static inline final EVENT_NAME = "MATCH_MAKER_LOADED";

	var mMatchMaker:MatchMaker;

	public function new(matchMaker:MatchMaker, bubbles:Bool = false, cancelable:Bool = false) {
		super("MATCH_MAKER_LOADED", bubbles, cancelable);
		mMatchMaker = matchMaker;
	}

	@:isVar public var matchMaker(get, never):MatchMaker;

	public function get_matchMaker():MatchMaker {
		return mMatchMaker;
	}
}
