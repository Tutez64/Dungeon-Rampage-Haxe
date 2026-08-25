package metrics;

import brain.logger.Logger;
import facade.DBFacade;
import flash.events.Event;

class PixelTracker {
	public function new() {}

	public static function tutorialComplete(dbFacade:DBFacade) {}

	public static function purchaseEvent(dbFacade:DBFacade, creditsValue:UInt) {}

	public static function nodeCompleted(dbFacade:DBFacade) {}

	public static function nodeIndexCompleted(dbFacade:DBFacade, dungeonIndex:UInt) {}

	public static function logMapNodeUnlocked(dbFacade:DBFacade, mapNodeIndex:UInt) {}

	public static function wallPost(dbFacade:DBFacade) {}

	public static function invitedFriend(dbFacade:DBFacade) {}

	public static function returnDAU(dbFacade:DBFacade) {}

	public static function visitedStore(dbFacade:DBFacade) {}

	public static function completeHandler(e:Event) {
		Logger.debug("Tracker completeHandler" + e.toString());
	}

	public static function securityErrorHandler(e:Event) {
		Logger.warn("Tracker securityErrorHandler: " + e.toString());
	}

	public static function ioErrorHandler(e:Event) {
		Logger.warn("Tracker ioErrorHandler: " + e.toString());
	}
}
