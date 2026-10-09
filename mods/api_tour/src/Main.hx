package mods.api_tour;

import mods.api.Mod;
import mods.api.Context;
import mods.api.Subscription;
import mods.api.account.Account;
import mods.api.account.OwnedHero;
import mods.api.dungeon.Floor;
import mods.api.dungeon.Hero;
import mods.api_tour.ui.Panel;

/**
 * Touches every member of the modding API and checks what docs/modding.md promises.
 * Each check logs `ok` or `FAIL`; the panel shows the totals and the last check.
 */
class Main extends Mod {
	var ctx:Context;

	var panel:Panel;

	var passed:Int = 0;

	var failed:Int = 0;

	var last:String = "";

	var tablesSeen:Bool = false;

	var readySeen:Bool = false;

	var cancelledCalls:Int = 0;

	var floorsEntered:Map<String, Bool> = new Map();

	var heroesSpawned:Int = 0;

	/** Heroes gone since the last check: they must read empty once their handlers are over. */
	var despawned:Array<Hero> = [];

	var keySeen:Bool = false;

	override public function init(ctx:Context):Void {
		this.ctx = ctx;
		panel = new Panel();
		ctx.overlay.addChild(panel.root);

		check("init: account empty", ctx.state.account == null);
		check("init: no floor", ctx.state.floor == null);
		check("init: no heroes", ctx.state.heroes.length == 0);

		var cancelled:Subscription = ctx.onTownEnter(function() cancelledCalls++);
		check("subscription starts active", cancelled.active);
		cancelled.cancel();
		cancelled.cancel();
		check("cancel deactivates, twice is harmless", !cancelled.active);

		var threw = false;
		try {
			ctx.onTownExit(null);
		} catch (e:Dynamic) {
			threw = true;
		}
		check("null handler is refused", threw);

		ctx.onTablesLoaded(function() {
			tablesSeen = true;
			check("tablesLoaded before ready", !readySeen);
		});
		ctx.onTownEnter(function() {
			check("townEnter after ready", readySeen);
			check("cancelled handler never ran", cancelledCalls == 0);
			check("town: no floor", ctx.state.floor == null);
			check("town: no players", ctx.state.players.length == 0);
			checkDespawned();
		});
		ctx.onTownExit(function() {
			check("townExit after ready", readySeen);
		});
		// A closure run long after it was made, once per return to town. One made the same way logged
		// a native handle instead of its message after a minute of play: its captures or its literal
		// were read from memory the GC had reused.
		ctx.onTownEnter(function() {
			var literal = "closure literal";
			check("closure keeps its captured argument", ctx == this.ctx);
			check("closure keeps its string literal", literal.length == 15 && literal.charAt(8) == "l");
		});
		ctx.onFloorEnter(onFloorEnter);
		ctx.onFloorExit(onFloorExit);
		ctx.onHeroSpawned(onHeroSpawned);
		ctx.onHeroDespawned(onHeroDespawned);
		// Never keeps a key: the game's own use of it must still happen.
		ctx.onKeyDown(function(key:UInt):Bool {
			if (!keySeen) {
				keySeen = true;
				check("keyDown: a key code", key > 0);
			}
			return false;
		});
	}

	override public function ready(ctx:Context):Void {
		readySeen = true;
		check("ready: tablesLoaded came first", tablesSeen);
		var account = ctx.state.account;
		check("ready: account filled", account != null);
		if (account != null) {
			check("ready: account id set", account.id != 0);
			check("activeAvatarId matches hasActiveAvatar", account.hasActiveAvatar == (account.activeAvatarId != 0));
			ctx.log("account " + account.id + ", active avatar " + account.activeAvatarId);
			checkInventory(account);
		}
		check("ready: no floor", ctx.state.floor == null);
		check("ready: view size set", ctx.viewWidth > 0 && ctx.viewHeight > 0);
		var copy = ctx.state.heroes;
		copy.push(null);
		check("state.heroes is a copy", ctx.state.heroes.length == copy.length - 1);
	}

	function checkInventory(account:Account):Void {
		var inventory = account.inventory;
		var heroes = inventory.heroes;
		var active = activeHero(account);
		check("inventory: active hero listed", !account.hasActiveAvatar || active != null);
		check("inventory: heroes have class and level", Lambda.foreach(heroes, hero -> hero.classId != 0 && hero.className != "" && hero.level > 0));
		check("inventory: equipped weapons in slots 0-2",
			Lambda.foreach(heroes, hero -> Lambda.foreach(hero.weapons, weapon -> weapon.slot >= 0 && weapon.slot <= 2)));
		var stored = inventory.weapons;
		check("inventory: stored weapons have slot -1 and a name", Lambda.foreach(stored, weapon -> weapon.slot == -1 && weapon.name != ""));
		check("inventory: weapon limit set", inventory.weaponLimit > 0);
		check("inventory: consumables have a name and a count", Lambda.foreach(inventory.consumables, stack -> stack.name != "" && stack.count > 0));
		check("inventory: pets have a name", Lambda.foreach(inventory.pets, pet -> pet.name != ""));
		stored.push(null);
		check("inventory.weapons is a copy", inventory.weapons.length == stored.length - 1);
		ctx.log("coins " + account.coins + ", gems " + account.gems + ", trophies " + account.trophies + ", " + heroes.length + " heroes, "
			+ (stored.length - 1) + "/" + inventory.weaponLimit + " weapons stored, " + inventory.pets.length + " pets, "
			+ inventory.consumables.length + " consumables");
	}

