package modding;

import distributedObjects.HeroGameObject;
import facade.GameMasterLocale;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMWeaponItem;

/**
 * One hero on a dungeon floor: what a player plays there. Each floor gives a new one. Fields read
 * the live object and go empty at `heroDespawned`; the player behind it stays in `player`.
 */
class ModHero {
	/** The hero's object id on the floor, not an account: see `player`. */
	public var id(default, null):UInt;

	/** True for the local player's hero. */
	public var local(default, null):Bool;

	/** The player playing this hero. Null only if the game sent no account for it. */
	public var player(default, null):Null<ModPlayer>;

	/** GameMaster hero class id, 0 once the hero is gone. */
	public var classId(get, never):UInt;

	/** Name of the hero class, as the game shows it. Empty once the hero is gone. */
	public var className(get, never):String;

	public var level(get, never):UInt;

	/** Equipped weapons by slot, empty slots left out. A copy. */
	public var weapons(get, never):Array<ModWeapon>;

	var hero:HeroGameObject;

	@:allow(modding.Host)
	function new(hero:HeroGameObject, local:Bool, player:Null<ModPlayer>) {
		this.hero = hero;
		this.local = local;
		this.player = player;
		id = hero.id;
	}

	/** At `heroDespawned`, before its handlers: the player keeps what was last read, fields read empty from there on. */
	@:allow(modding.Host)
	function detach():Void {
		if (player != null && player.hero == this)
			player.setHero(null);
		hero = null;
	}

	/** The game object while it is still there. */
	function live():Null<HeroGameObject> {
		return hero != null && !hero.isDestroyed ? hero : null;
	}

	function get_classId():UInt {
		var live = live();
		return live == null ? 0 : live.type;
	}

	function get_className():String {
		var live = live();
		var gm = live == null ? null : live.gMHero;
		return gm == null || gm.Name == null ? "" : gm.Name;
	}

	function get_level():UInt {
		var live = live();
		return live == null ? 0 : live.level;
	}

	function get_weapons():Array<ModWeapon> {
		var out:Array<ModWeapon> = [];
		var live = live();
		var facade = Host.facade;
		if (live == null || facade == null || facade.gameMaster == null)
			return out;
		var details = @:privateAccess live.mWeaponDetails;
		if (details == null)
			return out;
		for (slot in 0...details.length) {
			var detail = details[slot];
			if (detail == null || detail.type == 0)
				continue;
			var item:GMWeaponItem = cast facade.gameMaster.weaponItemById.itemFor(detail.type);
			var name = "";
			if (item != null) {
				var aesthetic = item.getWeaponAesthetic(detail.requiredlevel, detail.legendarymodifier > 0);
				name = aesthetic != null ? GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME", aesthetic.Constant) : item.Name;
			}
			var rarity:GMRarity = cast facade.gameMaster.rarityById.itemFor(detail.rarity);
			var color:UInt = rarity != null && rarity.TextColor != 0 ? rarity.TextColor : 15463921;
			out.push(new ModWeapon(slot, detail.type, name == null ? "" : name, detail.power, detail.requiredlevel,
				rarity == null || rarity.Constant == null ? "" : rarity.Constant, color, detail.rarity, detail.modifier1, detail.modifier2,
				detail.legendarymodifier));
		}
		return out;
	}
}
