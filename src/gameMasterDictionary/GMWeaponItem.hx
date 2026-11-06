package gameMasterDictionary;

import brain.logger.Logger;
import dBGlobals.As3Compat;

class GMWeaponItem extends GMInventoryBase {
	public static var MELEE_WEAPON_SORT:Vector<String> = Vector.ofArray([
		"AXE_TYPE",
		"HAMMER_TYPE",
		"SWORD_TYPE",
		"MEATCLEAVER_TYPE",
		"COOKING_TYPE",
		"FRYING_PAN_TYPE",
		"KATANA_TYPE",
		"SPEAR_TYPE",
		"SHIELD_TYPE",
		"FARMTOOL_TYPE",
		"GREATSWORD_TYPE",
		"FLAIL_TYPE",
		"MACE_TYPE",
		"LIGHT_SPEAR_TYPE",
		"HEAVY_SPEAR_TYPE"
	]);

	public static var SHOOTING_WEAPON_SORT:Vector<String> = Vector.ofArray([
		"BOW_TYPE",
		"CROSSBOW_TYPE",
		"PISTOL_TYPE",
		"THROWING_TYPE",
		"HEAVY_THROWING_TYPE",
		"LIGHT_THROWING_TYPE",
		"TRAP_TYPE",
		"SEED_TYPE",
		"THROWING_SPEAR_TYPE"
	]);

	public static var MAGIC_WEAPON_SORT:Vector<String> = Vector.ofArray([
		"LIGHTNING_STAFF_TYPE",
		"FIRE_STAFF_TYPE",
		"STAFF_TYPE",
		"LIGHTNING_MAGIC_TYPE",
		"FIRE_MAGIC_TYPE",
		"DARK_MAGIC_TYPE",
		"SCROLL_TYPE",
		"FIRE_RUNE_TYPE",
		"FLAME_STAFF_TYPE",
		"FIRE_GLOVE_TYPE",
		"FIRE_ORB_TYPE",
		"DRAGON_CHARM_TYPE"
	]);

	public static var ALL_WEAPON_SORT:Vector<String> = GMWeaponItem.MELEE_WEAPON_SORT.concat(GMWeaponItem.SHOOTING_WEAPON_SORT)
		.concat(GMWeaponItem.MAGIC_WEAPON_SORT);

	public var WeaponController:String;

	public var WeaponAestheticList:Vector<GMWeaponAesthetic>;

	public var TapTitle:String;

	public var TapIcon:String;

	public var TapDescription:String;

	public var Speed:Float = Math.NaN;

	public var ScalingProjectileStartAngle:Float = Math.NaN;

	public var ScalingProjectileMinDistance:Float = Math.NaN;

	public var ScalingProjectileMaxDistance:Float = Math.NaN;

	public var ScalingProjectileEndAngle:Float = Math.NaN;

	public var ScalingMinProjectiles:UInt = 0;

	public var ScalingMaxProjectiles:UInt = 0;

	public var ScalingMaxPowerMultiplier:Float = Math.NaN;

	public var ScalingHeroMinDistance:Float = Math.NaN;

	public var ScalingHeroMaxDistance:Float = Math.NaN;

	public var ScalingFactor:Float = Math.NaN;

	public var ScalingDistanceTime:Float = Math.NaN;

	public var ScaleTapAttack:Bool = false;

	public var RepeaterOnlyChargeRepeated:Bool = false;

	public var RepeaterMaxSpeedPercent:Float = Math.NaN;

	public var RepeaterIncrementSpeedPercent:Float = Math.NaN;

	public var Release:String;

	public var Power:UInt = 0;

	public var PotentialModifiers:Vector<GMModifier>;

	public var PotentialLegendaryModifiers:Vector<GMLegendaryModifier>;

	public var MasterType:String;

	public var HoldingAttack:String;

	public var HoldTitle:String;

	public var HoldIcon:String;

	public var HoldDescription:String;

	public var DoNotDrop:Bool = false;

	public var ControllerTimeTillEnd:Float = Math.NaN;

	public var ClassType:String;

	public var ChooseRandomAttack:Bool = false;

	public var ChargeAttack:String;

	public var AttackArray:Array<ASAny>;

