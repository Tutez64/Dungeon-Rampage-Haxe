package settings.model;

import settings.model.bindings.ISettingBinding;

class SettingDefinition {
	public var id:String;

	public var category:String;

	public var labelKey:String;

	public var descriptionKey:String;

	public var labelText:String;

	public var descriptionText:String;

	public var defaultValue:ASAny;

	public var binding:ISettingBinding;

	public var requiresRestart:Bool = false;

	public var minimum:Float = Math.NaN;

	public var maximum:Float = Math.NaN;

	public var step:Float = Math.NaN;

	public var decimals:Int = 0;

	public var displayScale:Float = 1;

	public var choices:Vector<SettingChoice>;

	public var coerceValue:ASFunction;

	public var descriptionKeyProvider:ASFunction;

	public var keyBindingAction:String;

	public function new(id:String, category:String, labelKey:String, descriptionKey:String, defaultValue:ASAny, binding:ISettingBinding,
			requiresRestart:Bool = false) {
		this.id = id;
		this.category = category;
		this.labelKey = labelKey;
		this.descriptionKey = descriptionKey;
		this.defaultValue = defaultValue;
		this.binding = binding;
		this.requiresRestart = requiresRestart;
	}

	public static function labelKeyFor(id:String):String {
		return "SETTING_" + toConstantCase(id);
	}

	public static function descriptionKeyFor(id:String):String {
		return "SETTING_" + toConstantCase(id) + "_DESC";
	}

	public static function choiceLabelKeyFor(id:String, value:ASAny):String {
		return labelKeyFor(id) + "_" + toConstantCase(ASCompat.toString(value));
	}

	static function toConstantCase(camelCase:String):String {
		var _loc6_ = 0;
		var _loc4_:String = null;
		var _loc3_ = false;
		var _loc5_ = false;
		var _loc2_ = "";
		var _loc7_ = false;
		_loc6_ = 0;
		while (_loc6_ < camelCase.length) {
			_loc4_ = camelCase.charAt(_loc6_);
			_loc3_ = _loc4_ == _loc4_.toUpperCase() && _loc4_ != _loc4_.toLowerCase();
			_loc5_ = _loc4_ >= "0" && _loc4_ <= "9";
			if (_loc6_ > 0 && (_loc3_ || _loc5_ && !_loc7_)) {
				_loc2_ += "_";
			}
			_loc2_ += _loc4_.toUpperCase();
			_loc7_ = _loc5_;
			_loc6_++;
		}
		return _loc2_;
	}

	@:isVar public var isChoice(get, never):Bool;

	public function get_isChoice():Bool {
		return choices != null;
	}

	@:isVar public var isSlider(get, never):Bool;

	public function get_isSlider():Bool {
		return !isChoice && !isKeyBinding && !Math.isNaN(minimum);
	}

	@:isVar public var isKeyBinding(get, never):Bool;

	public function get_isKeyBinding():Bool {
		return keyBindingAction != null;
	}

	@:isVar public var isBoolean(get, never):Bool;

	public function get_isBoolean():Bool {
		return !isChoice && !isSlider && !isKeyBinding;
	}

	@:isVar public var isPersisted(get, never):Bool;

	public function get_isPersisted():Bool {
		return binding != null;
	}

	@:isVar public var isPreset(get, never):Bool;

	public function get_isPreset():Bool {
		if (choices == null) {
			return false;
		}
		var _loc1_:SettingChoice;
		final __ax4_iter_469 = choices;
		if (checkNullIteratee(__ax4_iter_469))
			for (_tmp_ in __ax4_iter_469) {
				_loc1_ = _tmp_;
				if (_loc1_.memberValues != null) {
					return true;
				}
			}
		return false;
	}

	public function findChoice(value:ASAny):SettingChoice {
		if (choices == null) {
			return null;
		}
		var _loc2_:SettingChoice;
		final __ax4_iter_470 = choices;
		if (checkNullIteratee(__ax4_iter_470))
			for (_tmp_ in __ax4_iter_470) {
				_loc2_ = _tmp_;
				if (_loc2_.value == value) {
					return _loc2_;
				}
			}
		return null;
	}
}
