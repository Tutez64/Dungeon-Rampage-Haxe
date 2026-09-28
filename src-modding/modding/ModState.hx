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

	/** Heroes currently in the world, local and remote, town and dungeon. */
	public var heroes(default, null):Array<ModHero> = [];

	public function new() {}

	@:allow(modding.Host)
	function setAccount(value:Null<ModAccount>):Void {
		account = value;
	}

	@:allow(modding.Host)
	function setFloor(value:Null<ModFloor>):Void {
		floor = value;
	}
}