	public var AbilityArray:Array<ASAny>;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		Release = jsonAsset.Release;
		ClassType = jsonAsset.ClassType;
		MasterType = jsonAsset.Mastertype;
		DoNotDrop = ASCompat.toBool(jsonAsset.DoNotDrop);
		Power = (ASCompat.toInt(jsonAsset.Power) : UInt);
		Speed = ASCompat.toNumber(jsonAsset.Speed);
		ScalingFactor = ASCompat.toNumber(jsonAsset.ScalingFactor);
		WeaponController = jsonAsset.WeaponController;
		ControllerTimeTillEnd = ASCompat.toNumber(jsonAsset.ControllerTimeTillEnd);
		HoldingAttack = jsonAsset.HoldingAttack;
		ChargeAttack = jsonAsset.ChargeAttack != null ? jsonAsset.ChargeAttack : "";
		ScalingMaxPowerMultiplier = jsonAsset.ScalingMaxPowerMultiplier != null ? ASCompat.toNumber(jsonAsset.ScalingMaxPowerMultiplier) : 1;
		ScaleTapAttack = ASCompat.toBool(jsonAsset.ScaleTapAttack);
		ScalingMinProjectiles = (jsonAsset.ScalingMinProjectileMultiplier != null ? (ASCompat.toInt(jsonAsset.ScalingMinProjectileMultiplier) : UInt) : (1 : UInt):UInt);
		ScalingMaxProjectiles = (jsonAsset.ScalingMaxProjectileMultiplier != null ? (ASCompat.toInt(jsonAsset.ScalingMaxProjectileMultiplier) : UInt) : (1 : UInt):UInt);
		ScalingProjectileStartAngle = jsonAsset.ScalingProjectileStartAngle != null ? ASCompat.toNumber(jsonAsset.ScalingProjectileStartAngle) : 0;
		ScalingProjectileEndAngle = jsonAsset.ScalingProjectileEndAngle != null ? ASCompat.toNumber(jsonAsset.ScalingProjectileEndAngle) : 0;
		ScalingDistanceTime = jsonAsset.ScalingDistanceTime != null ? ASCompat.toNumber(jsonAsset.ScalingDistanceTime) : 0;
		ScalingHeroMinDistance = jsonAsset.ScalingHeroMinDistance != null ? ASCompat.toNumber(jsonAsset.ScalingHeroMinDistance) : 0;
		ScalingHeroMaxDistance = jsonAsset.ScalingHeroMaxDistance != null ? ASCompat.toNumber(jsonAsset.ScalingHeroMaxDistance) : 0;
		ScalingProjectileMinDistance = jsonAsset.ScalingProjectileMinDistance != null ? ASCompat.toNumber(jsonAsset.ScalingProjectileMinDistance) : 0;
		ScalingProjectileMaxDistance = jsonAsset.ScalingProjectileMaxDistance != null ? ASCompat.toNumber(jsonAsset.ScalingProjectileMaxDistance) : 0;
		RepeaterOnlyChargeRepeated = ASCompat.toBool(jsonAsset.RepeaterOnlyChargeRepeated);
		RepeaterIncrementSpeedPercent = jsonAsset.RepeaterIncrementSpeedPercent != null ? ASCompat.toNumber(jsonAsset.RepeaterIncrementSpeedPercent) : 0.5;
		RepeaterMaxSpeedPercent = jsonAsset.RepeaterMaxSpeedPercent != null ? ASCompat.toNumber(jsonAsset.RepeaterMaxSpeedPercent) : 3;
		TapIcon = jsonAsset.TapIcon;
		TapTitle = As3Compat.truthy(jsonAsset.TapTitle) ? jsonAsset.TapTitle : "";
		TapDescription = As3Compat.truthy(jsonAsset.TapDescription) ? jsonAsset.TapDescription : "";
		HoldIcon = jsonAsset.HoldIcon;
		HoldTitle = As3Compat.truthy(jsonAsset.HoldTitle) ? jsonAsset.HoldTitle : "";
		HoldDescription = As3Compat.truthy(jsonAsset.HoldDescription) ? jsonAsset.HoldDescription : "";
		AbilityArray = [
			jsonAsset.Ability1,
			jsonAsset.Ability2,
			jsonAsset.Ability3,
			jsonAsset.Ability4,
			jsonAsset.Ability5
		];
		AttackArray = [
			jsonAsset.Attack1,
			jsonAsset.Attack2,
			jsonAsset.Attack3,
			jsonAsset.Attack4,
			jsonAsset.Attack5,
			jsonAsset.Attack6,
			jsonAsset.Attack7,
			jsonAsset.Attack8,
			jsonAsset.Attack9,
			jsonAsset.Attack10
		];
		ChooseRandomAttack = ASCompat.toBool(jsonAsset.ChooseRandomAttack);
		WeaponAestheticList = new Vector<GMWeaponAesthetic>();
		ItemCategory = GMInventoryBase.WEAPON_CATEGORY;
		PotentialModifiers = new Vector<GMModifier>();
		PotentialLegendaryModifiers = new Vector<GMLegendaryModifier>();
	}

	public function getWeaponAesthetic(level:UInt, isLegendary:Bool = false):GMWeaponAesthetic {
		var _loc6_ = 0;
		if (WeaponAestheticList == null) {
			Logger.error("No weapon aesthetic list on weapon: " + Constant + ", id: " + Std.string(Id));
			return null;
		}
		var _loc3_ = level > 100 ? (100 : UInt) : level;
		var _loc4_ = 0;
		var _loc5_ = WeaponAestheticList.length;
		while (_loc4_ < _loc5_) {
			_loc6_ = _loc4_++;
			if (isLegendary) {
				if (WeaponAestheticList[_loc6_].IsLegendary) {
					return WeaponAestheticList[_loc6_];
				}
			} else if (_loc3_ >= WeaponAestheticList[_loc6_].MinLevel && _loc3_ <= WeaponAestheticList[_loc6_].MaxLevel) {
				return WeaponAestheticList[_loc6_];
			}
		}
		if (isLegendary) {
			return WeaponAestheticList[0];
		}
		Logger.error("Unable to find Weapon Aesthetic for weapon : " + Constant);
		return WeaponAestheticList[0];
	}
}
