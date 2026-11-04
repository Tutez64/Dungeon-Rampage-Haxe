package gameMasterDictionary;

import brain.logger.Logger;
import dBGlobals.As3Compat;
import dBGlobals.DBGlobal;
import gamemasterdictionary._gMHero.ExpToLevel;

class GMHero extends GMActor {
	public static var BASE_MAX_LEVEL:UInt = (100 : UInt);

	public static var LEVELS_PER_ASCENSION:UInt = (5 : UInt);

	public static var MAX_LEVEL:UInt = (150 : UInt);

	public static var MAX_EFFECTIVE_ASCENSIONS:UInt = (10 : UInt);

	public var UpgradeToSlotOffset:Vector<Vector<Int>>;

	public var UISwfFilepath:String;

	public var TeamAttack:String;

	public var StoreDescription:String;

	public var StatUpgrade4:String;

	public var StatUpgrade3:String;

	public var StatUpgrade2:String;

	public var StatUpgrade1:String;

	public var SpeedRating:Float = Math.NaN;

	public var Power4R5:Float = Math.NaN;

	public var Power4R4:Float = Math.NaN;

	public var Power4R3:Float = Math.NaN;

	public var Power4R2:Float = Math.NaN;

	public var Power4R1:Float = Math.NaN;

	public var Power4:String;

	public var Power3R5:Float = Math.NaN;

	public var Power3R4:Float = Math.NaN;

	public var Power3R3:Float = Math.NaN;

	public var Power3R2:Float = Math.NaN;

	public var Power3R1:Float = Math.NaN;

	public var Power3:String;

	public var Power2R5:Float = Math.NaN;

	public var Power2R4:Float = Math.NaN;

	public var Power2R3:Float = Math.NaN;

	public var Power2R2:Float = Math.NaN;

	public var Power2R1:Float = Math.NaN;

	public var Power2:String;

	public var Power1R5:Float = Math.NaN;

	public var Power1R4:Float = Math.NaN;

	public var Power1R3:Float = Math.NaN;

	public var Power1R2:Float = Math.NaN;

	public var Power1R1:Float = Math.NaN;

	public var Power1:String;

	public var PortraitClassName:String;

	public var Pet:String;

	public var Normalized_upgrades:StatVector;

	public var IsExclusive:Bool = false;

	public var Hidden:Bool = false;

	public var ExperienceToLevel:Vector<ExpToLevel>;

	public var DefenseRating:Float = Math.NaN;

	public var DefaultSkin:String;

	public var DBuster1:String;

	public var Coins:UInt = 0;

	public var CharUnlockLocation:String;

	public var CharNickname:String;

	public var CharLikes:String;

	public var CharDislikes:String;

	public var CharDescription:String;

	public var Cash:UInt = 0;

	public var AttackRating:Float = Math.NaN;

	public var AmtStat4:Float = Math.NaN;

	public var AmtStat3:Float = Math.NaN;

	public var AmtStat2:Float = Math.NaN;

	public var AmtStat1:Float = Math.NaN;

	public var AllowedWeapons:GMMap;

