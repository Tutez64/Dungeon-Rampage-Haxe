package dBGlobals;

import brain.logger.Logger;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.GlowFilter;
import haxe.Log;

class DBGlobal {
	public static var TUTORIAL_MAP_NODE_ID:UInt = (50002 : UInt);

	public static var MUSIC_VOLUME:Float = 0.5;

	public static var SFX_VOLUME:Float = 0.5;

	public static var RESSURECTION_POTION_STACK_ID:UInt = (60001 : UInt);

	public static var RESSURECTION_POTION_OFFER_ID:UInt = (51304 : UInt);

	public static var PARTYBOMB_POTION_STACK_ID:UInt = (60018 : UInt);

	public static var PARTYBOMB_POTION_OFFER_ID:UInt = (51369 : UInt);

	public static var CONSUMABLE_WEAPON_ID:UInt = (40000 : UInt);

	public static var SFX_PATH:String = "Resources/Audio/soundEffects.swf";

	public static var DEFAULT_ICON_NATIVE_SIZE:Float = 100;

	public static var WEAPON_ICON_NATIVE_SIZE:Float = 100;

	public static var CHEST_ICON_NATIVE_SIZE:Float = 120;

	public static var CHARGE_ICON_NATIVE_SIZE:Float = 60;

	public static var HERO_ICON_NATIVE_SIZE:Float = 72;

	public static var PET_ICON_NATIVE_SIZE:Float = 68;

	public static var BERSERKER_TYPE_ID:UInt = (101 : UInt);

	public static var RANGER_TYPE_ID:UInt = (102 : UInt);

	public static var SORCERER_TYPE_ID:UInt = (103 : UInt);

	public static var BATTLE_CHEF_TYPE_ID:UInt = (104 : UInt);

	public static var VAMPIRE_HUNTER_TYPE_ID:UInt = (105 : UInt);

	public static var GHOST_SAMURAI_TYPE_ID:UInt = (106 : UInt);

	public static var MELEE_ITEM_CATEGORY:String = "MELEE";

	public static var SHOOTING_ITEM_CATEGORY:String = "SHOOTING";

	public static var MAGIC_ITEM_CATEGORY:String = "MAGIC";

	public static var HP_BOOST:Int = 0;

	public static var MP_BOOST:Int = 1;

	public static var MELEE_ATK:Int = 2;

	public static var SHOOT_ATK:Int = 3;

	public static var MAGIC_ATK:Int = 4;

	public static var MELEE_DEF:Int = 5;

	public static var SHOOT_DEF:Int = 6;

	public static var MAGIC_DEF:Int = 7;

	public static var MELEE_SPD:Int = 8;

	public static var SHOOT_SPD:Int = 9;

	public static var MAGIC_SPD:Int = 10;

	public static var HP_REGEN:Int = 11;

	public static var MP_REGEN:Int = 12;

	public static var MOVEMENT:Int = 13;

	public static var LV_HP_BOOST:Int = 0;

	public static var LV_MP_BOOST:Int = 1;

	public static var LV_MELEE_ATK:Int = 2;

	public static var LV_SHOOT_ATK:Int = 3;

	public static var LV_MAGIC_ATK:Int = 4;

	public static var LV_MELEE_DEF:Int = 5;

	public static var LV_SHOOT_DEF:Int = 6;

	public static var LV_MAGIC_DEF:Int = 7;

	public static var LV_MELEE_SPD:Int = 8;

	public static var LV_SHOOT_SPD:Int = 9;

	public static var LV_MAGIC_SPD:Int = 10;

	public static var LV_HP_REGEN:Int = 11;

	public static var LV_MP_REGEN:Int = 12;

	public static var LV_MOVEMENT:Int = 13;

	public static var ATTTACK_TYPE_MELEE:Int = 0;

	public static var ATTTACK_TYPE_RANGE:Int = 1;

	public static var ATTTACK_TYPE_MAGIC:Int = 2;

	public static var B2D_ENVIRONMENT_MASK:UInt = (1 : UInt);

	public static var B2D_COMBAT_MASK:UInt = (2 : UInt);

	public static var TEAM_ENVIRONMENT:UInt = (1 : UInt);

	public static var TEAM_1:UInt = (5 : UInt);

	public static var TEAM_2:UInt = (6 : UInt);

	public static var TEAM_3:UInt = (7 : UInt);

	public static var ABILITY_SUFFER_IMMUNITY:UInt = (1 : UInt);

