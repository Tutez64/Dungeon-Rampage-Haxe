package brain.starling.swfConverter;

import flash.system.Capabilities;
import starling.core.Starling;

class BakeBudget {
	public static inline final POOL_HUD_STARLING = "hudStarling";

	public static var HUD_STARLING_CAP_MIB:Float = 64;

	public static inline final POOL_WORLD = "world";

	static inline final MIB:Float = 1048576;

	public static inline final HEADROOM_MIB:Float = 32;

	public static inline final RECTANGLE_BUDGET_MIB:Float = 512;

	public static inline final OTHER_RECTANGLES_MIB:Float = 256;

	public static inline final MAX_FIGHT_DEFER_MS = 4000;

	public static inline final FIGHT_ALLOW_MS = 500;

	static var sMajor:Int = -1;

	static var sRectangleUsed:Float = 0;

	static var sDeferredSince:Int = -1;

	static var sAllowUntil:Int = -1;

	static var sUsed:ASObject;

	public function new() {}

	@:isVar public static var mayAllocate(get, never):Bool;

	static public function get_mayAllocate():Bool {
		var _loc1_ = !BakeScheduler.loading && !BakeScheduler.fighting;
		if (_loc1_) {
			sDeferredSince = -1;
		}
		return _loc1_;
	}

	@:isVar public static var admitting(get, never):Bool;

	static public function get_admitting():Bool {
		return mayAllocate || fightWaitOver();
	}

	public static function accountedBytes(width:Int, height:Int, rectangle:Bool):Float {
		return width * height * 4 * (rectangle ? 1 : 1.5);
	}

	@:isVar public static var effectiveRuntimeCapMiB(get, never):Float;

	static public function get_effectiveRuntimeCapMiB():Float {
		return separateRectangleBudget ? 504 : 2040;
	}

	@:isVar public static var separateRectangleBudget(get, never):Bool;

	static public function get_separateRectangleBudget():Bool {
		var _loc1_:Array<ASAny> = null;
		if (sMajor < 0) {
			_loc1_ = (cast new compat.RegExp("(\\d+),").match(Capabilities.version));
			sMajor = _loc1_ != null ? ASCompat.toInt(_loc1_[1]) : 0;
		}
		return sMajor > 0 && sMajor <= 32;
	}

	public static function capBytes(pool:String):Float {
		switch (pool) {
			case "hudStarling":
				return HUD_STARLING_CAP_MIB * 1048576;
			case "world":
				return 8 * 1048576;
			default:
				return 0;
		}
		return Math.NaN;
	}

	public static function usedBytes(pool:String):Float {
		return ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(sUsed[pool]), 0));
	}

	@:isVar public static var gpuBytes(get, never):Float;

	static public function get_gpuBytes():Float {
		var _loc1_ = Starling.context;
		if (_loc1_ == null || !(_loc1_ : ASAny).hasOwnProperty("totalGPUMemory")) {
			return -1;
		}
		return ASCompat.toNumber((_loc1_ : ASAny)["totalGPUMemory"]);
	}

	public static function reserve(pool:String, width:Int, height:Int, force:Bool, rectangle:Bool):Bool {
		if (!force && !admitting) {
			return false;
		}
		var _loc6_ = accountedBytes(width, height, rectangle);
		if (usedBytes(pool) + _loc6_ > capBytes(pool) || !fitsHeadroom(_loc6_, rectangle)) {
			return false;
		}
		sUsed[pool] = usedBytes(pool) + _loc6_;
		if (rectangle) {
			sRectangleUsed += _loc6_;
		}
		return true;
	}

	public static function unreserve(pool:String, width:Int, height:Int, rectangle:Bool) {
		var _loc5_ = accountedBytes(width, height, rectangle);
		sUsed[pool] = Math.max(0, usedBytes(pool) - _loc5_);
		if (rectangle) {
			sRectangleUsed = Math.max(0, sRectangleUsed - _loc5_);
		}
	}

	static function fitsHeadroom(bytes:Float, rectangle:Bool):Bool {
		var _loc3_ = gpuBytes;
		if (rectangle && separateRectangleBudget) {
			if (sRectangleUsed + bytes > (512 - 256 - 32) * 1048576) {
				return false;
			}
			return _loc3_ < 0 || _loc3_ + bytes <= (effectiveRuntimeCapMiB + 512 - 32) * 1048576;
		}
		return _loc3_ < 0 || _loc3_ + bytes <= (effectiveRuntimeCapMiB - 32) * 1048576;
	}

	static function fightWaitOver():Bool {
		var _loc1_ = flash.Lib.getTimer();
		if (BakeScheduler.loading) {
			sDeferredSince = -1;
			return false;
		}
		if (sAllowUntil >= 0 && _loc1_ < sAllowUntil) {
			return true;
		}
		sAllowUntil = -1;
		if (sDeferredSince < 0) {
			sDeferredSince = _loc1_;
			return false;
		}
		if (_loc1_ - sDeferredSince < 4000) {
			return false;
		}
		sDeferredSince = -1;
		sAllowUntil = _loc1_ + 500;
		return true;
	}

	static function __init__() {
		sUsed = {};
	}
}
