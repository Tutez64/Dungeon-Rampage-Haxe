package settings.model;

class GraphicsPreset {
	public static inline final PERFORMANCE = "performance";

	public static inline final QUALITY = "quality";

	public static inline final CUSTOM = "custom";

	public static final MEMBERS:Vector<String> = Vector.ofArray(["zoom", "rarityBackgrounds", "damageFloaters", "busterBackgroundFade"]);

	public function new() {}

	public static function membersAt(value:Bool):ASObject {
		var _loc2_:ASObject = {};
		var _loc3_:String;
		final __ax4_iter_454 = MEMBERS;
		if (checkNullIteratee(__ax4_iter_454))
			for (_tmp_ in __ax4_iter_454) {
				_loc3_ = _tmp_;
				_loc2_[_loc3_] = value;
			}
		return _loc2_;
	}
}
