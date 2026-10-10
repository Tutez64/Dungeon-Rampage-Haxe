package steamAchievements;

class SteamStats {
	public static inline final INT_STAT = 0;

	var mAPIName:String;

	var mStatType:Int = 0;

	var mClientIntValue:Int = 0;

	var mStoreStatsThreshold:Int = 0;

	public function new(inAPIName:String, inType:Int, inUpdateThreshold:Int = 1) {
		mAPIName = inAPIName;
		mStatType = inType;
		mStoreStatsThreshold = inUpdateThreshold;
	}

	public static function steamStatFactory(inAPIName:String, inSteamStatsType:Int, inUpdateThreshold:Int):SteamStats {
		return new SteamStats(inAPIName, inSteamStatsType, inUpdateThreshold);
	}

	@:isVar public var APIName(get, never):String;

	public function get_APIName():String {
		return mAPIName;
	}

	@:isVar public var StatType(get, never):Int;

	public function get_StatType():Int {
		return mStatType;
	}

	@:isVar public var ClientIntValue(get, never):Int;

	public function get_ClientIntValue():Int {
		return mClientIntValue;
	}

	@:isVar public var StoreStatsThreshold(get, never):Int;

	public function get_StoreStatsThreshold():Int {
		return mStoreStatsThreshold;
	}

	public function setClientIntValue(inClientIntValue:Int) {
		mClientIntValue = inClientIntValue;
	}

	public function increaseClientIntValue(inClientIntValue:Int) {
		mClientIntValue += inClientIntValue;
	}
}
