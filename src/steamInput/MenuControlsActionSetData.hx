package steamInput;

class MenuControlsActionSetData {
	public static inline final actionSetName = "MenuControls";

	public static inline final movementActionName = "menu_movement";

	public static inline final upActionName = "menu_up";

	public static inline final downUpActionName = "menu_down";

	public static inline final leftUpActionName = "menu_left";

	public static inline final rightUpActionName = "menu_right";

	public static inline final selectActionName = "menu_select";

	public static inline final cancelActionName = "menu_cancel";

	public static inline final returnActionName = "menu_return";

	public static inline final previousCategoryActionName = "menu_previous_category";

	public static inline final nextCategoryActionName = "menu_next_category";

	public static inline final optionsMenuActionName = "menu_options";

	public function new() {}

	public static function gatherAnalogActionNames():Vector<String> {
		var _loc1_ = new Vector<String>();
		_loc1_.push("menu_movement");
		return _loc1_;
	}

	public static function gatherDigitalActionNames():Vector<String> {
		var _loc1_ = new Vector<String>();
		_loc1_.push("menu_up");
		_loc1_.push("menu_down");
		_loc1_.push("menu_left");
		_loc1_.push("menu_right");
		_loc1_.push("menu_select");
		_loc1_.push("menu_cancel");
		_loc1_.push("menu_return");
		_loc1_.push("menu_previous_category");
		_loc1_.push("menu_next_category");
		_loc1_.push("menu_options");
		return _loc1_;
	}
}
