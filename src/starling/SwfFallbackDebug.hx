package starling;

import brain.assetRepository.StarlingAssetMapper;
import brain.logger.Logger;
import facade.DBFacade;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;

class SwfFallbackDebug {
	public static inline final CATEGORY_TILE = "TILE";

	public static inline final CATEGORY_PROP = "PROP";

	public static inline final CATEGORY_EFFECT = "EFFECT";

	public static inline final CATEGORY_BUFF = "BUFF";

	public static inline final CATEGORY_PROJECTILE = "PROJECTILE";

	public static inline final CATEGORY_DOOBER = "DOOBER";

	public static inline final OUTLINE_COLOR = (16711897 : UInt);

	static inline final BITMAP_BORDER = 3;

	static final OUTLINE:GlowFilter = new GlowFilter((16711897 : UInt), 1, 16, 16, 5);

	static final SOUND_ONLY_SWF:compat.RegExp = new compat.RegExp("(^|[\\/\\\\])soundEffects\\.swf$", "i");

	static var sReported:ASObject;

	public function new() {}

	public static function isEnabled(facade:DBFacade, category:String = null):Bool {
		if (facade == null || facade.featureFlags == null) {
			return false;
		}
		if (facade.featureFlags.getFlagValue("debug-outline-swf-fallback")) {
			return true;
		}
		return isLegacyOutlineCategory(category) && facade.featureFlags.getFlagValue("debug-outline-swf-fallback-props");
	}

	static function isLegacyOutlineCategory(category:String):Bool {
		return category == "PROP" || category != null && (category.indexOf("ACTOR") == 0 || category.indexOf("WEAPON") == 0);
	}

	public static function applyOutline(facade:DBFacade, node:DisplayObject, category:String = null) {
		if (node == null || !isEnabled(facade, category)) {
			return;
		}
		var _loc4_ = if (node.filters != null) node.filters else [];
		if (findOutline(_loc4_) < 0) {
			_loc4_.push(OUTLINE);
			node.filters = cast(_loc4_);
		}
	}

	public static function removeOutline(node:DisplayObject) {
		if (node == null) {
			return;
		}
		var _loc2_ = node.filters;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_ = findOutline(_loc2_);
		if (_loc3_ >= 0) {
			_loc2_.splice(_loc3_, (1 : UInt));
			node.filters = cast(_loc2_);
		}
	}

	static function findOutline(filters:Array<ASAny>):Int {
		var _loc2_ = 0;
		var _loc3_:GlowFilter = null;
		_loc2_ = 0;
		while (_loc2_ < filters.length) {
			_loc3_ = ASCompat.dynamicAs(filters[_loc2_], GlowFilter);
			if (_loc3_ != null && _loc3_.color == 16711897 && _loc3_.blurX == OUTLINE.blurX && _loc3_.blurY == OUTLINE.blurY) {
				return _loc2_;
			}
			_loc2_++;
		}
		return -1;
	}

	public static function markFallbackBitmap(facade:DBFacade, bmd:BitmapData, category:String = null) {
		if (bmd == null || !isEnabled(facade, category)) {
			return;
		}
		var _loc5_:Float = bmd.width;
		var _loc6_:Float = bmd.height;
		var _loc4_ = ASCompat.floatToInt(Math.min(3, Math.min(_loc5_, _loc6_) / 2));
		bmd.fillRect(new Rectangle(0, 0, _loc5_, _loc4_), (ASCompat.floatToInt(0xFFFF0000) | 0xFF00D9:UInt));
		bmd.fillRect(new Rectangle(0, _loc6_ - _loc4_, _loc5_, _loc4_), (ASCompat.floatToInt(0xFFFF0000) | 0xFF00D9:UInt));
		bmd.fillRect(new Rectangle(0, 0, _loc4_, _loc6_), (ASCompat.floatToInt(0xFFFF0000) | 0xFF00D9:UInt));
		bmd.fillRect(new Rectangle(_loc5_ - _loc4_, 0, _loc4_, _loc6_), (ASCompat.floatToInt(0xFFFF0000) | 0xFF00D9:UInt));
	}

	public static function report(facade:DBFacade, category:String, assetName:String, swfPath:String, reason:String, asError:Bool = false) {
		if (swfPath != null && SOUND_ONLY_SWF.test(swfPath)) {
			return;
		}
		var _loc8_ = category + "|" + assetName + "|" + swfPath + "|" + reason;
		if (ASCompat.toBool(sReported[_loc8_])) {
			return;
		}
		sReported[_loc8_] = true;
		var _loc7_ = "SWF fallback [" + category + "] " + assetName + " (" + reason + ") path=" + swfPath + describeContext(facade, swfPath);
		if (asError) {
			try {
				Logger.error(_loc7_);
			} catch (e:Dynamic) {}
		} else {
			Logger.warnch("SwfFallback", _loc7_);
		}
	}

	static function describeContext(facade:DBFacade, swfPath:String):String {
		var _loc3_ = facade != null ? facade.assetLoadingComponent : null;
		var _loc4_:String = null;
		try {
			_loc4_ = swfPath != null ? StarlingAssetMapper.getBiomeKeyFromPath(swfPath) : null;
		} catch (e:Dynamic) {
			_loc4_ = "<unmapped>";
		}
		return " [context: starlingReady=" + (_loc3_ != null && _loc3_.isStarlingReady) + " loadPending=" + (_loc3_ != null && _loc3_.isStarlingLoadPending)
			+ " floorBiome=" + (_loc3_ != null ? _loc3_.currentFloorBiome : null) + " purgeCount=" + (_loc3_ != null ? _loc3_.starlingPurgeCount : -1)
			+ " pathBiome=" + _loc4_ + "]";
	}

	static function __init__() {
		sReported = {};
	}
}
