package metrics;

import facade.DBFacade;
import com.junkbyte.console.Cc;

class GpuMemoryGraph {
	static inline final MENU_NAME = "VM";

	static inline final PANEL_NAME = "VRAM";

	static inline final LINE_COLOR:Float = 1624575;

	static inline final B_TO_MB:Float = 9.5367431640625e-7;

	var mDBFacade:DBFacade;

	var mPeakMb:Float = 0;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		Cc.addMenu("VM", show, null, "Show the VRAM graph (Stage3D texture/buffer memory, MB)");
	}

	public function show() {
		var _loc1_:ASObject = starlingContext();
		if (_loc1_ == null) {
			Cc.log("VRAM graph: the Starling context is not ready yet.");
			return;
		}
		if (!_loc1_.hasOwnProperty("totalGPUMemory")) {
			Cc.log("VRAM graph: this runtime has no Context3D.totalGPUMemory (needs AIR 24 or later).");
			return;
		}
		mPeakMb = 0;
		Cc.addGraph("VRAM", this, "vramMb", 1624575);
	}

	@:isVar public var vramMb(get, never):Float;

	public function get_vramMb():Float {
		var _loc1_ = readVramMb();
		if (_loc1_ > mPeakMb) {
			mPeakMb = _loc1_;
		}
		Cc.fixGraphRange("VRAM", 0, mPeakMb);
		return _loc1_;
	}

	function readVramMb():Float {
		var _loc1_:ASObject = starlingContext();
		if (_loc1_ == null) {
			return 0;
		}
		try {
			if (_loc1_.hasOwnProperty("totalGPUMemory")) {
				return Math.fround(ASCompat.toNumber(_loc1_["totalGPUMemory"]) * 9.5367431640625e-7 * 10) / 10;
			}
		} catch (e:Dynamic) {}
		return 0;
	}

	function starlingContext():ASObject {
		if (mDBFacade == null || mDBFacade.starlingLayerManager == null || mDBFacade.starlingLayerManager.starlingInstance == null) {
			return null;
		}
		return mDBFacade.starlingLayerManager.starlingInstance._context;
	}
}