	public static var ABILITY_INVULNERABLE_MELEE:UInt = (2 : UInt);

	public static var ABILITY_INVULNERABLE_MAGIC:UInt = (4 : UInt);

	public static var ABILITY_INVULNERABLE_SHOOT:UInt = (8 : UInt);

	public static var ABILITY_BERSERK_MODE:UInt = (16 : UInt);

	public static var ABILITY_PARALYZED:UInt = (32 : UInt);

	public static var ABILITY_BREAK_FREE:UInt = (64 : UInt);

	public static var ABILITY_PANIC:UInt = (128 : UInt);

	public static var ABILITY_PARALYZE_IMMUNITY:UInt = (256 : UInt);

	public static var ABILITY_DISABLE_CONTROLS:UInt = (512 : UInt);

	public static var ABILITY_PIERCE_IMMUNE:UInt = (16777216 : UInt);

	public static var BERSERKER_RAMPAGE:String = "RAMPAGE";

	public static var UI_16_TO_9_PORT_OBJECT_SCALE:Float = 1.8;

	public static var FILTER_QUALITY_LOW:UInt = (0 : UInt);

	public static var FILTER_QUALITY_MEDIUM:UInt = (1 : UInt);

	public static var FILTER_QUALITY_HIGH:UInt = (2 : UInt);

	public static var StatNames:Vector<String> = Vector.ofArray([
		"HP_BOOST",
		"MP_BOOST",
		"MELEE_ATK",
		"SHOOT_ATK",
		"MAGIC_ATK",
		"MELEE_DEF",
		"SHOOT_DEF",
		"MAGIC_DEF",
		"MELEE_SPD",
		"SHOOT_SPD",
		"MAGIC_SPD",
		"HP_REGEN",
		"MP_REGEN",
		"MOVEMENT"
	]);

	public static var ABILITY_INVULNERABLE_ALL:UInt = ((DBGlobal.ABILITY_INVULNERABLE_MELEE : Int) | (DBGlobal.ABILITY_INVULNERABLE_MAGIC : Int) | (DBGlobal.ABILITY_INVULNERABLE_SHOOT : Int) : UInt);

	public static var UI_ROLLOVER_FILTER:GlowFilter = new GlowFilter((16633879 : UInt), 1, 8, 8, 5);

	public static var UI_SELECTED_FILTER:GlowFilter = new GlowFilter((16777215 : UInt), 1, 6, 6, 12);

	public static var UI_DISABLED_FILTER:GlowFilter = new GlowFilter((16711680 : UInt), 0.1, 5, 5, 2.6);

	public function new() {}

