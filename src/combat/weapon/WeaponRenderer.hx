package combat.weapon;

import actor.ActorRenderer;
import brain.render.IRenderer;
import dBGlobals.DBGlobal;
import facade.DBFacade;

class WeaponRenderer extends ActorRenderer {
	var mWeaponGameObject:WeaponGameObject;

	public function new(dbFacade:DBFacade, weaponGameObject:WeaponGameObject, triggerState:Bool) {
		super(dbFacade, weaponGameObject.actorGameObject, triggerState);
		mWeaponGameObject = weaponGameObject;
	}

	override public function destroy() {
		super.destroy();
		mWeaponGameObject = null;
	}

	override function loadErrorCallback() {}

	override function getSpriteSheetClassName(animName:String):String {
		return mActorGameObject.actorData.assetClassName + "_" + animName + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".png";
	}

	override function get_movieClipClassName():String {
		return super.movieClipClassName + "_" + mWeaponGameObject.weaponAesthetic.ModelName;
	}

	override function setAnimInDictionary(animName:String, renderer:IRenderer) {
		super.setAnimInDictionary(animName, renderer);
		stop();
	}

	override function get_swfFilePath():String {
		if (DBGlobal.endsWith(super.swfFilePath, ".HD.swf")) {
			return super.swfFilePath.substring(0, super.swfFilePath.length - 7)
				+ "_"
				+ mWeaponGameObject.weaponAesthetic.ModelName
				+ ".HD.swf";
		}
		return super.swfFilePath.substring(0, super.swfFilePath.length - 4)
			+ "_"
			+ mWeaponGameObject.weaponAesthetic.ModelName
			+ ".swf";
	}
}
