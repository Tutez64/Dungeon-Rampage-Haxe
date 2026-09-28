package modding;

import distributedObjects.HeroGameObject;

/** One hero in the world. Fields read the live object and go empty once it is gone. */
class ModHero {
	public var id(default, null):UInt;

	/** True for the local player, false for everyone else. */
	public var local(default, null):Bool;

	public var name(get, never):String;

	var hero:HeroGameObject;

	@:allow(modding.Host)
	function new(hero:HeroGameObject, local:Bool) {
		this.hero = hero;
		this.local = local;
		id = hero.id;
	}

	function get_name():String {
		if (hero == null || hero.isDestroyed)
			return "";
		var value = hero.screenName;
		return value == null ? "" : value;
	}
}