	function activeHero(account:Account):Null<OwnedHero> {
		for (hero in account.inventory.heroes)
			if (hero.id == account.activeAvatarId)
				return hero;
		return null;
	}

	override public function dispose():Void {
		if (ctx != null)
			ctx.log("dispose: " + passed + " ok, " + failed + " failed");
	}

	function onFloorEnter(floor:Floor):Void {
		floorsEntered.set(Std.string(floor.id), true);
		check("floorEnter: state.floor is this floor", ctx.state.floor == floor);
		check("floorEnter: number >= 1", floor.number >= 1);
		check("floorEnter: map set", floor.map != "");
		ctx.log("floor " + floor.id + " #" + floor.number + " " + floor.map);
	}

	function onFloorExit(floor:Floor):Void {
		check("floorExit: floor was entered", floorsEntered.exists(Std.string(floor.id)));
		check("floorExit: state.floor moved off it", ctx.state.floor != floor);
	}

	function onHeroSpawned(hero:Hero):Void {
		heroesSpawned++;
		checkDespawned();
		check("heroSpawned: after its floorEnter", ctx.state.floor != null);
		check("heroSpawned: in state.heroes", ctx.state.heroes.indexOf(hero) >= 0);
		check("heroSpawned: class and level set", hero.classId != 0 && hero.className != "" && hero.level > 0);
		var player = hero.player;
		check("heroSpawned: player set", player != null);
		if (player == null)
			return;
		check("player: account and name set", player.accountId != 0 && player.name != "");
		check("player: its hero is this one", player.hero == hero);
		check("player: local matches its hero", player.local == hero.local);
		check("player: in state.players", ctx.state.players.indexOf(player) >= 0);
		var weapons = hero.weapons;
		check("heroSpawned: at least one weapon", weapons.length > 0);
		weapons.push(null);
		check("hero.weapons is a copy", hero.weapons.length == weapons.length - 1);
		var account = ctx.state.account;
		var owned = hero.local && account != null ? activeHero(account) : null;
		if (owned != null) {
			check("local hero: class of the active owned hero", hero.classId == owned.classId);
			check("local hero: weapons of the active owned hero",
				owned.weapons.map(weapon -> weapon.slot + ":" + weapon.id).join(",") == hero.weapons.map(weapon -> weapon.slot + ":" + weapon.id).join(","));
		}
		// Social actions are left out on purpose: a test must not send a friend request, a block or a report.
		check("local player is no one to act on", !player.local || !player.addFriend());
		// Art is loaded and released by the sprites themselves; building and dropping them must not throw.
		var portrait = player.createPortrait(32);
		ctx.overlay.addChild(portrait);
		ctx.overlay.removeChild(portrait);
		if (weapons[0] != null) {
			var icon = weapons[0].createIcon(32);
			ctx.overlay.addChild(icon);
			ctx.overlay.removeChild(icon);
		}
		ctx.log("hero " + hero.id + " of " + player.accountId + " " + player.name + (hero.local ? " (local)" : "") + ", " + hero.className
			+ " lv " + hero.level + ", friend " + player.isFriend);
	}

	function onHeroDespawned(hero:Hero):Void {
		check("heroDespawned: out of state.heroes", ctx.state.heroes.indexOf(hero) < 0);
		check("heroDespawned: still read in its handlers", hero.classId != 0 && hero.className != "" && hero.level > 0);
		despawned.push(hero);
		var player = hero.player;
		if (player != null) {
			check("heroDespawned: player no longer on it", player.hero != hero);
			check("heroDespawned: player kept, name too", ctx.state.players.indexOf(player) >= 0 && player.name != "");
		}
	}

	function checkDespawned():Void {
		if (despawned.length == 0)
			return;
		check("heroDespawned: read empty after its handlers",
			Lambda.foreach(despawned, hero -> hero.classId == 0 && hero.className == "" && hero.level == 0 && hero.weapons.length == 0));
		despawned = [];
	}

	function check(label:String, ok:Bool):Void {
		if (ok)
			passed++;
		else
			failed++;
		last = (ok ? "ok   " : "FAIL ") + label;
		ctx.log(last);
		panel.show([
			"api_tour: " + passed + " ok, " + failed + " failed",
			"heroes seen: " + heroesSpawned + ", on floor now: " + ctx.state.heroes.length,
			last
		]);
	}
}
