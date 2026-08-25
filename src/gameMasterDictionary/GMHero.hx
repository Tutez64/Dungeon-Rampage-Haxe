package gameMasterDictionary;

import brain.logger.Logger;
import dBGlobals.DBGlobal;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class GMHero extends GMActor {
	public var IsExclusive:Bool = false;

	public var Hidden:Bool = false;

	public var AmtStat1:Float = Math.NaN;

	public var StatUpgrade1:String;

	public var AmtStat2:Float = Math.NaN;

	public var StatUpgrade2:String;

	public var AmtStat3:Float = Math.NaN;

	public var StatUpgrade3:String;

	public var AmtStat4:Float = Math.NaN;

	public var StatUpgrade4:String;

	public var Power1R1:Float = Math.NaN;

	public var Power1R2:Float = Math.NaN;

	public var Power1R3:Float = Math.NaN;

	public var Power1R4:Float = Math.NaN;

	public var Power1R5:Float = Math.NaN;

	public var Power1:String;

	public var Power2R1:Float = Math.NaN;

	public var Power2R2:Float = Math.NaN;

	public var Power2R3:Float = Math.NaN;

	public var Power2R4:Float = Math.NaN;

	public var Power2R5:Float = Math.NaN;

	public var Power2:String;

	public var Power3R1:Float = Math.NaN;

	public var Power3R2:Float = Math.NaN;

	public var Power3R3:Float = Math.NaN;

	public var Power3R4:Float = Math.NaN;

	public var Power3R5:Float = Math.NaN;

	public var Power3:String;

	public var Power4R1:Float = Math.NaN;

	public var Power4R2:Float = Math.NaN;

	public var Power4R3:Float = Math.NaN;

	public var Power4R4:Float = Math.NaN;

	public var Power4R5:Float = Math.NaN;

	public var Power4:String;

	public var DBuster1:String;

	public var TeamAttack:String;

	public var Pet:String;

	public var AllowedWeapons:Map;

	public var UISwfFilepath:String;

	public var FeedPostPicture:String;

	public var CharNickname:String;

	public var CharLikes:String;

	public var CharDislikes:String;

	public var CharUnlockLocation:String;

	public var CharDescription:String;

	public var StoreDescription:String;

	public var Coins:UInt = 0;

	public var Cash:UInt = 0;

	public var SpeedRating:Float = Math.NaN;

	public var AttackRating:Float = Math.NaN;

	public var DefenseRating:Float = Math.NaN;

	public var DefaultSkin:String;

	var ExperienceToLevel:Vector<ExpToLevel>;

	public var UpgradeToSlotOffset:Vector<Vector<Int>> = new Vector((4 : UInt), true);

	public var Normalized_upgrades:StatVector;

	public function new(jsonAsset:ASObject, splitTests:ASObject) {
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
		AmtStat1 = ASCompat.toNumberField(jsonAsset, "AmtStat1");
		StatUpgrade1 = jsonAsset.StatUpgrade1;
		AmtStat2 = ASCompat.toNumberField(jsonAsset, "AmtStat2");
		StatUpgrade2 = jsonAsset.StatUpgrade2;
		AmtStat3 = ASCompat.toNumberField(jsonAsset, "AmtStat3");
		StatUpgrade3 = jsonAsset.StatUpgrade3;
		AmtStat4 = ASCompat.toNumberField(jsonAsset, "AmtStat4");
		StatUpgrade4 = jsonAsset.StatUpgrade4;
		Power1R1 = ASCompat.toNumberField(jsonAsset, "Power1R1");
		Power1R2 = ASCompat.toNumberField(jsonAsset, "Power1R2");
		Power1R3 = ASCompat.toNumberField(jsonAsset, "Power1R3");
		Power1R4 = ASCompat.toNumberField(jsonAsset, "Power1R4");
		Power1R5 = ASCompat.toNumberField(jsonAsset, "Power1R5");
		Power1 = jsonAsset.Power1;
		Power2R1 = ASCompat.toNumberField(jsonAsset, "Power2R1");
		Power2R2 = ASCompat.toNumberField(jsonAsset, "Power2R2");
		Power2R3 = ASCompat.toNumberField(jsonAsset, "Power2R3");
		Power2R4 = ASCompat.toNumberField(jsonAsset, "Power2R4");
		Power2R5 = ASCompat.toNumberField(jsonAsset, "Power2R5");
		Power2 = jsonAsset.Power2;
		Power3R1 = ASCompat.toNumberField(jsonAsset, "Power3R1");
		Power3R2 = ASCompat.toNumberField(jsonAsset, "Power3R2");
		Power3R3 = ASCompat.toNumberField(jsonAsset, "Power3R3");
		Power3R4 = ASCompat.toNumberField(jsonAsset, "Power3R4");
		Power3R5 = ASCompat.toNumberField(jsonAsset, "Power3R5");
		Power3 = jsonAsset.Power3;
		Power4R1 = ASCompat.toNumberField(jsonAsset, "Power4R1");
		Power4R2 = ASCompat.toNumberField(jsonAsset, "Power4R2");
		Power4R3 = ASCompat.toNumberField(jsonAsset, "Power4R3");
		Power4R4 = ASCompat.toNumberField(jsonAsset, "Power4R4");
		Power4R5 = ASCompat.toNumberField(jsonAsset, "Power4R5");
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
		AttackRating = ASCompat.toNumberField(jsonAsset, "AttackRating");
		DefenseRating = ASCompat.toNumberField(jsonAsset, "DefenseRating");
		SpeedRating = ASCompat.toNumberField(jsonAsset, "SpeedRating");
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
		AllowedWeapons = new Map();
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
		if (ASCompat.toBool(jsonAsset.LIGHT_THROWING_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHT_THROWING_TYPE);
			AllowedWeapons.add("LIGHT_THROWING_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.HEAVY_THROWING_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_THROWING_TYPE);
			AllowedWeapons.add("HEAVY_THROWING_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.THROWING_WEAPON_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.THROWING_WEAPON_TYPE);
			AllowedWeapons.add("THROWING_WEAPON_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.VINTAGE_SCROLL_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.VINTAGE_SCROLL_TYPE);
			AllowedWeapons.add("VINTAGE_SCROLL_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.FIRE_ORB_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_ORB_TYPE);
			AllowedWeapons.add("FIRE_ORB_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.FIRE_RUNE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_RUNE_TYPE);
			AllowedWeapons.add("FIRE_RUNE_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.FIRE_GLOVE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.FIRE_GLOVE_TYPE);
			AllowedWeapons.add("FIRE_GLOVE_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.LIGHT_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LIGHT_SPEAR_TYPE);
			AllowedWeapons.add("LIGHT_SPEAR_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.HEAVY_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_SPEAR_TYPE);
			AllowedWeapons.add("HEAVY_SPEAR_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.THROWING_SPEAR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.THROWING_SPEAR_TYPE);
			AllowedWeapons.add("THROWING_SPEAR_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.DRAGON_CHARM_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.DRAGON_CHARM_TYPE);
			AllowedWeapons.add("DRAGON_CHARM_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.DRAGON_BOOTS_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.DRAGON_BOOTS_TYPE);
			AllowedWeapons.add("DRAGON_BOOTS_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.GUN_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.GUN_TYPE);
			AllowedWeapons.add("GUN_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.HEAVY_WEAPONS_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.HEAVY_WEAPONS_TYPE);
			AllowedWeapons.add("HEAVY_WEAPONS_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.TURRET_GADGET_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.TURRET_GADGET_TYPE);
			AllowedWeapons.add("TURRET_GADGET_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.LUCHADOR_GLOVE_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_GLOVE_TYPE);
			AllowedWeapons.add("LUCHADOR_GLOVE_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.LUCHADOR_BOOT_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_BOOT_TYPE);
			AllowedWeapons.add("LUCHADOR_BOOT_TYPE", _loc3_);
		}
		if (ASCompat.toBool(jsonAsset.LUCHADOR_CHAIR_TYPE)) {
			_loc3_ = ASCompat.toBool(jsonAsset.LUCHADOR_CHAIR_TYPE);
			AllowedWeapons.add("LUCHADOR_CHAIR_TYPE", _loc3_);
		}
		UISwfFilepath = jsonAsset.UISwfFilepath;
		FeedPostPicture = jsonAsset.FeedPostPicture;
		IsMover = true;
	}

	public function getAllowedWeaponSubTypes():Vector<String> {
		var _loc3_:String = null;
		var _loc2_ = new Vector<String>();
		var _loc1_ = ASCompat.reinterpretAs(AllowedWeapons.iterator(), IMapIterator);
		while (ASCompat.toBool(_loc1_.next())) {
			_loc3_ = ASCompat.asString(_loc1_.key);
			if (ASCompat.asBool(AllowedWeapons.itemFor(_loc3_))) {
				_loc2_.push(_loc3_);
			}
		}
		return _loc2_;
	}

	public function HeroSlotHelper(statname:String, pos:Int, value:Float, gm:GameMaster) {
		var _loc6_:GMSuperStat = null;
		var _loc7_ = 0;
		if (value == 0) {
			return;
		}
		var _loc5_ = DBGlobal.NameToSlotOffset(statname);
		if (_loc5_ >= 0) {
			UpgradeToSlotOffset[pos].push(_loc5_);
			Normalized_upgrades.values[_loc5_] += value;
		} else {
			_loc6_ = ASCompat.dynamicAs(gm.superStatByConstant.itemFor(statname), gameMasterDictionary.GMSuperStat);
			if (_loc6_ != null) {
				_loc7_ = 0;
				while ((_loc7_ : UInt) < StatVector.slotCount) {
					if (_loc6_.BaseValues.values[_loc7_] != 0) {
						UpgradeToSlotOffset[pos].push(_loc7_);
						Normalized_upgrades.values[_loc7_] += _loc6_.BaseValues.values[_loc7_];
					}
					_loc7_++;
				}
			} else {
				Logger.error("Can not find Definition for Stat: " + statname);
			}
		}
	}

	public function LoadingOnly_addExpRecord(level:UInt, exp:UInt, statPoints:UInt) {
		ExperienceToLevel.push(new ExpToLevel(level, exp, statPoints));
	}

	public function getLevelIndex(val:Float):Int {
		var _loc3_ = 0;
		var _loc5_ = 0;
		var _loc4_ = ExperienceToLevel.length;
		var _loc6_ = 0;
		var _loc2_ = _loc4_;
		var _loc7_ = _loc2_ - _loc6_;
		while (0 < _loc7_) {
			_loc3_ = Std.int(_loc7_ / 2);
			_loc5_ = _loc6_ + _loc3_;
			if (ExperienceToLevel[_loc5_].mExperience < val) {
				_loc6_ = ++_loc5_;
				_loc7_ -= _loc3_ + 1;
			} else {
				_loc7_ = _loc3_;
			}
		}
		if (_loc6_ >= _loc4_) {
			return _loc4_ - 1;
		}
		return _loc6_;
	}

	public function getLevelFromExp(val:UInt):UInt {
		return ExperienceToLevel[getLevelIndex(val)].mLevel;
	}

	public function getTotalStatFromExp(val:UInt):UInt {
		return ExperienceToLevel[getLevelIndex(val)].mTotalStatPoints;
	}

	public function getLevelFromIndex(index:UInt):UInt {
		return ExperienceToLevel[(index : Int)].mLevel;
	}

	public function getExpFromIndex(index:UInt):UInt {
		return ExperienceToLevel[(index : Int)].mExperience + 1;
	}

	public function getTotalStatFromIndex(index:UInt):UInt {
		return ExperienceToLevel[(index : Int)].mTotalStatPoints;
	}
}

private class ExpToLevel {
	public var mLevel:UInt = 0;

	public var mExperience:UInt = 0;

	public var mTotalStatPoints:UInt = 0;

	public function new(level:UInt, experience:UInt, totalStatPoints:UInt) {
		mLevel = level;
		mExperience = experience;
		mTotalStatPoints = totalStatPoints;
	}
}
