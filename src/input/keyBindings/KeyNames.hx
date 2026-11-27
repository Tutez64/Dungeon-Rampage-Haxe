package input.keyBindings;

class KeyNames {
	static final NAMES:ASObject = buildNames();

	public function new() {}

	public static function displayName(keyCode:Int):String {
		if (keyCode == 0) {
			return "";
		}
		if (keyCode >= 65 && keyCode <= 90) {
			return String.fromCharCode(keyCode);
		}
		if (keyCode >= 48 && keyCode <= 57) {
			return String.fromCharCode(keyCode);
		}
		if (keyCode >= 96 && keyCode <= 105) {
			return "NUM " + (keyCode - 96);
		}
		if (keyCode >= 112 && keyCode <= 126) {
			return "F" + (keyCode - 112 + 1);
		}
		if (NAMES.hasOwnProperty(Std.string(keyCode))) {
			return NAMES[Std.string(keyCode)];
		}
		return "KEY " + keyCode;
	}

	static function buildNames():ASObject {
		var _loc1_:ASObject = {};
		_loc1_[Std.string(8)] = "BACKSPACE";
		_loc1_[Std.string(9)] = "TAB";
		_loc1_[Std.string(13)] = "ENTER";
		_loc1_[Std.string(16)] = "SHIFT";
		_loc1_[Std.string(17)] = "CTRL";
		_loc1_[Std.string(18)] = "ALT";
		_loc1_[Std.string(20)] = "CAPS LOCK";
		_loc1_[Std.string(27)] = "ESC";
		_loc1_[Std.string(32)] = "SPACE";
		_loc1_[Std.string(33)] = "PAGE UP";
		_loc1_[Std.string(34)] = "PAGE DOWN";
		_loc1_[Std.string(35)] = "END";
		_loc1_[Std.string(36)] = "HOME";
		_loc1_[Std.string(37)] = "LEFT";
		_loc1_[Std.string(38)] = "UP";
		_loc1_[Std.string(39)] = "RIGHT";
		_loc1_[Std.string(40)] = "DOWN";
		_loc1_[Std.string(45)] = "INSERT";
		_loc1_[Std.string(46)] = "DELETE";
		_loc1_[Std.string(107)] = "NUM +";
		_loc1_[Std.string(109)] = "NUM -";
		_loc1_[Std.string(106)] = "NUM *";
		_loc1_[Std.string(111)] = "NUM /";
		_loc1_[Std.string(110)] = "NUM .";
		_loc1_[Std.string(108)] = "NUM ENTER";
		_loc1_[Std.string(186)] = ";";
		_loc1_[Std.string(187)] = "=";
		_loc1_[Std.string(188)] = ",";
		_loc1_[Std.string(189)] = "-";
		_loc1_[Std.string(190)] = ".";
		_loc1_[Std.string(191)] = "/";
		_loc1_[Std.string(192)] = "`";
		_loc1_[Std.string(219)] = "[";
		_loc1_[Std.string(220)] = "\\";
		_loc1_[Std.string(221)] = "]";
		_loc1_[Std.string(222)] = "\'";
		return _loc1_;
	}
}
