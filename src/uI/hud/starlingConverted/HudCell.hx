package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPicture;
import starling.textures.Texture;

/*internal*/
class HudCell extends BakedCell {
	@:allow(UI.Hud.StarlingConverted) var mKey:String;

	@:allow(UI.Hud.StarlingConverted) var mPage:HudPage;

	@:allow(UI.Hud.StarlingConverted) var mTexture:Texture;

	@:allow(UI.Hud.StarlingConverted) var mReferences:Int = 1;

	@:allow(UI.Hud.StarlingConverted) var mX:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var mY:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var mSlotWidth:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var mSlotHeight:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var mBake:BakedPicture;

	@:allow(UI.Hud.StarlingConverted) var mLiveViews:Int = 0;

	@:allow(UI.Hud.StarlingConverted) var mPinned:Bool = false;

	@:allow(UI.Hud.StarlingConverted) var mSource:HudCell;

	public function new() {
		super();
	}

	override public function get_key():String {
		return mKey;
	}

	override public function get_texture():Texture {
		return mTexture;
	}

	override public function get_pivotX():Float {
		return mBake.originX / mBake.pixelScale;
	}

	override public function get_pivotY():Float {
		return mBake.originY / mBake.pixelScale;
	}

	override public function get_pixelScale():Float {
		return mBake.pixelScale;
	}

	override public function get_pixelWidth():Int {
		return mSlotWidth;
	}

	override public function get_pixelHeight():Int {
		return mSlotHeight;
	}

	override public function get_isEmpty():Bool {
		return mBake.empty;
	}

	override public function get_refCount():Int {
		return mReferences;
	}

	override public function get_alive():Bool {
		return mTexture != null;
	}

	override public function opaqueAt(localX:Float, localY:Float, threshold:UInt = (16 : UInt)):Bool {
		if (!alive) {
			return false;
		}
		var _loc4_ = Math.floor(localX * pixelScale);
		var _loc5_ = Math.floor(localY * pixelScale);
		if (_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= mSlotWidth || _loc5_ >= mSlotHeight) {
			return false;
		}
		return ((mPage.mPixels.getPixel32(mX + _loc4_, mY + _loc5_) : Int) >>> 24 : UInt) > threshold;
	}
}
