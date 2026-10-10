package account;

class PlayerSpecialStatus {
	public function new() {}

	public static function getSpecialTextColor(playerName:String, defaultColor:UInt):UInt {
		if (playerName.charAt(0) == "★") {
			return (380536 : UInt);
		}
		if (playerName.charAt(0) == "⚡") {
			return (16738339 : UInt);
		}
		if (playerName.charAt(0) == "⚠") {
			return defaultColor;
		}
		return defaultColor;
	}
}
