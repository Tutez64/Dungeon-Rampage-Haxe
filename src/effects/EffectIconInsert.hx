package effects;

class EffectIconInsert {
	public var iconPath:String;

	public var iconName:String;

	public var markerName:String;

	public function new(iconPath:String, iconName:String, markerName:String) {
		this.iconPath = iconPath;
		this.iconName = iconName;
		this.markerName = markerName;
	}
}
