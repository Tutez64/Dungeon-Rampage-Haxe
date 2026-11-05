package combat.weapon;

import actor.ActorRenderer;
import brain.render.IRenderer;
import facade.DBFacade;
import starling.extensions.animate.Animation;

class WeaponRenderer extends ActorRenderer {
	public static inline final WEAPON_DRAW_ORDER_OFFSET:Float = 0.1;

	static var DIRECTION_LABEL_SUFFIXES:Array<ASAny>;

	var mWeaponGameObject:WeaponGameObject;

	public function new(dbFacade:DBFacade, weaponGameObject:WeaponGameObject, triggerState:Bool) {
		super(dbFacade, weaponGameObject.actorGameObject, triggerState);
		mWeaponGameObject = weaponGameObject;
	}

	public static function weaponSwfFilePath(actorSwfFilePath:String, modelName:String):String {
		return actorSwfFilePath.substring(0, actorSwfFilePath.length - 4) + "_" + modelName + ".swf";
	}

	override function syncStarlingTransform(updateCulling:Bool = false) {
		if (mStarlingRenderer != null) {
			mStarlingRenderer.drawOrderOffsetY = 0.1;
		}
		super.syncStarlingTransform(updateCulling);
	}

	override function testCulled(drawX:Float, drawY:Float, scale:Float):Bool {
		var _loc4_ = mActorGameObject.actorView != null ? mActorGameObject.actorView.bodyAnimRenderer : null;
		return _loc4_ != null && _loc4_.hasStarlingArt ? _loc4_.isCulled : super.testCulled(drawX, drawY, scale);
	}

	public function followWielderCulling(culled:Bool) {
		mCulled = mPendingVisible && culled;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setVisibility(mPendingVisible, mCulled);
		}
	}

	override public function destroy() {
		super.destroy();
		mWeaponGameObject = null;
	}

	override function loadErrorCallback() {}

	override function get_fallbackCategory():String {
		return "WEAPON:" + mWeaponGameObject.weaponAesthetic.ModelName;
	}

	override function getSpriteSheetClassName(animName:String):String {
		return mActorGameObject.actorData.assetClassName + "_" + animName + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".png";
	}

	override function get_movieClipClassName():String {
		return super.movieClipClassName + "_" + mWeaponGameObject.weaponAesthetic.ModelName;
	}

	override function isStarlingMultiDirectionAnim(animation:Animation):Bool {
		if (super.isStarlingMultiDirectionAnim(animation)) {
			return true;
		}
		var _loc2_:String;
		final __ax4_iter_335 = DIRECTION_LABEL_SUFFIXES;
		if (checkNullIteratee(__ax4_iter_335))
			for (_tmp_ in __ax4_iter_335) {
				_loc2_ = _tmp_;
				if (animation.hasFrameLabelSuffix(_loc2_)) {
					return true;
				}
			}
		return false;
	}

	override function setAnimInDictionary(animName:String, renderer:IRenderer) {
		super.setAnimInDictionary(animName, renderer);
		stop();
	}

	override function updateStarlingHitArea() {}

	override function get_backgroundLoadTier():Int {
		var _loc1_ = super.backgroundLoadTier;
		return _loc1_ == 0 ? 1 : _loc1_;
	}

	override function get_swfFilePath():String {
		return weaponSwfFilePath(super.swfFilePath, mWeaponGameObject.weaponAesthetic.ModelName);
	}

	static function __init__() {
		DIRECTION_LABEL_SUFFIXES = ["_angA", "_angB", "_angC", "_angD", "_angE"];
	}
}
