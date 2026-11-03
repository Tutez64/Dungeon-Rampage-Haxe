package uI;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Vector3D;

class ControllerIconData {
	public var mControllerGlyph:DisplayObject;

	public var mOwner:MovieClip;

	public var mIsHidden:Bool = false;

	public var mActionName:String;

	public var mGlyphFilePath:String;

	public var mPosition:Vector3D;

	public var mScale:Point;

	public function new(inControllerGlyph:DisplayObject, inOwner:MovieClip, inIsHidden:Bool = true) {
		mControllerGlyph = inControllerGlyph;
		mOwner = inOwner;
		mIsHidden = inIsHidden;
	}

	public function destroy() {
		mControllerGlyph = null;
		mOwner = null;
	}
}
