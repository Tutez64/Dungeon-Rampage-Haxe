package settings.model;

class SettingIds {
	public static inline final GRAPHICS_PRESET = "graphicsPreset";

	public static inline final ZOOM = "zoom";

	public static inline final DAMAGE_FLOATERS = "damageFloaters";

	public static inline final RARITY_BACKGROUNDS = "rarityBackgrounds";

	public static inline final BUSTER_BACKGROUND_FADE = "busterBackgroundFade";

	public static inline final MUSIC_VOLUME = "musicVolume";

	public static inline final SFX_VOLUME = "sfxVolume";

	public static inline final STEAM_INPUT = "steamInput";

	public static inline final CONTROLLER_RUMBLE = "controllerRumble";

	public static inline final KEY_MOVE_UP = "keyMoveUp";

	public static inline final KEY_MOVE_DOWN = "keyMoveDown";

	public static inline final KEY_MOVE_LEFT = "keyMoveLeft";

	public static inline final KEY_MOVE_RIGHT = "keyMoveRight";

	public static inline final KEY_ATTACK_WEAPON_1 = "keyAttackWeapon1";

	public static inline final KEY_ATTACK_WEAPON_2 = "keyAttackWeapon2";

	public static inline final KEY_ATTACK_WEAPON_3 = "keyAttackWeapon3";

	public static inline final KEY_USE_DUNGEON_BUSTER = "keyUseDungeonBuster";

	public static inline final KEY_USE_CONSUMABLE_1 = "keyUseConsumable1";

	public static inline final KEY_USE_CONSUMABLE_2 = "keyUseConsumable2";

	public static inline final KEY_HOLD_IN_PLACE = "keyHoldInPlace";

	public static inline final KEY_REVIVE_ALLY = "keyReviveAlly";

	public static inline final KEY_TOGGLE_CHAT_LOG = "keyToggleChatLog";

	public static inline final KEY_OPEN_OPTIONS_MENU = "keyOpenOptionsMenu";

	public static inline final HUD_STYLE = "hudStyle";

	public static inline final NUMBERS_ON_BARS = "numbersOnBars";

	public static inline final TOWN_ANIMATIONS = "townAnimations";

	public static inline final PICKUP_UI_POP = "pickupUiPop";

	public static inline final FPS = "fps";

	public static inline final VSYNC = "vsync";

	public static inline final START_WINDOWED = "startWindowed";

	public static inline final STARLING_RENDERER = "starlingRenderer";

	public static inline final RESUMABLE_CONNECTION = "resumableConnection";

	public static inline final STARLING_HUD = "starlingHud";

	public function new() {}

	public static function keyBindingIdFor(action:String):String {
		switch (action) {
			case "moveUp":
				return "keyMoveUp";
			case "moveDown":
				return "keyMoveDown";
			case "moveLeft":
				return "keyMoveLeft";
			case "moveRight":
				return "keyMoveRight";
			case "attackWeapon1":
				return "keyAttackWeapon1";
			case "attackWeapon2":
				return "keyAttackWeapon2";
			case "attackWeapon3":
				return "keyAttackWeapon3";
			case "useDungeonBuster":
				return "keyUseDungeonBuster";
			case "useConsumable1":
				return "keyUseConsumable1";
			case "useConsumable2":
				return "keyUseConsumable2";
			case "holdInPlace":
				return "keyHoldInPlace";
			case "reviveAlly":
				return "keyReviveAlly";
			case "toggleChatLog":
				return "keyToggleChatLog";
			case "openOptionsMenu":
				return "keyOpenOptionsMenu";
			default:
				throw new Error("No setting id for input action: " + action);
		}
		return null;
	}
}
