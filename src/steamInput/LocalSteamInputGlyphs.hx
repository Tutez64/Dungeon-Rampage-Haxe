package steamInput;

import brain.assetRepository.AssetLoader;
import brain.logger.Logger;
import flash.filesystem.File;

class LocalSteamInputGlyphs {
	public static inline final DETECT_CONTROLLER_GLYPH = "";

	public static inline final PREFERENCE_XBOX_SERIES_X = "Xbox Series X";

	public static inline final PREFERENCE_XBOX_ONE = "Xbox One";

	public static inline final PREFERENCE_XBOX_360 = "Xbox 360";

	public static inline final PREFERENCE_PS5 = "PS5";

	public static inline final PREFERENCE_PS4 = "PS4";

	public static inline final PREFERENCE_PS3 = "PS3";

	public static inline final PREFERENCE_PS_VITA = "PS Vita";

	public static inline final PREFERENCE_PS_MOVE = "PS Move";

	public static inline final PREFERENCE_SWITCH = "Switch";

	public static inline final PREFERENCE_STEAM_DECK = "Steam Deck";

	public static inline final PREFERENCE_STEAM = "Steam";

	public static inline final PREFERENCE_AMAZON_LUNA = "Amazon Luna";

	public static inline final PREFERENCE_GOOGLE_STADIA = "Google Stadia";

	public static inline final PREFERENCE_OUYA = "Ouya";

	public static inline final PREFERENCE_WII = "Wii";

	public static inline final PREFERENCE_WII_U = "WiiU";

	public static inline final PREFERENCE_OCULUS = "Oculus";

	public static inline final PREFERENCE_VIVE = "Vive";

	public static inline final PREFERENCE_DEFAULT = "";

	static inline final GLYPH_DIRECTORY = "Resources/Glyphs";

	var mGlyphPathsByName:ASDictionary<ASAny, ASAny>;

	public function new() {}

	public function getGlyphPath(steamGlyphPath:String, preference:String):String {
		if (steamGlyphPath == null || steamGlyphPath == "" || steamGlyphPath == "error1") {
			return null;
		}
		ensureGlyphIndexIsLoaded();
		var _loc3_ = getControlFromSteamGlyphPath(steamGlyphPath);
		var _loc4_ = getPreferredGlyphName(preference, _loc3_);
		if (_loc4_ == null) {
			return null;
		}
		return ASDictionary.getString(mGlyphPathsByName, normalise(_loc4_));
	}

	function ensureGlyphIndexIsLoaded() {
		if (mGlyphPathsByName != null) {
			return;
		}
		mGlyphPathsByName = new ASDictionary<ASAny, ASAny>();
		var _loc1_ = AssetLoader.resolveFile("Resources/Glyphs");
		if (!_loc1_.exists || !_loc1_.isDirectory) {
			Logger.warnch("Input", "LocalSteamInputGlyphs: Glyph directory not found at \'" + _loc1_.nativePath + "\'. Steam glyphs will be used.");
			return;
		}
		indexGlyphDirectory(_loc1_);
		Logger.infoch("Input", "LocalSteamInputGlyphs: Indexed bundled glyphs from \'" + _loc1_.nativePath + "\'.");
	}

	function indexGlyphDirectory(directory:File) {
		var _loc3_:String = null;
		var _loc2_:File;
		final __ax4_iter_101 = directory.getDirectoryListing();
		if (checkNullIteratee(__ax4_iter_101))
			for (_tmp_ in __ax4_iter_101) {
				_loc2_ = ASCompat.coerce(_tmp_, flash.filesystem.File);
				if (_loc2_.isDirectory) {
					indexGlyphDirectory(_loc2_);
				} else if (_loc2_.extension != null && _loc2_.extension.toLowerCase() == "png") {
					_loc3_ = normalise(_loc2_.name.substring(0, _loc2_.name.length - 4));
					if (ASCompat.dictionaryLookupEqNull(mGlyphPathsByName, _loc3_)) {
						mGlyphPathsByName[_loc3_] = _loc2_.nativePath;
					}
				}
			}
	}

	function getControlFromSteamGlyphPath(steamGlyphPath:String):String {
		var _loc5_ = steamGlyphPath.split("?")[0];
		var _loc3_:Array<ASAny> = (cast new compat.RegExp("\\\\", "g").replace(_loc5_, "/").split("/"));
		var _loc4_ = new compat.RegExp("_(sm|md|lg)\\.png$").replace(ASCompat.toString(_loc3_[_loc3_.length - 1]).toLowerCase(), "");
		_loc4_ = new compat.RegExp("^(shared_color_outlined_button_|shared_color_button_|shared_outlined_button_|shared_button_)").replace(_loc4_, "");
		if (_loc4_ == "a" || _loc4_ == "b" || _loc4_ == "x" || _loc4_ == "y") {
			return _loc4_.toUpperCase();
		}
		_loc4_ = new compat.RegExp("^(ps_color_outlined_button_|ps_color_button_|ps_outlined_button_|ps_button_)").replace(_loc4_, "");
		if (_loc4_ == "x") {
			return "A";
		}
		if (_loc4_ == "circle") {
			return "B";
		}
		if (_loc4_ == "square") {
			return "X";
		}
		if (_loc4_ == "triangle") {
			return "Y";
		}
		var _loc2_:ASObject = {
			"shared_dpad": "Dpad",
			"shared_dpad_up": "Dpad_Up",
			"shared_dpad_down": "Dpad_Down",
			"shared_dpad_left": "Dpad_Left",
			"shared_dpad_right": "Dpad_Right",
			"ps_dpad": "Dpad",
			"ps_dpad_up": "Dpad_Up",
			"ps_dpad_down": "Dpad_Down",
			"ps_dpad_left": "Dpad_Left",
			"ps_dpad_right": "Dpad_Right",
			"switchpro_dpad": "Dpad",
			"switchpro_dpad_up": "Dpad_Up",
			"switchpro_dpad_down": "Dpad_Down",
			"switchpro_dpad_left": "Dpad_Left",
			"switchpro_dpad_right": "Dpad_Right",
			"xbox_lb": "LB",
			"ps_lb": "LB",
			"switchpro_l": "LB",
			"xbox_rb": "RB",
			"ps_rb": "RB",
			"switchpro_r": "RB",
			"xbox_lt": "LT",
			"switchpro_l2": "LT",
			"xbox_rt": "RT",
			"switchpro_r2": "RT",
			"shared_lstick": "Left_Stick",
			"shared_lstick_click": "Left_Stick_Click",
			"shared_rstick": "Right_Stick",
			"shared_rstick_click": "Right_Stick_Click",
			"switchpro_lstick": "Left_Stick",
			"switchpro_lstick_click": "Left_Stick_Click",
			"switchpro_rstick": "Right_Stick",
			"switchpro_rstick_click": "Right_Stick_Click",
			"xbox_button_start": "Menu",
			"xbox_button_select": "View",
			"xbox_button_share": "Share",
			"switchpro_button_plus": "Menu",
			"switchpro_button_minus": "View",
			"switchpro_button_capture": "Share"
		};
		return _loc2_[_loc4_];
	}

