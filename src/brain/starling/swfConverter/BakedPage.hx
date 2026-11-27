package brain.starling.swfConverter;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.textures.Texture;
import starling.utils.MathUtil;

/*use*/ /*namespace*/ /*starling_internal*/ /*internal*/
class BakedPage {
	static final sRect:Rectangle = new Rectangle();

	static final sPoint:Point = new Point();

	@:allow(brain.starling.swfConverter) var texture:Texture;

	@:allow(brain.starling.swfConverter) var pixels:BitmapData;

	@:allow(brain.starling.swfConverter) var pool:String;

	@:allow(brain.starling.swfConverter) var single:Bool = false;

	@:allow(brain.starling.swfConverter) var dirty:Bool = false;

	@:allow(brain.starling.swfConverter) var needsRestore:Bool = false;

	@:allow(brain.starling.swfConverter) var cells:Int = 0;

	@:allow(brain.starling.swfConverter) var width:Int = 0;

	@:allow(brain.starling.swfConverter) var height:Int = 0;

	@:allow(brain.starling.swfConverter) var rectangle:Bool = true;

	@:allow(brain.starling.swfConverter) var retiredAt:Int = -1;

	var mPacker:ShelfPacker;

	public function new() {}

	@:allow(brain.starling.swfConverter) static function create(pool:String, width:Int, height:Int, single:Bool, force:Bool):BakedPage {
		var _loc6_ = Starling.current;
		if (_loc6_ == null || !_loc6_.contextValid) {
			return null;
		}
		var _loc7_ = _loc6_.profile != "baselineConstrained";
		if (!_loc7_) {
			width = MathUtil.getNextPowerOfTwo(width);
			height = MathUtil.getNextPowerOfTwo(height);
		}
		if (!BakeBudget.reserve(pool, width, height, force, _loc7_)) {
			return null;
		}
		var _loc8_ = new BakedPage();
		_loc8_.pool = pool;
		_loc8_.width = width;
		_loc8_.height = height;
		_loc8_.single = single;
		_loc8_.rectangle = _loc7_;
		_loc8_.mPacker = new ShelfPacker(width, height);
		try {
			_loc8_.texture = Texture.empty(width, height, true, false, false, 1);
			_loc8_.texture.root.onRestore = null;
			_loc8_.pixels = new BitmapData(width, height, true, (0 : UInt));
			_loc8_.dirty = true;
		} catch (error:Dynamic) {
			if (_loc8_.texture != null) {
				_loc8_.texture.dispose();
			}
			if (_loc8_.pixels != null) {
				_loc8_.pixels.dispose();
			}
			BakeBudget.unreserve(pool, width, height, _loc7_);
			return null;
		}
		return _loc8_;
	}

	@:allow(brain.starling.swfConverter) function place(w:Int, h:Int, out:Point):Bool {
		if (w > width || h > height) {
			return false;
		}
		if (single) {
			if (cells > 0) {
				return false;
			}
			out.setTo(0, 0);
			return true;
		}
		return mPacker.place(w, h, out);
	}

	@:allow(brain.starling.swfConverter) function free(x:Int, y:Int, w:Int) {
		if (single) {
			return;
		}
		mPacker.free(x, y, w);
	}

	@:allow(brain.starling.swfConverter) function write(bake:BakedPicture, x:Int, y:Int, slotWidth:Int, slotHeight:Int) {
		sRect.setTo(x, y, slotWidth + 1, slotHeight + 1);
		pixels.fillRect(sRect, (0 : UInt));
		sPoint.setTo(x, y);
		pixels.copyPixels(bake.bitmap, bake.bitmap.rect, sPoint);
		dirty = true;
		if (Starling.current != null) {
			Starling.current.setRequiresRedraw();
		}
	}

	@:allow(brain.starling.swfConverter) function upload():Bool {
		if (!dirty || texture == null) {
			return false;
		}
		if (needsRestore) {
			restore();
			return true;
		}
		texture.root.uploadBitmapData(pixels);
		dirty = false;
		return true;
	}

	@:allow(brain.starling.swfConverter) function restore() {
		if (texture == null) {
			return;
		}
		var _loc1_ = texture.root;
		needsRestore = true;
		_loc1_.recreateBase();
		needsRestore = false;
		_loc1_.uploadBitmapData(pixels);
		dirty = false;
	}

	@:allow(brain.starling.swfConverter) function dispose() {
		if (texture == null) {
			return;
		}
		texture.dispose();
		texture = null;
		pixels.dispose();
		pixels = null;
		BakeBudget.unreserve(pool, width, height, rectangle);
	}
}
