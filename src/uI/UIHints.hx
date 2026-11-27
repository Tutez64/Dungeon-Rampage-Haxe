package uI;

import brain.utils.TextUtil;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHints;
import flash.display.MovieClip;
import flash.text.TextField;

class UIHints {
	static inline final KEYBOARD_MOUSE_HINT_TYPE = "CONTROLS";

	static var KEYBOARD_MOUSE_HINT_CONSTANTS:Array<ASAny>;

	var mDBFacade:DBFacade;

	var mHintBox:MovieClip;

	var mHintText:TextField;

	public function new(dbFacade:DBFacade, hintBox:MovieClip) {
		mDBFacade = dbFacade;
		mHintBox = hintBox;
		mHintText = ASCompat.coerce((hintBox : ASAny).hint_text, flash.text.TextField);
		var _loc3_ = ASCompat.coerce((hintBox : ASAny).hint_title, flash.text.TextField);
		Locale.setText(_loc3_, "HINT_TITLE");
		getNewHint();
	}

	static function isKeyboardMouseHint(hint:GMHints):Bool {
		return hint.Type == "CONTROLS" || KEYBOARD_MOUSE_HINT_CONSTANTS.indexOf(hint.Constant) != -1;
	}

	function getNewHint() {
		var _loc2_ = new Vector<GMHints>();
		var _loc3_ = mDBFacade.dbAccountInfo.activeAvatarInfo.ogLevel;
		var _loc6_ = mDBFacade.steamInputManager.wantsControllerPrompts;
		var _loc5_:GMHints;
		final __ax4_iter_132 = mDBFacade.gameMaster.Hints;
		if (checkNullIteratee(__ax4_iter_132))
			for (_tmp_ in __ax4_iter_132) {
				_loc5_ = _tmp_;
				if (!(_loc6_ && isKeyboardMouseHint(_loc5_))) {
					if (_loc5_.MinLevel <= _loc3_ && _loc5_.MaxLevel >= _loc3_) {
						_loc2_.push(_loc5_);
					}
				}
			}
		if (_loc2_.length == 0) {
			return;
		}
		var _loc1_ = (Math.floor(Math.random() * _loc2_.length) : UInt);
		var _loc4_ = _loc2_[(_loc1_ : Int)];
		if (_loc4_ == null) {
			return;
		}
		TextUtil.setText(mHintText, GameMasterLocale.getGameMasterSubString("HINTS", _loc4_.Constant), 1.55);
		TextUtil.fitToField(mHintText);
	}

	public function destroy() {
		mDBFacade = null;
		mHintBox = null;
		mHintText = null;
	}

	static function __init__() {
		KEYBOARD_MOUSE_HINT_CONSTANTS = ["HINT_GAMEPLAY_1"];
	}
}
