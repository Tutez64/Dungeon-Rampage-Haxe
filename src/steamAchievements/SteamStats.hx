package steamAchievements;

class SteamStats {
	public static inline final INT_STAT = 0;

	var mAPIName:String;

	var mStatType:Int = 0;

	var mClientIntValue:Int = 0;

	var mStoreStatsThreshold:Int = 0;

	var mMaxValue:Int = 0;

	public function new(inAPIName:String, inType:Int, inUpdateThreshold:Int = 1, inMaxValue:Int = 2000000000) {
		mAPIName = inAPIName;
		mStatType = inType;
		mStoreStatsThreshold = inUpdateThreshold;
		mMaxValue = inMaxValue;
	}

	public static function steamStatFactory(inAPIName:String, inSteamStatsType:Int, inUpdateThreshold:Int, inMaxValue:Int = 2000000000):SteamStats {
		return new SteamStats(inAPIName, inSteamStatsType, inUpdateThreshold, inMaxValue);
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

	public function setClientIntValue(inClientIntValue:Float) {
		if (inClientIntValue < 0 || inClientIntValue % 1 != 0) {
			return;
		}
		mClientIntValue = ASCompat.floatToInt(Math.min(mMaxValue, inClientIntValue));
	}

	public function increaseClientIntValue(inClientIntValue:Float) {
		if (inClientIntValue < 0 || inClientIntValue % 1 != 0) {
			return;
		}
		setClientIntValue(mClientIntValue + inClientIntValue);
	}
}
