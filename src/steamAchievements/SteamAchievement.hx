package steamAchievements;

class SteamAchievement {
	var mAPIName:String;

	var mIsAchieved:Bool = false;

	public function new(inAPIName:String) {
		mAPIName = inAPIName;
		mIsAchieved = false;
	}

	public static function steamAchievementFactory(inAPIName:String):SteamAchievement {
		return new SteamAchievement(inAPIName);
	}

	@:isVar public var APIName(get, never):String;

	public function get_APIName():String {
		return mAPIName;
	}

	@:isVar public var IsAchieved(get, never):Bool;

	public function get_IsAchieved():Bool {
		return mIsAchieved;
	}

	public function setIsAchieved(inAchieved:Bool) {
		mIsAchieved = inAchieved;
	}
}
