package settings.model.bindings;

interface ISettingBinding {
	function read():ASAny;

	function write(value:ASAny):Void;

	function writeInitial(value:ASAny):Void;

	function destroy():Void;
}
