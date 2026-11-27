package uI.cursor;

import combat.weapon.WeaponGameObject;
import dBGlobals.DBGlobal;
import facade.DBFacade;

class UIMouseCursors {
	public static inline final ARROW = "ARROW";

	public static inline final POINT = "POINT";

	public static inline final HAND = "HAND";

	public static inline final DRAG = "DRAG";

	public static inline final SWORD = "SWORD";

	public static inline final BOW = "BOW";

	public static inline final STAFF = "STAFF";

	static var ArrowArt:Dynamic = Db_UI_cursors_swf_2;

	static var PointArt:Dynamic = Db_UI_cursors_swf_c12ba094d1b838815d2550f1d60f1c5b904251893;

	static var HandArt:Dynamic = Db_UI_cursors_swf_c12ba094d1b838815d2550f1d60f1c5b1019661057;

	static var DragArt:Dynamic = Db_UI_cursors_swf_c12ba094d1b838815d2550f1d60f1c5b1019411263;

	static var SwordArt:Dynamic = Db_UI_cursors_swf_c12ba094d1b838815d2550f1d60f1c5b903334214;

	static var BowArt:Dynamic = Db_UI_cursors_swf;

	static var StaffArt:Dynamic = Db_UI_cursors_swf_c12ba094d1b838815d2550f1d60f1c5b902912549;

	public function new() {}

	public static function register(dbFacade:DBFacade) {
		var _loc2_ = dbFacade.mouseCursorManager;
		_loc2_.registerMouseCursor("ARROW", ASCompat.coerce(ASCompat.createInstance(ArrowArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("POINT", ASCompat.coerce(ASCompat.createInstance(PointArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("HAND", ASCompat.coerce(ASCompat.createInstance(HandArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("DRAG", ASCompat.coerce(ASCompat.createInstance(DragArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("SWORD", ASCompat.coerce(ASCompat.createInstance(SwordArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("BOW", ASCompat.coerce(ASCompat.createInstance(BowArt, []), flash.display.DisplayObject));
		_loc2_.registerMouseCursor("STAFF", ASCompat.coerce(ASCompat.createInstance(StaffArt, []), flash.display.DisplayObject));
		_loc2_.defaultMouseCursor = "ARROW";
	}

	public static function setDefault(dbFacade:DBFacade, name:String) {
		dbFacade.mouseCursorManager.defaultMouseCursor = name;
	}

	public static function forWeapon(dbFacade:DBFacade, weapon:WeaponGameObject):String {
		if (weapon == null || !dbFacade.featureFlags.getFlagValue("want-weapon-cursors")) {
			return "SWORD";
		}
		if (weapon.weaponData.ClassType == DBGlobal.SHOOTING_ITEM_CATEGORY) {
			return "BOW";
		}
		if (weapon.weaponData.ClassType == DBGlobal.MAGIC_ITEM_CATEGORY) {
			return "STAFF";
		}
		return "SWORD";
	}
}
