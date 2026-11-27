package settings.model;

class SettingChoice {
	public var value:ASAny;

	public var labelKey:String;

	public var memberValues:ASObject;

	public var derived:Bool = false;

	public function new(value:ASAny, labelKey:String, memberValues:ASObject = null, derived:Bool = false) {
		this.value = value;
		this.labelKey = labelKey;
		this.memberValues = memberValues;
		this.derived = derived;
	}
}
