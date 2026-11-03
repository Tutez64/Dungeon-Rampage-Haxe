package settings.model.bindings;

import facade.DBFacade;
import input.keyBindings.KeyBindings;
import settings.model.KeyBindingValue;

class KeyBindingSettingBinding implements ISettingBinding {
	var mKeyBindings:KeyBindings;

	var mAction:String;

	public function new(dbFacade:DBFacade, action:String) {
		mKeyBindings = dbFacade.keyBindings;
		mAction = action;
	}

	public function read():ASAny {
		return KeyBindingValue.make(mKeyBindings.getPrimary(mAction), mKeyBindings.getAlternate(mAction));
	}

	public function write(value:ASAny) {
		mKeyBindings.setBinding(mAction, KeyBindingValue.primary(value), KeyBindingValue.alternate(value));
	}

	public function writeInitial(value:ASAny) {
		write(value);
	}

	public function destroy() {
		mKeyBindings = null;
	}
}
