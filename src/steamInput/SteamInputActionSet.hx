package steamInput;

import com.amanitadesign.steam.FRESteamWorks;

class SteamInputActionSet {
	public var actionSetName:String;

	public var actionSetHandle:String;

	var mAnalogActions:Vector<SteamInputAction>;

	var mDigitalActions:Vector<SteamInputAction>;

	public function new(inActionSetName:String, inActionSetHandle:String) {
		actionSetName = inActionSetName;
		actionSetHandle = inActionSetHandle;
	}

	@:isVar public var analogActionHandles(get, never):Vector<SteamInputAction>;

	public function get_analogActionHandles():Vector<SteamInputAction> {
		return mAnalogActions;
	}

	@:isVar public var digitalActionHandles(get, never):Vector<SteamInputAction>;

	public function get_digitalActionHandles():Vector<SteamInputAction> {
		return mDigitalActions;
	}

	public function tryLoadAnalogActions(analogActionNames:Vector<String>, mSteamworks:FRESteamWorks):Bool {
		var _loc4_ = tryLoadActionHandles(analogActionNames, false, mSteamworks);
		var _loc3_ = validateSteamInputActions(_loc4_);
		if (!_loc3_) {
			return false;
		}
		mAnalogActions = _loc4_;
		return true;
	}

	public function tryLoadDigitalActions(digitalActionNames:Vector<String>, mSteamworks:FRESteamWorks):Bool {
		var _loc4_ = tryLoadActionHandles(digitalActionNames, true, mSteamworks);
		var _loc3_ = validateSteamInputActions(_loc4_);
		if (!_loc3_) {
			return false;
		}
		mDigitalActions = _loc4_;
		return true;
	}

	function tryLoadActionHandles(actionNames:Vector<String>, isDigitalAction:Bool, mSteamworks:FRESteamWorks):Vector<SteamInputAction> {
		var _loc6_:String = null;
		var _loc4_:SteamInputAction = null;
		var _loc5_ = new Vector<SteamInputAction>();
		var _loc7_:String;
		if (checkNullIteratee(actionNames))
			for (_tmp_ in actionNames) {
				_loc7_ = _tmp_;
				if (isDigitalAction) {
					_loc6_ = mSteamworks.getDigitalActionHandle(_loc7_);
				} else {
					_loc6_ = mSteamworks.getAnalogActionHandle(_loc7_);
				}
				_loc4_ = new SteamInputAction(_loc7_, _loc6_);
				_loc5_.push(_loc4_);
			}
		return _loc5_;
	}

	function validateSteamInputActions(actions:Vector<SteamInputAction>):Bool {
		var _loc2_:SteamInputAction;
		if (checkNullIteratee(actions))
			for (_tmp_ in actions) {
				_loc2_ = _tmp_;
				if (_loc2_.actionHandle == "0") {
					return false;
				}
			}
		return true;
	}
}
