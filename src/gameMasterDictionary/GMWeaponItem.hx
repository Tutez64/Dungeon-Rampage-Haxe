package gameMasterDictionary;

import brain.logger.Logger;

class GMWeaponItem extends GMInventoryBase {
	public static final MELEE_WEAPON_SORT:Vector<String> = Vector.ofArray([
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

	public static final SHOOTING_WEAPON_SORT:Vector<String> = Vector.ofArray([
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

	public static final MAGIC_WEAPON_SORT:Vector<String> = Vector.ofArray([
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

	public static final ALL_WEAPON_SORT:Vector<String> = MELEE_WEAPON_SORT.concat(SHOOTING_WEAPON_SORT).concat(MAGIC_WEAPON_SORT);

	public var Release:String;

	public var ClassType:String;

	public var MasterType:String;

	public var DoNotDrop:Bool = false;

	public var Power:UInt = 0;

	public var Speed:Float = Math.NaN;

	public var ScalingFactor:Float = Math.NaN;

	public var WeaponController:String;

	public var ControllerTimeTillEnd:Float = Math.NaN;

	public var HoldingAttack:String;

	public var ChargeAttack:String;

	public var ScalingMaxPowerMultiplier:Float = Math.NaN;

	public var ScaleTapAttack:Bool = false;

	public var ScalingMinProjectiles:UInt = 0;

	public var ScalingMaxProjectiles:UInt = 0;

	public var ScalingProjectileStartAngle:Float = Math.NaN;

	public var ScalingProjectileEndAngle:Float = Math.NaN;

	public var ScalingDistanceTime:Float = Math.NaN;

	public var ScalingHeroMinDistance:Float = Math.NaN;

	public var ScalingHeroMaxDistance:Float = Math.NaN;

	public var ScalingProjectileMinDistance:Float = Math.NaN;

	public var ScalingProjectileMaxDistance:Float = Math.NaN;

	public var RepeaterOnlyChargeRepeated:Bool = false;

	public var RepeaterIncrementSpeedPercent:Float = Math.NaN;

	public var RepeaterMaxSpeedPercent:Float = Math.NaN;

	public var AbilityArray:Array<ASAny>;

	public var AttackArray:Array<ASAny>;

	public var PotentialModifiers:Vector<GMModifier>;

	public var PotentialLegendaryModifiers:Vector<GMLegendaryModifier>;

	public var WeaponAestheticList:Vector<GMWeaponAesthetic>;

	public var TapIcon:String;

	public var TapTitle:String;

	public var TapDescription:String;

	public var HoldIcon:String;

	public var HoldTitle:String;

	public var HoldDescription:String;

	public var ChooseRandomAttack:Bool = false;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		Release = jsonAsset.Release;
		ClassType = jsonAsset.ClassType;
		MasterType = jsonAsset.Mastertype;
		DoNotDrop = ASCompat.toBool(jsonAsset.DoNotDrop);
		Power = (ASCompat.toInt(jsonAsset.Power) : UInt);
		Speed = ASCompat.toNumberField(jsonAsset, "Speed");
		ScalingFactor = ASCompat.toNumberField(jsonAsset, "ScalingFactor");
		WeaponController = jsonAsset.WeaponController;
		ControllerTimeTillEnd = ASCompat.toNumberField(jsonAsset, "ControllerTimeTillEnd");
		HoldingAttack = jsonAsset.HoldingAttack;
		ChargeAttack = jsonAsset.ChargeAttack != null ? jsonAsset.ChargeAttack : "";
		ScalingMaxPowerMultiplier = ASCompat.toNumber(jsonAsset.ScalingMaxPowerMultiplier != null ? ASCompat.toNumberField(jsonAsset,
			"ScalingMaxPowerMultiplier") : 1);
		ScaleTapAttack = ASCompat.toBool(jsonAsset.ScaleTapAttack);
		ScalingMinProjectiles = (ASCompat.toInt(jsonAsset.ScalingMinProjectileMultiplier != null ? (ASCompat.toInt(jsonAsset.ScalingMinProjectileMultiplier) : UInt) : (1 : UInt)) : UInt);
		ScalingMaxProjectiles = (ASCompat.toInt(jsonAsset.ScalingMaxProjectileMultiplier != null ? (ASCompat.toInt(jsonAsset.ScalingMaxProjectileMultiplier) : UInt) : (1 : UInt)) : UInt);
		ScalingProjectileStartAngle = ASCompat.toNumber(jsonAsset.ScalingProjectileStartAngle != null ? ASCompat.toNumberField(jsonAsset,
			"ScalingProjectileStartAngle") : 0);
		ScalingProjectileEndAngle = ASCompat.toNumber(jsonAsset.ScalingProjectileEndAngle != null ? ASCompat.toNumberField(jsonAsset,
			"ScalingProjectileEndAngle") : 0);
		ScalingDistanceTime = ASCompat.toNumber(jsonAsset.ScalingDistanceTime != null ? ASCompat.toNumberField(jsonAsset, "ScalingDistanceTime") : 0);
		ScalingHeroMinDistance = ASCompat.toNumber(jsonAsset.ScalingHeroMinDistance != null ? ASCompat.toNumberField(jsonAsset, "ScalingHeroMinDistance") : 0);
		ScalingHeroMaxDistance = ASCompat.toNumber(jsonAsset.ScalingHeroMaxDistance != null ? ASCompat.toNumberField(jsonAsset, "ScalingHeroMaxDistance") : 0);
		ScalingProjectileMinDistance = ASCompat.toNumber(jsonAsset.ScalingProjectileMinDistance != null ? ASCompat.toNumberField(jsonAsset,
			"ScalingProjectileMinDistance") : 0);
		ScalingProjectileMaxDistance = ASCompat.toNumber(jsonAsset.ScalingProjectileMaxDistance != null ? ASCompat.toNumberField(jsonAsset,
			"ScalingProjectileMaxDistance") : 0);
		RepeaterOnlyChargeRepeated = ASCompat.toBool(jsonAsset.RepeaterOnlyChargeRepeated);
		RepeaterIncrementSpeedPercent = ASCompat.toNumber(jsonAsset.RepeaterIncrementSpeedPercent != null ? ASCompat.toNumberField(jsonAsset,
			"RepeaterIncrementSpeedPercent") : 0.5);
		RepeaterMaxSpeedPercent = ASCompat.toNumber(jsonAsset.RepeaterMaxSpeedPercent != null ? ASCompat.toNumberField(jsonAsset,
			"RepeaterMaxSpeedPercent") : 3);
		TapIcon = jsonAsset.TapIcon;
		TapTitle = ASCompat.toBool(jsonAsset.TapTitle) ? jsonAsset.TapTitle : "";
		TapDescription = ASCompat.toBool(jsonAsset.TapDescription) ? jsonAsset.TapDescription : "";
		HoldIcon = jsonAsset.HoldIcon;
		HoldTitle = ASCompat.toBool(jsonAsset.HoldTitle) ? jsonAsset.HoldTitle : "";
		HoldDescription = ASCompat.toBool(jsonAsset.HoldDescription) ? jsonAsset.HoldDescription : "";
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
		ItemCategory = "WEAPON";
		PotentialModifiers = new Vector<GMModifier>();
		PotentialLegendaryModifiers = new Vector<GMLegendaryModifier>();
	}

	public function getWeaponAesthetic(level:UInt, isLegendary:Bool = false):GMWeaponAesthetic {
		var _loc3_ = 0;
		if (WeaponAestheticList == null) {
			Logger.error("No weapon aesthetic list on weapon: " + this.Constant + ", id: " + this.Id);
			return null;
		}
		_loc3_ = 0;
		while (_loc3_ < WeaponAestheticList.length) {
			if (isLegendary) {
				if (WeaponAestheticList[_loc3_].IsLegendary) {
					return WeaponAestheticList[_loc3_];
				}
			} else if (level >= WeaponAestheticList[_loc3_].MinLevel && level <= WeaponAestheticList[_loc3_].MaxLevel) {
				return WeaponAestheticList[_loc3_];
			}
			_loc3_++;
		}
		if (isLegendary) {
			return WeaponAestheticList[0];
		}
		Logger.error("Unable to find Weapon Aesthetic for weapon : " + this.Constant);
		return WeaponAestheticList[0];
	}
}
