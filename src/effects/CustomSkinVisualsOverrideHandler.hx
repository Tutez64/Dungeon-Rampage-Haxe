package effects;

import actor.ActorGameObject;
import brain.gameObject.GameObject;
import facade.DBFacade;

class CustomSkinVisualsOverrideHandler {
	static inline final DARK_MAGE_SKIN_ID = (168 : UInt);

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
	}

	public function customSkinVFXVisualsOverrider(vfxName:String, attackerId:UInt):String {
		var _loc4_:GameObject = null;
		var _loc3_:ActorGameObject = null;
		if (attackerId != 0) {
			_loc4_ = mDBFacade.gameObjectManager.getReferenceFromId(attackerId);
			_loc3_ = ASCompat.reinterpretAs(_loc4_, ActorGameObject);
			if (_loc3_ != null && _loc3_.gmSkin != null && _loc3_.gmSkin.Id == 168) {
				if (vfxName == "db_fx_shockStun") {
					return "db_fx_darkShockStun";
				}
			}
		}
		return vfxName;
	}

	public function customSkinBusterVisualOverrider(effectName:String, actorGameObject:ActorGameObject):String {
		if (actorGameObject.gmSkin != null) {
			if (actorGameObject.gmSkin.Id == 168) {
				if (effectName == "sorcerer_db") {
					return "sorcerer_dark_db";
				}
				if (effectName == "db_fx_knockback_sorcerer") {
					return "db_fx_knockback_sorcerer_dark";
				}
				if (effectName == "Thunderbolt") {
					return "thunderbolt_dark";
				}
				if (effectName == "ShockNova") {
					return "ShockNova_dark";
				}
				if (effectName == "db_fx_charge_release") {
					return "db_fx_charge_release_dark";
				}
				if (effectName == "db_fx_magicCircle") {
					return "db_fx_magicCircle_dark";
				}
			}
		}
		return effectName;
	}

	public function customSkinProjectileVisualOverrider(effectName:String, skinId:UInt):String {
		if (skinId == 168) {
			return effectName + "_dark";
		}
		return effectName;
	}
}
