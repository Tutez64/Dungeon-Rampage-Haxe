package facade;

import brain.assetRepository.AssetLoaderInfo;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.utils.TextUtil;
import flash.events.Event;
import flash.text.TextField;

class Locale {
	public static inline final DEFAULT_NAMETAG = "DEFAULT_NAMETAG";

	static var mDefaultStringTable:ASObject;

	static var mOverrideStringTable:ASObject;

	static var dbFacade:DBFacade;

	public static inline final MIN_FONT_SIZE_HIGH_RES = 9;

	public static inline final MIN_FONT_SIZE_HIGH_RES_LOCALIZED = 7;

	public static inline final MIN_FONT_SIZE_LOW_RES = 11;

	public static inline final MIN_FONT_SIZE_LOW_RES_LOCALIZED = 9;

	public static inline final LOW_RES_MAX_WIDTH = 1600;

	public static inline final LOW_RES_MAX_HEIGHT = 900;

	static var mMinFontSizeHighRes:Int = 9;

	static var mMinFontSizeHighResLocalized:Int = 7;

	static var mMinFontSizeLowRes:Int = 11;

	static var mMinFontSizeLowResLocalized:Int = 9;

	public static inline final NAMETAG_MIN_FONT_SIZE_PX = 18;

	static var mNametagMinFontSizePx:Int = 18;

	public static inline final SIZE_MODIFIER_UI:Float = 1;

	public static inline final SIZE_MODIFIER_WORLD:Float = 1.82;

	public static inline final RESCUE_ALERT_SIZE_MODIFIER:Float = 1.64;

	public static inline final SIZE_MODIFIER_OFFSCREEN:Float = 1.27;

	public static inline final OFFSCREEN_MARKER_SIZE_MODIFIER:Float = 1.82;

	public static inline final OFFSCREEN_RESCUE_SIZE_MODIFIER:Float = 1.36;

	public static inline final POPUP_MESSAGE_SIZE_MODIFIER:Float = 1.55;

	public static inline final GIFT_INFO_MESSAGE_SIZE_MODIFIER:Float = 1.55;

	public static inline final CREW_BONUS_TITLE_SIZE_MODIFIER:Float = 0.82;

	public static inline final CREW_BONUS_NUMBER_SIZE_MODIFIER:Float = 0.73;

	public static inline final HUD_CHAT_SIZE_MODIFIER:Float = 1.18;

	public static inline final STAT_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final STAT_UPGRADE_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final SHOP_TIMER_LABEL_SIZE_MODIFIER:Float = 1.55;

	public static inline final SHOP_COUNTDOWN_SIZE_MODIFIER:Float = 1.18;

	public static inline final SHOP_CARD_TIMER_SIZE_MODIFIER:Float = 1.55;

	public static inline final SHOP_OFFER_TITLE_SIZE_MODIFIER:Float = 1.45;

	public static inline final SHOP_OFFER_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final WEAPON_TOOLTIP_SIZE_MODIFIER:Float = 1.55;

	public static inline final WEAPON_ITEM_TOOLTIP_SIZE_MODIFIER:Float = 1.09;

	public static inline final SUMMARY_CHAT_SIZE_MODIFIER:Float = 1.55;

	public static inline final SUMMARY_NAME_LOW_RES_SIZE_MODIFIER:Float = 1.33;

	public static inline final SUMMARY_CHAT_BALLOON_SIZE_MODIFIER:Float = 1.47;

	public static inline final MAP_NODE_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final MAP_NODE_TITLE_SIZE_MODIFIER:Float = 1.73;

	public static inline final ULTIMATE_RAMPAGE_CYCLE_SIZE_MODIFIER:Float = 1.55;

	public static inline final HOW_TO_CURRENCY_SIZE_MODIFIER:Float = 1.55;

	public static inline final LOADING_HINT_SIZE_MODIFIER:Float = 1.55;

	public static inline final CHEST_HERO_LABEL_SIZE_MODIFIER:Float = 1.55;

	public static inline final DAILY_REWARD_COMEBACK_SIZE_MODIFIER:Float = 1.55;

	public static inline final TAVERN_STORY_SIZE_MODIFIER:Float = 1.55;

	public static inline final TAVERN_SKIN_STATUS_SIZE_MODIFIER:Float = 1.55;

	public static inline final FRIEND_MANAGER_DESCRIPTION_SIZE_MODIFIER:Float = 2.73;

