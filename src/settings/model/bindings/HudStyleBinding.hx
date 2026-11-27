package settings.model.bindings;

import brain.event.EventComponent;
import events.UIHudChangeEvent;
import facade.DBFacade;

class HudStyleBinding implements ISettingBinding {
	var mEventComponent:EventComponent;

	var mCurrent:UInt = 0;

	public function new(dbFacade:DBFacade) {
		mEventComponent = new EventComponent(dbFacade);
		mCurrent = (0 : UInt);
	}

	public function read():ASAny {
		return mCurrent;
	}

	public function write(value:ASAny) {
		mCurrent = (ASCompat.toInt(value) : UInt);
		mEventComponent.dispatchEvent(new UIHudChangeEvent(mCurrent));
	}

	public function writeInitial(value:ASAny) {
		mCurrent = (ASCompat.toInt(value) : UInt);
	}

	public function destroy() {
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
	}
}