	public function new(jsonAsset:ASObject = /*undefined*/ null, splitTests:ASAny = /*undefined*/ null) {
		var _loc3_ = false;
		super(jsonAsset);
		Normalized_upgrades = new StatVector();
		UpgradeToSlotOffset = new Vector<Vector<Int>>();
		UpgradeToSlotOffset.push(new Vector<Int>());
		UpgradeToSlotOffset.push(new Vector<Int>());
		UpgradeToSlotOffset.push(new Vector<Int>());
		UpgradeToSlotOffset.push(new Vector<Int>());
		ExperienceToLevel = new Vector<ExpToLevel>();
		IsExclusive = ASCompat.toBool(jsonAsset.IsExclusive);
		Hidden = ASCompat.toBool(jsonAsset.Hidden);
		AmtStat1 = ASCompat.toNumber(jsonAsset.AmtStat1);
		StatUpgrade1 = jsonAsset.StatUpgrade1;
		AmtStat2 = ASCompat.toNumber(jsonAsset.AmtStat2);
		StatUpgrade2 = jsonAsset.StatUpgrade2;
		AmtStat3 = ASCompat.toNumber(jsonAsset.AmtStat3);
		StatUpgrade3 = jsonAsset.StatUpgrade3;
		AmtStat4 = ASCompat.toNumber(jsonAsset.AmtStat4);
		StatUpgrade4 = jsonAsset.StatUpgrade4;
		Power1R1 = ASCompat.toNumber(jsonAsset.Power1R1);
		Power1R2 = ASCompat.toNumber(jsonAsset.Power1R2);
		Power1R3 = ASCompat.toNumber(jsonAsset.Power1R3);
		Power1R4 = ASCompat.toNumber(jsonAsset.Power1R4);
		Power1R5 = ASCompat.toNumber(jsonAsset.Power1R5);
		Power1 = jsonAsset.Power1;
		Power2R1 = ASCompat.toNumber(jsonAsset.Power2R1);
		Power2R2 = ASCompat.toNumber(jsonAsset.Power2R2);
		Power2R3 = ASCompat.toNumber(jsonAsset.Power2R3);
		Power2R4 = ASCompat.toNumber(jsonAsset.Power2R4);
		Power2R5 = ASCompat.toNumber(jsonAsset.Power2R5);
		Power2 = jsonAsset.Power2;
		Power3R1 = ASCompat.toNumber(jsonAsset.Power3R1);
		Power3R2 = ASCompat.toNumber(jsonAsset.Power3R2);
		Power3R3 = ASCompat.toNumber(jsonAsset.Power3R3);
		Power3R4 = ASCompat.toNumber(jsonAsset.Power3R4);
		Power3R5 = ASCompat.toNumber(jsonAsset.Power3R5);
		Power3 = jsonAsset.Power3;
		Power4R1 = ASCompat.toNumber(jsonAsset.Power4R1);
		Power4R2 = ASCompat.toNumber(jsonAsset.Power4R2);
		Power4R3 = ASCompat.toNumber(jsonAsset.Power4R3);
		Power4R4 = ASCompat.toNumber(jsonAsset.Power4R4);
		Power4R5 = ASCompat.toNumber(jsonAsset.Power4R5);
		Power4 = jsonAsset.Power4;
		DBuster1 = jsonAsset.DBuster1;
		TeamAttack = jsonAsset.TeamAttack;
		Pet = jsonAsset.Pet;
		DefaultSkin = jsonAsset.DefaultSkin;
		CharNickname = jsonAsset.CharNickname;
		CharLikes = jsonAsset.CharLikes;
		CharDislikes = jsonAsset.CharDislikes;
		CharUnlockLocation = jsonAsset.CharUnlockLocation;
		CharDescription = jsonAsset.Description;
		StoreDescription = jsonAsset.StoreDescription;
		Coins = (ASCompat.toInt(jsonAsset.Coins) : UInt);
		Cash = (ASCompat.toInt(jsonAsset.Cash) : UInt);
		AttackRating = ASCompat.toNumber(jsonAsset.AttackRating);
		DefenseRating = ASCompat.toNumber(jsonAsset.DefenseRating);
		SpeedRating = ASCompat.toNumber(jsonAsset.SpeedRating);
		Ability = (0 : UInt);
		if (jsonAsset.Ability1 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability1) : UInt) : UInt);
		}
		if (jsonAsset.Ability2 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability2) : UInt) : UInt);
		}
		if (jsonAsset.Ability3 != null) {
			Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability3) : UInt) : UInt);
		}
		AllowedWeapons = new GMMap();
		if (jsonAsset.SWORD_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.SWORD_TYPE);
			AllowedWeapons.add("SWORD_TYPE", _loc3_);
		}
		if (jsonAsset.AXE_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.AXE_TYPE);
			AllowedWeapons.add("AXE_TYPE", _loc3_);
		}
		if (jsonAsset.HAMMER_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.HAMMER_TYPE);
			AllowedWeapons.add("HAMMER_TYPE", _loc3_);
		}
		if (jsonAsset.FLAIL_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FLAIL_TYPE);
			AllowedWeapons.add("FLAIL_TYPE", _loc3_);
		}
		if (jsonAsset.KATANA_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.KATANA_TYPE);
			AllowedWeapons.add("KATANA_TYPE", _loc3_);
		}
		if (jsonAsset.GREATSWORD_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.GREATSWORD_TYPE);
			AllowedWeapons.add("GREATSWORD_TYPE", _loc3_);
		}
		if (jsonAsset.SPEAR_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.SPEAR_TYPE);
			AllowedWeapons.add("SPEAR_TYPE", _loc3_);
		}
		if (jsonAsset.SHIELD_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.SHIELD_TYPE);
			AllowedWeapons.add("SHIELD_TYPE", _loc3_);
		}
		if (jsonAsset.FARMTOOL_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FARMTOOL_TYPE);
			AllowedWeapons.add("FARMTOOL_TYPE", _loc3_);
		}
		if (jsonAsset.MEATCLEAVER_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.MEATCLEAVER_TYPE);
			AllowedWeapons.add("MEATCLEAVER_TYPE", _loc3_);
		}
		if (jsonAsset.FRYING_PAN_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FRYING_PAN_TYPE);
			AllowedWeapons.add("FRYING_PAN_TYPE", _loc3_);
		}
		if (jsonAsset.COOKING_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.COOKING_TYPE);
			AllowedWeapons.add("COOKING_TYPE", _loc3_);
		}
		if (jsonAsset.BOW_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.BOW_TYPE);
			AllowedWeapons.add("BOW_TYPE", _loc3_);
		}
		if (jsonAsset.CROSSBOW_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.CROSSBOW_TYPE);
			AllowedWeapons.add("CROSSBOW_TYPE", _loc3_);
		}
		if (jsonAsset.PISTOL_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.PISTOL_TYPE);
			AllowedWeapons.add("PISTOL_TYPE", _loc3_);
		}
		if (jsonAsset.TRAP_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.TRAP_TYPE);
			AllowedWeapons.add("TRAP_TYPE", _loc3_);
		}
		if (jsonAsset.SEED_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.SEED_TYPE);
			AllowedWeapons.add("SEED_TYPE", _loc3_);
		}
		if (jsonAsset.LIGHTNING_STAFF_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHTNING_STAFF_TYPE);
			AllowedWeapons.add("LIGHTNING_STAFF_TYPE", _loc3_);
		}
		if (jsonAsset.FIRE_STAFF_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_STAFF_TYPE);
			AllowedWeapons.add("FIRE_STAFF_TYPE", _loc3_);
		}
		if (jsonAsset.FIRE_MAGIC_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_MAGIC_TYPE);
			AllowedWeapons.add("FIRE_MAGIC_TYPE", _loc3_);
		}
		if (jsonAsset.LIGHTNING_MAGIC_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHTNING_MAGIC_TYPE);
			AllowedWeapons.add("LIGHTNING_MAGIC_TYPE", _loc3_);
		}
		if (jsonAsset.THROWING_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.THROWING_TYPE);
			AllowedWeapons.add("THROWING_TYPE", _loc3_);
		}
		if (jsonAsset.SCROLL_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.SCROLL_TYPE);
			AllowedWeapons.add("SCROLL_TYPE", _loc3_);
		}
		if (jsonAsset.FLAME_STAFF_TYPE != null) {
			_loc3_ = ASCompat.toBool(jsonAsset.FLAME_STAFF_TYPE);
			AllowedWeapons.add("FLAME_STAFF_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.LIGHT_THROWING_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHT_THROWING_TYPE);
			AllowedWeapons.add("LIGHT_THROWING_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.HEAVY_THROWING_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_THROWING_TYPE);
			AllowedWeapons.add("HEAVY_THROWING_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.THROWING_WEAPON_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.THROWING_WEAPON_TYPE);
			AllowedWeapons.add("THROWING_WEAPON_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.VINTAGE_SCROLL_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.VINTAGE_SCROLL_TYPE);
			AllowedWeapons.add("VINTAGE_SCROLL_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.FIRE_ORB_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_ORB_TYPE);
			AllowedWeapons.add("FIRE_ORB_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.FIRE_RUNE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_RUNE_TYPE);
			AllowedWeapons.add("FIRE_RUNE_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.FIRE_GLOVE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_GLOVE_TYPE);
			AllowedWeapons.add("FIRE_GLOVE_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.LIGHT_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHT_SPEAR_TYPE);
			AllowedWeapons.add("LIGHT_SPEAR_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.HEAVY_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_SPEAR_TYPE);
			AllowedWeapons.add("HEAVY_SPEAR_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.THROWING_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.THROWING_SPEAR_TYPE);
			AllowedWeapons.add("THROWING_SPEAR_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.DRAGON_CHARM_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.DRAGON_CHARM_TYPE);
			AllowedWeapons.add("DRAGON_CHARM_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.DRAGON_BOOTS_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.DRAGON_BOOTS_TYPE);
			AllowedWeapons.add("DRAGON_BOOTS_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.GUN_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.GUN_TYPE);
			AllowedWeapons.add("GUN_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.HEAVY_WEAPONS_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_WEAPONS_TYPE);
			AllowedWeapons.add("HEAVY_WEAPONS_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.TURRET_GADGET_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.TURRET_GADGET_TYPE);
			AllowedWeapons.add("TURRET_GADGET_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.LUCHADOR_GLOVE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_GLOVE_TYPE);
			AllowedWeapons.add("LUCHADOR_GLOVE_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.LUCHADOR_BOOT_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_BOOT_TYPE);
			AllowedWeapons.add("LUCHADOR_BOOT_TYPE", _loc3_);
		}
		if (As3Compat.truthy(jsonAsset.LUCHADOR_CHAIR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_CHAIR_TYPE);
			AllowedWeapons.add("LUCHADOR_CHAIR_TYPE", _loc3_);
		}
		UISwfFilepath = jsonAsset.UISwfFilepath;
		PortraitClassName = jsonAsset.PortraitClassName;
		IsMover = true;
	}

	public static function maxLevelForAscension(ascensionLevel:UInt):UInt {
		var _loc2_ = ascensionLevel < GMHero.MAX_EFFECTIVE_ASCENSIONS ? ascensionLevel : GMHero.MAX_EFFECTIVE_ASCENSIONS;
		return (GMHero.BASE_MAX_LEVEL + _loc2_ * GMHero.LEVELS_PER_ASCENSION:UInt);
	}

	public function getTotalStatFromIndex(index:UInt):UInt {
		if (index < (ExperienceToLevel.length:UInt)) {
			return ExperienceToLevel[(index : Int)].mTotalStatPoints;
		}
		return ExperienceToLevel[ExperienceToLevel.length - 1].mTotalStatPoints;
	}

	public function getTotalStatFromExp(val:UInt, ascensionLevel:UInt):UInt {
		var _loc3_ = getLevelIndex(val, (ascensionLevel : Int));
		if (_loc3_ < ExperienceToLevel.length) {
			return ExperienceToLevel[_loc3_].mTotalStatPoints;
		}
		return ExperienceToLevel[ExperienceToLevel.length - 1].mTotalStatPoints;
	}

	public function getLevelIndex(val:Float, ascensionLevel:Int):Int {
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_ = (0 : UInt);
		var _loc11_ = (0 : UInt);
		var _loc12_ = (0 : UInt);
		var _loc3_:Int = GMHero.maxLevelForAscension((ascensionLevel : UInt));
		var _loc4_ = 0;
		var _loc5_ = _loc3_;
		var _loc6_ = ExperienceToLevel.length;
		var _loc7_ = _loc5_ - _loc4_;
		while (0 < _loc7_) {
			_loc8_ = ASCompat.floatToInt(_loc7_ / 2);
			_loc9_ = _loc4_ + _loc8_;
			if (_loc9_ >= _loc6_) {
				_loc10_ = ExperienceToLevel[_loc6_ - 1].mExperience;
				_loc11_ = _loc10_ - ExperienceToLevel[_loc6_ - 2].mExperience;
				_loc12_ = _loc10_ + _loc11_ * (_loc9_ + 1 - _loc6_);
				if (_loc12_ < val) {
					_loc4_ = ASCompat.floatToInt(++_loc9_);
					_loc7_ -= _loc8_ + 1;
				} else {
					_loc7_ = _loc8_;
				}
			} else if (ExperienceToLevel[_loc9_].mExperience < val) {
				_loc4_ = ASCompat.floatToInt(++_loc9_);
				_loc7_ -= _loc8_ + 1;
			} else {
				_loc7_ = _loc8_;
			}
		}
		if (_loc4_ >= _loc3_) {
			return _loc3_ - 1;
		}
		return _loc4_;
	}

	public function getLevelFromIndex(index:UInt):UInt {
		if (index < (ExperienceToLevel.length:UInt)) {
			return ExperienceToLevel[(index : Int)].mLevel;
		}
		return index;
	}

	public function getLevelFromExp(val:UInt, ascensionLevel:UInt):UInt {
		var _loc3_ = getLevelIndex(val, (ascensionLevel : Int));
		if (_loc3_ < ExperienceToLevel.length) {
			return ExperienceToLevel[_loc3_].mLevel;
		}
		return (_loc3_ + 1 : UInt);
	}

	public function getExpFromIndex(index:UInt):UInt {
		var _loc2_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		if (index < (ExperienceToLevel.length:UInt)) {
			return (ExperienceToLevel[(index : Int)].mExperience + 1:UInt);
		}
		_loc2_ = ExperienceToLevel[ExperienceToLevel.length - 1].mExperience;
		_loc3_ = _loc2_ - ExperienceToLevel[ExperienceToLevel.length - 2].mExperience;
		_loc4_ = _loc2_ + _loc3_ * (index + 1 - ExperienceToLevel.length);
		return (_loc4_ + 1 : UInt);
	}

	public function getBaseLevelFromExp(val:UInt):UInt {
		return getLevelFromExp(val, (0 : UInt));
	}

	public function getAllowedWeaponSubTypes():Vector<String> {
		var _loc3_:ASAny = ASCompat.asString(null);
		var _loc1_ = new Vector<String>();
		var _loc2_ = AllowedWeapons.iterator();
		while (As3Compat.truthy(_loc2_.next())) {
			_loc3_ = _loc2_.get_key();
			if (As3Compat.truthy(AllowedWeapons.itemFor(_loc3_))) {
				_loc1_.push(_loc3_);
			}
		}
		return _loc1_;
	}

	public function LoadingOnly_addExpRecord(level:UInt, exp:UInt, statPoints:UInt) {
		ExperienceToLevel.push(new ExpToLevel(level, exp, statPoints));
	}

	public function LoadingOnly_addAscensionExpRecord(ascensionLevel:UInt, ascensionExp:UInt, ascensionStatPoints:UInt) {
		ExperienceToLevel.push(new ExpToLevel(ascensionLevel, ascensionExp, ascensionStatPoints));
	}

	public function HeroSlotHelper(statname:String, pos:Int, value:Float, gm:GameMaster) {
		var _loc6_ = ASCompat.asVector(null, (_ : Float));
		var _loc7_:ASAny = ASCompat.dynamicAs(null, GMSuperStat);
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_ = 0;
		if (value == 0) {
			return;
		}
		var _loc5_ = DBGlobal.NameToSlotOffset(statname);
		if (_loc5_ >= 0) {
			UpgradeToSlotOffset[pos].push(_loc5_);
			_loc6_ = Normalized_upgrades.values;
			_loc6_[_loc5_] = _loc6_[_loc5_] + value;
		} else {
			_loc7_ = gm.superStatByConstant.itemFor(statname);
			if (_loc7_ != null) {
				_loc8_ = 0;
				_loc9_ = StatVector.slotCount;
				while (_loc8_ < _loc9_) {
					_loc10_ = _loc8_++;
					if (ASCompat.toNumber(_loc7_.BaseValues.values[_loc10_]) != 0) {
						UpgradeToSlotOffset[pos].push(_loc10_);
						_loc6_ = Normalized_upgrades.values;
						_loc6_[_loc10_] = _loc6_[_loc10_] + _loc7_.BaseValues.values[_loc10_];
					}
				}
			} else {
				Logger.error("Can not find Definition for Stat: " + statname);
			}
		}
	}
}
