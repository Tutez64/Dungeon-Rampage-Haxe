package brain.event;

import brain.component.Component;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.utils.Receipt;
import flash.events.Event;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class EventComponent extends Component {
	var mRegisteredListeners:Map = new Map();

	public function new(facade:Facade) {
		super(facade);
		mFacade = facade;
	}

	public function addListener(eventName:String, callback:ASFunction):Receipt {
		var _loc4_:Receipt = null;
		var _loc3_ = mRegisteredListeners.add(eventName, callback);
		if (_loc3_) {
			mFacade.eventManager.addEventListener(eventName, callback);
			_loc4_ = new Receipt(removeListener);
			MemoryTracker.track(_loc4_, "Receipt - EventComponent listener: " + eventName, "brain");
			return _loc4_;
		}
		Logger.warn("Failed duplicate addListener for eventName: " + eventName);
		return null;
	}

	public function removeListener(eventName:String) {
		var _loc2_ = ASCompat.asFunction(mRegisteredListeners.removeKey(eventName));
		if (_loc2_ == null) {
			return;
		}
		mFacade.eventManager.removeEventListener(eventName, _loc2_);
	}

	public function dispatchEvent(eventObj:Event) {
		mFacade.eventManager.dispatchEvent(eventObj);
	}

	override public function destroy() {
		removeAllListeners();
		mRegisteredListeners = null;
		super.destroy();
	}

	public function removeAllListeners() {
		var _loc2_:String = null;
		var _loc3_:ASFunction = null;
		var _loc1_ = ASCompat.reinterpretAs(mRegisteredListeners.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc3_ = ASCompat.asFunction(_loc1_.next());
			_loc2_ = _loc1_.key;
			mFacade.eventManager.removeEventListener(_loc2_, _loc3_);
		}
		mRegisteredListeners.clear();
	}
}
