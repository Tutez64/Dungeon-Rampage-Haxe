package modding;

/**
 * Live window handed to every mod.
 *
 * Account is filled at `onReady`. Hero and floor wrappers stay absent until the
 * matching event. Adding a field later does not bump `modding.Version.API`.
 */
class ModState {
	/** Account-level reading. Null until `onReady`. */
	public var account(default, null):Null<ModAccount>;

	/** Dungeon floor in progress. Null in town and until `floorEnter`. */
	public var floor(default, null):Null<ModFloor>;

	/** Heroes currently on a dungeon floor, local and remote. A copy: changing it changes nothing. */
	public var heroes(get, never):Array<ModHero>;

	/**
	 * Players met in the dungeon in progress, in order of arrival, those who left included. Emptied on
	 * `townEnter`. A copy.
	 */
	public var players(get, never):Array<ModPlayer>;

	var heroList:Array<ModHero> = [];

	var playerList:Array<ModPlayer> = [];

	public function new() {}

	function get_heroes():Array<ModHero> {
		return heroList.copy();
	}

	function get_players():Array<ModPlayer> {
		return playerList.copy();
	}

	@:allow(modding.Host)
	function setAccount(value:Null<ModAccount>):Void {
		account = value;
	}

	@:allow(modding.Host)
	function setFloor(value:Null<ModFloor>):Void {
		floor = value;
	}

	@:allow(modding.Host)
	function addHero(hero:ModHero):Void {
		heroList.push(hero);
	}

	@:allow(modding.Host)
	function removeHero(hero:ModHero):Void {
		heroList.remove(hero);
	}

	@:allow(modding.Host)
	function addPlayer(player:ModPlayer):Void {
		playerList.push(player);
	}

	@:allow(modding.Host)
	function clearPlayers():Void {
		playerList = [];
	}
}
