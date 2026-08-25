package uI.infiniteIsland;

import com.maccherone.json.JSON;

class II_ChampionsboardTopScore {
	public var name:String;

	public var score:Int = 0;

	public var skinId:Int = 0;

	var mWeaponsJson:Array<Dynamic>;

	public function new(nameVal:String, scoreVal:Int, skinVal:Int, weapon1:String, weapon2:String, weapon3:String) {
		name = nameVal;
		score = scoreVal;
		skinId = skinVal;
		mWeaponsJson = new Array<Dynamic>();
		if (weapon1 != null) {
			mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon1));
		} else {
			mWeaponsJson.push(null);
		}
		if (weapon1 != null) {
			mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon2));
		} else {
			mWeaponsJson.push(null);
		}
		if (weapon1 != null) {
			mWeaponsJson.push(com.maccherone.json.JSON.decode(weapon3));
		} else {
			mWeaponsJson.push(null);
		}
	}

	@:isVar public var weaponsJson(get, never):Array<Dynamic>;

	public function get_weaponsJson():Array<Dynamic> {
		return mWeaponsJson;
	}
}
