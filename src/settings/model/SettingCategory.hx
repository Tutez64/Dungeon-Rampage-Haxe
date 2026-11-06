package settings.model;

class SettingCategory {
	public static inline final GRAPHICS = "graphics";

	public static inline final AUDIO = "audio";

	public static inline final CONTROLS = "controls";

	public static inline final INTERFACE = "interface";

	public static inline final DISPLAY = "display";

	public static inline final ADVANCED = "advanced";

	public static final ORDERED:Vector<String> = Vector.ofArray(["graphics", "audio", "controls", "interface", "display", "advanced"]);

	public function new() {}

	public static function getLabelKey(category:String):String {
		return "SETTINGS_CATEGORY_" + category.toUpperCase();
	}

	public static function indexOf(category:String):Int {
		return ORDERED.indexOf(category);
	}
}
