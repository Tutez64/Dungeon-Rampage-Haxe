package uI;

import brain.logger.Logger;
import facade.DBFacade;
import facade.Locale;
import flash.text.TextField;
import flash.text.TextFormat;

class UIReconnectingIndicator {
	static inline final DRAW_LAYER:Float = 1003;

	static inline final TOP_OFFSET:Float = 40;

	var mDBFacade:DBFacade;

	var mField:TextField;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
	}

	public function show() {
		if (mField != null || mDBFacade == null) {
			return;
		}
		var _loc1_ = new TextField();
		_loc1_.selectable = false;
		_loc1_.mouseEnabled = false;
		_loc1_.autoSize = "left";
		var _loc2_ = new TextFormat();
		_loc2_.bold = true;
		_loc2_.font = "Verdana";
		_loc2_.color = 16767370;
		_loc2_.size = 22;
		_loc1_.defaultTextFormat = _loc2_;
		_loc1_.text = Locale.getString("RECONNECTING");
		_loc1_.background = true;
		_loc1_.backgroundColor = (0 : UInt);
		_loc1_.cacheAsBitmap = true;
		_loc1_.name = "ReconnectingIndicator";
		_loc1_.y = 40;
		mField = _loc1_;
		centre();
		mDBFacade.addRootDisplayObject(_loc1_, 1003);
	}

	public function update(attempt:Int, elapsedMilliseconds:Int, graceMilliseconds:Int) {
		if (mField == null) {
			return;
		}
		mField.text = StringTools.replace(StringTools.replace(StringTools.replace(Locale.getString("RECONNECTING_DETAIL"), "#ATTEMPT", Std.string(attempt)),
			"#ELAPSED", Std.string(ASCompat.floatToInt(elapsedMilliseconds / 1000))),
			"#GRACE", Std.string(ASCompat.floatToInt(graceMilliseconds / 1000)));
		centre();
	}

	public function destroy() {
		var _loc1_:TextField = null;
		if (mField != null) {
			_loc1_ = mField;
			mField = null;
			try {
				mDBFacade.removeRootDisplayObject(_loc1_);
			} catch (error:Dynamic) {
				Logger.warn("The reconnecting indicator was already gone: " + Std.string(error.message));
			}
		}
		mDBFacade = null;
	}

	function centre() {
		mField.x = Math.max(0, (mDBFacade.viewWidth - mField.width) * 0.5);
	}
}