	function getPreferredGlyphName(preference:String, control:String):String {
		if (control == null) {
			return null;
		}
		switch (normalise(preference)) {
			case "xboxseries" | "xboxseriesx":

			case "xboxone":
				return "XboxOne_" + control;
			case "xbox360":
				return "360_" + menuControl(control, "Start", "Back");
			case "ps5":
				return "PS5_" + playStationControl(control);
			case "ps4":
				return "PS4_" + playStationControl(control);
			case "ps3":
				return "PS3_" + legacyPlayStationControl(control);
			case "psvita":
				return "Vita_" + vitaControl(control);
			case "psmove":
				return "PSMove_" + legacyPlayStationControl(control);
			case "switch":
				return "Switch_" + control;
			case "steamdeck":
				return "SteamDeck_" + steamDeckControl(control);
			case "steam":
				return "Steam_" + steamControl(control);
			case "amazonluna":
				return "Luna_" + control;
			case "googlestadia":
				return "Stadia_" + stadiaControl(control);
			case "ouya":
				return "Ouya_" + ouyaControl(control);
			case "wii":
				return "Wii_" + menuControl(control, "Plus", "Minus");
			case "wiiu":
				return "WiiU_" + wiiUControl(control);
			case "oculus":
				return "Oculus_" + control;
			case "vive":
				return "Vive_" + control;
			default:
				return null;
		}
		return "XboxSeriesX_" + control;
	}

	function playStationControl(control:String):String {
		if (control == "A") {
			return "Cross";
		}
		if (control == "B") {
			return "Circle";
		}
		if (control == "X") {
			return "Square";
		}
		if (control == "Y") {
			return "Triangle";
		}
		if (control == "LB") {
			return "L1";
		}
		if (control == "RB") {
			return "R1";
		}
		if (control == "LT") {
			return "L2";
		}
		if (control == "RT") {
			return "R2";
		}
		if (control == "Menu") {
			return "Options";
		}
		if (control == "View") {
			return "Share";
		}
		return control;
	}

	function steamDeckControl(control:String):String {
		if (control == "LB") {
			return "L1";
		}
		if (control == "RB") {
			return "R1";
		}
		if (control == "LT") {
			return "L2";
		}
		if (control == "RT") {
			return "R2";
		}
		if (control == "View") {
			return "Inventory";
		}
		return control;
	}

	function vitaControl(control:String):String {
		if (control == "LB") {
			return "Bumpter_Left";
		}
		if (control == "RB") {
			return "Bumper_Right";
		}
		return legacyPlayStationControl(control);
	}

	function legacyPlayStationControl(control:String):String {
		if (control == "Menu") {
			return "Start";
		}
		if (control == "View") {
			return "Select";
		}
		return playStationControl(control);
	}

	function steamControl(control:String):String {
		if (control == "Left_Stick" || control == "Left_Stick_Click") {
			return "Stick";
		}
		return menuControl(control, "Start", "Back");
	}

	function stadiaControl(control:String):String {
		if (control == "LB") {
			return "L1";
		}
		if (control == "RB") {
			return "R1";
		}
		if (control == "LT") {
			return "L2";
		}
		if (control == "RT") {
			return "R2";
		}
		return menuControl(control, "Menu", "Select");
	}

	function ouyaControl(control:String):String {
		if (control == "A") {
			return "O";
		}
		if (control == "B") {
			return "A";
		}
		if (control == "X") {
			return "U";
		}
		return control;
	}

	function wiiUControl(control:String):String {
		if (control == "LB") {
			return "L";
		}
		if (control == "RB") {
			return "R";
		}
		if (control == "LT") {
			return "ZL";
		}
		if (control == "RT") {
			return "ZR";
		}
		return menuControl(control, "Plus", "Minus");
	}

	function menuControl(control:String, menuName:String, viewName:String):String {
		if (control == "Menu") {
			return menuName;
		}
		if (control == "View") {
			return viewName;
		}
		return control;
	}

	function normalise(value:String):String {
		return value == null ? "" : new compat.RegExp("[^a-z0-9]", "g").replace(value.toLowerCase(), "");
	}
}
