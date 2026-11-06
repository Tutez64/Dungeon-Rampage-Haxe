package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedPicture;
import brain.starling.swfConverter.FlashBaker;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;

class StarlingRaster {
	public static inline final MAX_SIDE = 1024;

	public static inline final BORDER = 1;

	public function new() {}

	@:allow(uI.hud.starlingConverted) static function requestedScale(bake:BakedPicture):Float {
		return Math.isNaN(bake.requestedScale) ? bake.pixelScale : bake.requestedScale;
	}

	@:allow(uI.hud.starlingConverted) static function limit(bake:BakedPicture, requested:Float = null) {
		if (requested == null)
			requested = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc4_:BitmapData = null;
		if (Math.isNaN(requested)) {
			requested = requestedScale(bake);
		}
		var _loc3_ = ASCompat.floatToInt(Math.max(bake.bitmap.width, bake.bitmap.height));
		if (_loc3_ > 1024) {
			_loc5_ = 1024 / _loc3_;
			_loc4_ = new BitmapData(ASCompat.floatToInt(Math.max(1, Math.ffloor(bake.bitmap.width * _loc5_))),
				ASCompat.floatToInt(Math.max(1, Math.ffloor(bake.bitmap.height * _loc5_))), true, (0 : UInt));
			_loc4_.draw(bake.bitmap, new Matrix(_loc5_, 0, 0, _loc5_), null, null, null, true);
			bake.bitmap.dispose();
			bake.bitmap = _loc4_;
			bake.originX = Math.round(bake.originX * _loc5_);
			bake.originY = Math.round(bake.originY * _loc5_);
			bake.pixelScale *= _loc5_;
		}
		bake.requestedScale = requested;
	}

	public static function bake(source:DisplayObject, pixelScale:Float, hide:Vector<DisplayObject> = null, ownFilters:Bool = true):BakedPicture {
		var _loc5_:BakedPicture = null;
		try {
			_loc5_ = FlashBaker.bake(source, pixelScale, hide, ownFilters, true, true);
			if (_loc5_ != null) {
				limit(_loc5_, pixelScale);
			}
			return _loc5_;
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
		return null;
	}
}