	public static inline final FRIEND_INVITE_DESCRIPTION_SIZE_MODIFIER:Float = 2.73;

	public static inline final HERO_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final CHEST_REVEAL_DESCRIPTION_SIZE_MODIFIER:Float = 1.55;

	public static inline final NEWS_FEED_SIZE_MODIFIER:Float = 1.82;

	public function new() {}

	@:isVar public static var isDefaultLoaded(get, never):Bool;

	static public function get_isDefaultLoaded():Bool {
		return mDefaultStringTable != null;
	}

	@:isVar public static var isOverrideActive(get, never):Bool;

	static public function get_isOverrideActive():Bool {
		return mOverrideStringTable != null && mOverrideStringTable.strings != null;
	}

	@:isVar public static var isLowRes(get, never):Bool;

	static public function get_isLowRes():Bool {
		var _loc1_ = dbFacade != null ? dbFacade.stageRef : null;
		if (_loc1_ == null) {
			return true;
		}
		return _loc1_.stageWidth <= 1600 || _loc1_.stageHeight <= 900;
	}

	static function configMinFontSize(key:String, fallback:Int):Int {
		var _loc3_ = ASCompat.floatToInt(dbFacade.dbConfigManager.getConfigNumber(key, fallback));
		return _loc3_ > 0 ? _loc3_ : fallback;
	}

	public static function applyMinFontSize() {
		var _loc1_ = isLowRes;
		var _loc3_ = isOverrideActive;
		var _loc2_ = _loc1_ ? (_loc3_ ? mMinFontSizeLowResLocalized : mMinFontSizeLowRes) : (_loc3_ ? mMinFontSizeHighResLocalized : mMinFontSizeHighRes);
		TextUtil.minFontSize = _loc2_;
		Logger.debugch("Locale", "Minimum font size " + _loc2_ + " (" + (_loc1_ ? "low-res" : "high-res") + (_loc3_ ? ", localized" : "") + ")");
	}

	@:isVar public static var summaryNameSizeModifier(get, never):Float;

	static public function get_summaryNameSizeModifier():Float {
		return isLowRes ? 1.33 : 1;
	}

	@:isVar public static var nametagSizeModifier(get, never):Float;

	static public function get_nametagSizeModifier():Float {
		var _loc1_ = dbFacade != null && dbFacade.viewScale > 0 ? dbFacade.viewScale : 1;
		return TextUtil.modifierForSize(Math.fceil(mNametagMinFontSizePx / _loc1_));
	}

	static function onStageResize(event:Event) {
		applyMinFontSize();
	}

	public static function loadStrings(facade:DBFacade, callback:ASFunction) {
		var overrideLanguageAssetInfo:AssetLoaderInfo;
		var defaultLanguageAssetInfo:AssetLoaderInfo;
		dbFacade = facade;
		mMinFontSizeHighRes = configMinFontSize("min_font_size_high_res", 9);
		mMinFontSizeHighResLocalized = configMinFontSize("min_font_size_high_res_localized", 7);
		mMinFontSizeLowRes = configMinFontSize("min_font_size_low_res", 11);
		mMinFontSizeLowResLocalized = configMinFontSize("min_font_size_low_res_localized", 9);
		mNametagMinFontSizePx = configMinFontSize("nametag_min_font_size_px", 18);
		applyMinFontSize();
		if (facade.stageRef != null) {
			EventListeners.remove(facade.stageRef, "resize", onStageResize);
			EventListeners.add(facade.stageRef, "resize", onStageResize);
		}
		overrideLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.override.json"), false);
		facade.assetRepository.getJsonAsset(overrideLanguageAssetInfo, function(param1:brain.assetRepository.JsonAsset) {
			Logger.debugch("Locale", "Override Locale loaded!");
			mOverrideStringTable = param1.json;
			applyMinFontSize();
			callback();
		}, function() {
			Logger.warnch("Locale", "Failed to load Override Locale JSON.");
		});
		defaultLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.default.json"), false);
		facade.assetRepository.getJsonAsset(defaultLanguageAssetInfo, function(param1:brain.assetRepository.JsonAsset) {
			Logger.debugch("Locale", "Default Locale loaded!");
			mDefaultStringTable = param1.json;
			callback();
		}, function() {
			Logger.fatal("Default Locale File \'Locale.default.json\' failed to Load, cannot proceed with loading the game. Please run \'Verify integrity of game files\' on Steam.");
		});
	}

