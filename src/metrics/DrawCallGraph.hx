package metrics;

import facade.DBFacade;
import com.junkbyte.console.Cc;
import starling.core.Starling;

class DrawCallGraph {
	static inline final MENU_NAME = "DC";

	static inline final PANEL_NAME = "Draw calls";

	static inline final LINE_COLOR:Float = 16756768;

	var mDBFacade:DBFacade;

	var mPeak:Int = 0;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		Cc.addMenu("DC", show, null, "Show the draw calls graph (Starling draw calls per frame)");
	}

	public function show() {
		if (currentStarling() == null) {
			Cc.log("Draw calls graph: Starling is not ready yet.");
			return;
		}
		mPeak = 0;
		Cc.addGraph("Draw calls", this, "drawCalls", 16756768);
	}

	@:isVar public var drawCalls(get, never):Int;

	public function get_drawCalls():Int {
		var _loc1_ = currentStarling();
		var _loc2_ = _loc1_ != null && _loc1_.painter_instance != null ? _loc1_.painter_instance.drawCount : 0;
		if (_loc2_ > mPeak) {
			mPeak = _loc2_;
		}
		Cc.fixGraphRange("Draw calls", 0, mPeak);
		return _loc2_;
	}

	function currentStarling():Starling {
		if (mDBFacade == null || mDBFacade.starlingLayerManager == null) {
			return null;
		}
		return mDBFacade.starlingLayerManager.starlingInstance;
	}
}
