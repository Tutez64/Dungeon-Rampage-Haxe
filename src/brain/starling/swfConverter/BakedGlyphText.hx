package brain.starling.swfConverter;

import starling.display.Image;
import starling.display.MeshBatch;
import starling.rendering.Painter;
import starling.styles.MeshStyle;

class BakedGlyphText extends MeshBatch {
	static var sScratch:Image;

	var mFont:BakedGlyphFont;

	var mColor:UInt = (16777215 : UInt);

	var mCodes:Vector<Int> = new Vector((0 : UInt));

	var mCount:Int = 0;

	var mWidth:Float = 0;

	var mDisposed:Bool = false;

	public function new(font:BakedGlyphFont) {
		super();
		mFont = font;
		batchable = true;
		touchable = false;
	}

	@:isVar public var font(get, set):BakedGlyphFont;

	public function get_font():BakedGlyphFont {
		return mFont;
	}

	function set_font(value:BakedGlyphFont):BakedGlyphFont {
		if (mDisposed) {
			return value;
		}
		mFont = value;
		layout();
		return value;
	}

	override public function get_color():UInt {
		return mColor;
	}

	override public function set_color(value:UInt):UInt {
		mColor = value;
		if (numVertices > 0) {
			super.color = value;
		}
		return value;
	}

	@:isVar public var textWidth(get, never):Float;

	public function get_textWidth():Float {
		return mWidth;
	}

	public function setText(text:String) {
		var _loc3_ = 0;
		var _loc2_ = text != null ? text.length : 0;
		if (mCodes.length < _loc2_) {
			mCodes.length = _loc2_;
		}
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			mCodes[_loc3_] = text.charCodeAt(_loc3_);
			_loc3_++;
		}
		mCount = _loc2_;
		layout();
	}

	override public function render(painter:Painter) {
		if (mFont == null || !mFont.alive) {
			return;
		}
		super.render(painter);
	}

	override public function dispose() {
		mDisposed = true;
		mFont = null;
		super.dispose();
	}

	function layout() {
		var _loc2_ = 0;
		var _loc5_ = 0;
		if (mDisposed) {
			return;
		}
		clear();
		mWidth = 0;
		if (mFont == null || !mFont.alive) {
			return;
		}
		var _loc3_:Float = 0;
		_loc5_ = 0;
		while (_loc5_ < mCount) {
			_loc3_ += mFont.advance(mCodes[_loc5_]);
			_loc5_++;
		}
		mWidth = _loc3_;
		var _loc6_ = mFont.pixelScale;
		var _loc1_ = Math.fround(2 * _loc6_) / _loc6_;
		var _loc4_ = -_loc1_;
		if (sScratch == null) {
			sScratch = new Image(null);
		}
		var _loc7_ = sScratch;
		if (_loc7_.style.type != style.type) {
			_loc7_.style = ASCompat.dynamicAs(ASCompat.createInstance(style.type, []), MeshStyle);
		}
		_loc5_ = 0;
		while (_loc5_ < mCount) {
			_loc2_ = mCodes[_loc5_];
			if (!mFont.hasGlyph(_loc2_)) {
				_loc4_ += mFont.advance(_loc2_);
			} else {
				_loc7_.texture = mFont.glyphTexture(_loc2_);
				_loc7_.readjustSize();
				_loc7_.x = _loc4_ + mFont.glyphOffsetX(_loc2_);
				_loc7_.y = -_loc1_ + mFont.glyphOffsetY(_loc2_);
				addMesh(_loc7_);
				_loc4_ += mFont.advance(_loc2_);
			}
			_loc5_++;
		}
		if (mColor != 16777215 && numVertices > 0) {
			super.color = mColor;
		}
	}
}
