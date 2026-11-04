package effects;

import brain.utils.IPoolable;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import dr_floor.FloorObject;
import flash.geom.Vector3D;

class EffectGameObject extends FloorObject implements IPoolable {
	var mEffectView:EffectView;

	public var swfPath:String;

	public var className:String;

	public var iconInsert:EffectIconInsert;

	public var fallbackCategory:String;

	var mAssetLoadedCallback:ASFunction;

	public function new(facade:DBFacade, swfPath:String, className:String, playRate:Float, remoteId:UInt = (0 : UInt), assetLoadedCallback:ASFunction = null,
			iconInsert:EffectIconInsert = null, fallbackCategory:String = null) {
		this.swfPath = swfPath;
		this.className = className;
		this.iconInsert = iconInsert;
		this.fallbackCategory = fallbackCategory;
		mAssetLoadedCallback = assetLoadedCallback;
		super(facade, remoteId);
		this.layer = 20;
		this.init();
		mEffectView.setPlayRate(playRate);
	}

	public function setAssetLoadedCallback(callback:ASFunction) {
		mAssetLoadedCallback = callback;
	}

	public function setIconInsert(iconInsert:EffectIconInsert) {
		this.iconInsert = iconInsert;
		if (mEffectView != null) {
			mEffectView.setIconInsert(iconInsert);
		}
	}

	public function postCheckout(isNewObject:Bool) {
		if (!isNewObject && mAssetLoadedCallback != null && view.movieClipRenderer != null) {
			view.movieClipRenderer.clip.gotoAndStop(0);
			mAssetLoadedCallback(view.movieClipRenderer.clip);
		}
	}

	public function postCheckin() {
		mAssetLoadedCallback = null;
		setIconInsert(null);
		mEffectView.stop();
	}

	public function getPoolKey():String {
		return swfPath + ":" + className;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		mEffectView.snapPosition(pos);
		return pos;
	}

	override function buildView() {
		mEffectView = new EffectView(mDBFacade, this, mAssetLoadedCallback);
		MemoryTracker.track(mEffectView, "EffectView \'" + swfPath + ":" + className + "\' - created in EffectGameObject.buildView()", "pool");
		this.view = mEffectView;
	}

	@:isVar public var rotation(get, set):Float;

	public function get_rotation():Float {
		return mFloorView.rotation;
	}

	function set_rotation(rot:Float):Float {
		return this.view.rotation = rot;
	}

	override public function destroy() {
		mAssetLoadedCallback = null;
		mEffectView = null;
		super.destroy();
	}
}
