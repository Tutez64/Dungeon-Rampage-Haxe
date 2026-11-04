package input.keyBindings;

class InputAction {
	public static inline final MOVE_UP = "moveUp";

	public static inline final MOVE_DOWN = "moveDown";

	public static inline final MOVE_LEFT = "moveLeft";

	public static inline final MOVE_RIGHT = "moveRight";

	public static inline final ATTACK_WEAPON_1 = "attackWeapon1";

	public static inline final ATTACK_WEAPON_2 = "attackWeapon2";

	public static inline final ATTACK_WEAPON_3 = "attackWeapon3";

	public static inline final USE_DUNGEON_BUSTER = "useDungeonBuster";

	public static inline final USE_CONSUMABLE_1 = "useConsumable1";

	public static inline final USE_CONSUMABLE_2 = "useConsumable2";

	public static inline final HOLD_IN_PLACE = "holdInPlace";

	public static inline final REVIVE_ALLY = "reviveAlly";

	public static inline final TOGGLE_CHAT_LOG = "toggleChatLog";

	public static inline final OPEN_OPTIONS_MENU = "openOptionsMenu";

	public static final ORDERED:Vector<String> = Vector.ofArray([
		"moveUp",
		"moveDown",
		"moveLeft",
		"moveRight",
		"attackWeapon1",
		"attackWeapon2",
		"attackWeapon3",
		"useDungeonBuster",
		"useConsumable1",
		"useConsumable2",
		"holdInPlace",
		"reviveAlly",
		"toggleChatLog",
		"openOptionsMenu"
	]);

	public static final ATTACK_SLOTS:Vector<String> = Vector.ofArray(["attackWeapon1", "attackWeapon2", "attackWeapon3", "useDungeonBuster"]);

	public static final CONSUMABLE_SLOTS:Vector<String> = Vector.ofArray(["useConsumable1", "useConsumable2"]);

	static final DEFAULTS:ASObject = buildDefaults();

	static final LEGACY_ALIASES:ASObject = buildLegacyAliases();

	public function new() {}

	public static function isKnown(action:String):Bool {
		return action != null && DEFAULTS.hasOwnProperty(action);
	}

	public static function defaultPrimary(action:String):Int {
		return isKnown(action) ? ASCompat.toInt(ASCompat.dynGetIndex(DEFAULTS[action], 0)) : 0;
	}

	public static function defaultAlternate(action:String):Int {
		return isKnown(action) ? ASCompat.toInt(ASCompat.dynGetIndex(DEFAULTS[action], 1)) : 0;
	}

	public static function legacyAlias(action:String):Int {
		return action != null && LEGACY_ALIASES.hasOwnProperty(action) ? ASCompat.toInt(LEGACY_ALIASES[action]) : 0;
	}

	public static function isMovement(action:String):Bool {
		return action == "moveUp" || action == "moveDown" || action == "moveLeft" || action == "moveRight";
	}

	public static function isWeaponAttack(action:String):Bool {
		return action == "attackWeapon1" || action == "attackWeapon2" || action == "attackWeapon3";
	}

	static function buildDefaults():ASObject {
		var _loc1_:ASObject = {};
		_loc1_["moveUp"] = [87, 38];
		_loc1_["moveDown"] = [83, 40];
		_loc1_["moveLeft"] = [65, 37];
		_loc1_["moveRight"] = [68, 39];
		_loc1_["attackWeapon1"] = [74, 90];
		_loc1_["attackWeapon2"] = [75, 88];
		_loc1_["attackWeapon3"] = [76, 67];
		_loc1_["useDungeonBuster"] = [66, 0];
		_loc1_["useConsumable1"] = [49, 0];
		_loc1_["useConsumable2"] = [50, 0];
		_loc1_["holdInPlace"] = [16, 0];
		_loc1_["reviveAlly"] = [32, 0];
		_loc1_["toggleChatLog"] = [220, 0];
		_loc1_["openOptionsMenu"] = [79, 0];
		return _loc1_;
	}

	static function buildLegacyAliases():ASObject {
		var _loc1_:ASObject = {};
		_loc1_["attackWeapon1"] = 89;
		return _loc1_;
	}
}