	public static function getString(key:String):String {
		var _loc4_ = false;
		if (mDefaultStringTable == null) {
			Logger.warnch("Locale", "You cannot call getString before load has finished: " + key);
			return key;
		}
		var _loc3_:String = null;
		if (mOverrideStringTable != null && mOverrideStringTable.strings != null) {
			_loc3_ = mOverrideStringTable.strings[key];
			_loc4_ = true;
			if (_loc3_ != null) {
				return _loc3_;
			}
		}
		var _loc2_:String = mDefaultStringTable.strings[key];
		if (_loc4_) {
			Logger.warnch("Locale", "Localized string not found: " + key);
		}
		if (_loc2_ == null) {
			Logger.warnch("Locale", "Default string not found: " + key);
			return "mia:" + key;
		}
		return _loc2_;
	}

	public static function getSubString(key:String, subKey:String):String {
		var _loc7_ = false;
		if (mDefaultStringTable == null) {
			Logger.warnch("Locale", "You cannot call getSubString before load has finished: " + key + " subKey: " + subKey);
			return key;
		}
		var _loc5_:ASObject = null;
		if (mOverrideStringTable != null && mOverrideStringTable.strings != null) {
			_loc5_ = mOverrideStringTable.strings[key];
			_loc7_ = true;
		}
		var _loc3_:ASObject = mDefaultStringTable.strings[key];
		if (_loc5_ == null && _loc3_ == null) {
			Logger.error("Unable to find in the `strings` table a dictionary for key: " + key + " (when looking up subKey: " + subKey + ")");
			return "mia:" + key;
		}
		var _loc6_:String = null;
		if (_loc5_ != null) {
			_loc6_ = _loc5_[subKey];
			if (_loc6_ != null) {
				return _loc6_;
			}
		}
		var _loc4_:String = _loc3_ != null ? _loc3_[subKey] : null;
		if (_loc7_) {
			Logger.warnch("Locale", "Localized sub string not found: "
				+ key
				+ " subKey: "
				+ subKey
				+ " Using English default value of: `"
				+ _loc4_
				+ "`");
		}
		if (_loc4_ == null) {
			Logger.error("Default sub string not found: " + key + " subKey: " + subKey);
			return "mia:" + key;
		}
		return _loc4_;
	}

	public static function setText(field:TextField, key:String, params:ASObject = null, sizeModifier:Float = 1) {
		field.text = key == null || key == "" ? "" : format(key, params);
		TextUtil.fitToField(field, sizeModifier);
	}

	public static function setSubText(field:TextField, key:String, subKey:String, sizeModifier:Float = 1) {
		field.text = key == null || key == "" ? "" : getSubString(key, subKey);
		TextUtil.fitToField(field, sizeModifier);
	}

	public static function format(key:String, params:ASObject):String {
		var _loc4_:compat.RegExp = null;
		var _loc3_ = getString(key);
		if (params == null) {
			return _loc3_;
		}
		var _loc5_:String;
		if (checkNullIteratee(params))
			for (_tmp_ in params.___keys()) {
				_loc5_ = _tmp_;
				_loc4_ = new compat.RegExp("#" + _loc5_ + "(?:#|(?![A-Za-z0-9_]))", "g");
				_loc3_ = _loc4_.split(_loc3_).join(ASCompat.toString(params[_loc5_]));
			}
		return _loc3_;
	}

	public static function getError(key:Int):String {
		var _loc4_ = false;
		if (mDefaultStringTable == null) {
			Logger.warnch("Locale", "You cannot call getError before load has finished: " + Std.string(key));
			return "Error (" + Std.string(key) + ")";
		}
		var _loc3_:String = null;
		if (mOverrideStringTable != null && mOverrideStringTable.errors != null) {
			_loc3_ = mOverrideStringTable.errors[Std.string(key)];
			_loc4_ = true;
			if (_loc3_ != null) {
				return _loc3_;
			}
		}
		var _loc2_:String = mDefaultStringTable.errors[Std.string(key)];
		if (_loc4_) {
			Logger.warnch("Locale", "Localized error string not found: " + Std.string(key));
		}
		if (_loc2_ == null) {
			Logger.warnch("Locale", "Default error string not found: " + Std.string(key));
			_loc2_ = mDefaultStringTable.errors["DEF"];
			if (_loc2_ == null) {
				_loc2_ = "Error ";
			}
			_loc2_ += "(" + Std.string(key) + ")";
		}
		return _loc2_;
	}
}