	public static function NameToSlotOffset(name:String):Int {
		var _loc4_ = 0;
		var _loc2_ = 0;
		var _loc3_ = DBGlobal.StatNames.length;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			if (DBGlobal.StatNames[_loc4_] == name) {
				return _loc4_;
			}
		}
		return -1;
	}

	public static function b2dMaskForAllTeamsBut(team:UInt):UInt {
		if (team == DBGlobal.TEAM_1) {
			return ((DBGlobal.B2D_ENVIRONMENT_MASK : Int) | 1 << (DBGlobal.TEAM_2 : Int) | 1 << (DBGlobal.TEAM_3 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_2) {
			return ((DBGlobal.B2D_ENVIRONMENT_MASK : Int) | 1 << (DBGlobal.TEAM_1 : Int) | 1 << (DBGlobal.TEAM_3 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_3) {
			return ((DBGlobal.B2D_ENVIRONMENT_MASK : Int) | 1 << (DBGlobal.TEAM_1 : Int) | 1 << (DBGlobal.TEAM_2 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_ENVIRONMENT) {
			return (1 << (DBGlobal.TEAM_1 : Int) | 1 << (DBGlobal.TEAM_2 : Int) : UInt);
		}
		Logger.error("Unable to determine box2D team mask for team: " + ("" + team) + " in function: b2dMaskForAllTeamsBut");
		return (0 : UInt);
	}

	public static function b2dMaskForTeam(team:UInt):UInt {
		if (team == DBGlobal.TEAM_1) {
			return (1 << (DBGlobal.TEAM_1 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_2) {
			return (1 << (DBGlobal.TEAM_2 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_3) {
			return (1 << (DBGlobal.TEAM_3 : Int) : UInt);
		}
		if (team == DBGlobal.TEAM_ENVIRONMENT) {
			return DBGlobal.B2D_ENVIRONMENT_MASK;
		}
		Logger.error("Unable to determine box2D team mask for team: " + ("" + team) + " in function: b2dMaskForTeam");
		return (0 : UInt);
	}

	public static function mapAbilityMask(ability:String):UInt {
		if (ability == "SUFFER_IMMUNE") {
			return DBGlobal.ABILITY_SUFFER_IMMUNITY;
		}
		if (ability == "INVULNERABLE_MELEE") {
			return DBGlobal.ABILITY_INVULNERABLE_MELEE;
		}
		if (ability == "INVULNERABLE_MAGIC") {
			return DBGlobal.ABILITY_INVULNERABLE_MAGIC;
		}
		if (ability == "INVULNERABLE_SHOOT") {
			return DBGlobal.ABILITY_INVULNERABLE_SHOOT;
		}
		if (ability == "INVULNERABLE_ALL") {
			return DBGlobal.ABILITY_INVULNERABLE_ALL;
		}
		if (ability == "BERSERK_MODE") {
			return DBGlobal.ABILITY_BERSERK_MODE;
		}
		if (ability == "PARALYZED") {
			return DBGlobal.ABILITY_PARALYZED;
		}
		if (ability == "DISABLE_CONTROLS") {
			return DBGlobal.ABILITY_DISABLE_CONTROLS;
		}
		if (ability == "BREAK_FREE") {
			return DBGlobal.ABILITY_BREAK_FREE;
		}
		if (ability == "PANIC") {
			return DBGlobal.ABILITY_PANIC;
		}
		if (ability == "PARALYZE_IMMUNITY") {
			return DBGlobal.ABILITY_PARALYZE_IMMUNITY;
		}
		if (ability == "PIERCE_IMMUNE") {
			return DBGlobal.ABILITY_PIERCE_IMMUNE;
		}
		return (0 : UInt);
	}

	public static function traceClipChildren(clipToTrace:MovieClip) {
		var _loc4_ = 0;
		var _loc5_ = ASCompat.dynamicAs(null, DisplayObject);
		Log.trace("+ number of DisplayObject: " + clipToTrace.numChildren + "  --------------------------------", {
			"fileName": "../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
			"lineNumber": 202,
			"className": "dbglobals.DBGlobal",
			"methodName": "traceClipChildren"
		});
		var _loc2_ = 0;
		var _loc3_ = clipToTrace.numChildren;
		while (_loc2_ < _loc3_) {
			_loc4_ = _loc2_++;
			_loc5_ = clipToTrace.getChildAt(_loc4_);
			Log.trace("\t|\t " + _loc4_ + ".\t name:" + Std.string(_loc5_.name) + "\t type:" + Type.getClassName(Type.getClass(_loc5_)) + "\t"
				+ Std.string(_loc5_),
				{
					"fileName": "../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
					"lineNumber": 205,
					"className": "dbglobals.DBGlobal",
					"methodName": "traceClipChildren"
				});
		}
		Log.trace("\t+ --------------------------------------------------------------------------------------", {
			"fileName": "../DungeonBusters/Client/GameMasterProjectHaxe/src/dbglobals/DBGlobal.hx",
			"lineNumber": 207,
			"className": "dbglobals.DBGlobal",
			"methodName": "traceClipChildren"
		});
	}

	public static function highlightButton(button:ASAny, quality:UInt = (1 : UInt)) {
		var _loc3_ = DBGlobal.UI_ROLLOVER_FILTER;
		if (quality == DBGlobal.FILTER_QUALITY_LOW) {
			_loc3_.quality = 1;
		} else if (quality == DBGlobal.FILTER_QUALITY_MEDIUM) {
			_loc3_.quality = 2;
		} else if (quality == DBGlobal.FILTER_QUALITY_HIGH) {
			_loc3_.quality = 3;
		} else {
			Logger.warn("No such quality exists..");
		}
		if (Std.isOfType(button, MovieClip)) {
			ASCompat.setProperty(button, "filters", [_loc3_]);
		} else {
			ASCompat.setProperty(button.root, "filters", [_loc3_]);
		}
	}

	public static function unHighlightButton(button:ASAny) {
		if (button == null) {
			Logger.warn("Cannot unhilight null button/movieclip");
		}
		if (Std.isOfType(button, MovieClip)) {
			ASCompat.setProperty(button, "filters", []);
		} else {
			ASCompat.setProperty(button.root, "filters", null);
		}
	}

	public static function endsWith(input:String, suffix:String):Bool {
		return suffix == input.substring(input.length - suffix.length);
	}
}
