package mods.api_tour;

import modding.Mod;
import modding.ModContext;
import modding.ModFloor;
import modding.ModHero;
import modding.ModSubscription;
import modding.Version;
import mods.api_tour.ui.Panel;

/**
 * Touches every member of the modding API and checks what docs/modding.md promises.
 * Each check logs `ok` or `FAIL`; the panel shows the totals and the last check.
 */
class Main extends Mod {
	var ctx:ModContext;

	var panel:Panel;

	var passed:Int = 0;

	var failed:Int = 0;

	var last:String = "";

	var tablesSeen:Bool = false;

	var readySeen:Bool = false;

	var cancelledCalls:Int = 0;

	var floorsEntered:Map<String, Bool> = new Map();

	var heroesSpawned:Int = 0;

	var keySeen:Bool = false;

	override public function onInit(ctx:ModContext):Void {
		this.ctx = ctx;
		panel = new Panel();
		ctx.overlay.addChild(panel.root);
		ctx.log("modding api " + Version.API + ", drh " + Version.TAG);

		check("onInit: account empty", ctx.state.account == null);
		check("onInit: no floor", ctx.state.floor == null);
		check("onInit: no heroes", ctx.state.heroes.length == 0);

		var cancelled:ModSubscription = ctx.onTownEnter(function() cancelledCalls++);
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
			check("tablesLoaded before onReady", !readySeen);
		});
		ctx.onTownEnter(function() {
			check("townEnter after onReady", readySeen);
			check("cancelled handler never ran", cancelledCalls == 0);
			check("town: no floor", ctx.state.floor == null);
		});
		ctx.onTownExit(function() {
			check("townExit after onReady", readySeen);
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

	override public function onReady(ctx:ModContext):Void {
		readySeen = true;
		check("onReady: tablesLoaded came first", tablesSeen);
		var account = ctx.state.account;
		check("onReady: account filled", account != null);
		if (account != null) {
			check("onReady: account id set", account.id != 0);
			check("activeAvatarId matches hasActiveAvatar", account.hasActiveAvatar == (account.activeAvatarId != 0));
			ctx.log("account " + account.id + ", active avatar " + account.activeAvatarId);
		}
		check("onReady: no floor", ctx.state.floor == null);
		check("onReady: view size set", ctx.viewWidth > 0 && ctx.viewHeight > 0);
		var copy = ctx.state.heroes;
		copy.push(null);
		check("state.heroes is a copy", ctx.state.heroes.length == copy.length - 1);
	}

	override public function onDispose():Void {
		if (ctx != null)
			ctx.log("onDispose: " + passed + " ok, " + failed + " failed");
	}

	function onFloorEnter(floor:ModFloor):Void {
		floorsEntered.set(Std.string(floor.id), true);
		check("floorEnter: state.floor is this floor", ctx.state.floor == floor);
		check("floorEnter: number >= 1", floor.number >= 1);
		check("floorEnter: map set", floor.map != "");
		ctx.log("floor " + floor.id + " #" + floor.number + " " + floor.map);
	}

	function onFloorExit(floor:ModFloor):Void {
		check("floorExit: floor was entered", floorsEntered.exists(Std.string(floor.id)));
		check("floorExit: state.floor moved off it", ctx.state.floor != floor);
	}

	function onHeroSpawned(hero:ModHero):Void {
		heroesSpawned++;
		check("heroSpawned: after its floorEnter", ctx.state.floor != null);
		check("heroSpawned: name set", hero.name != "");
		check("heroSpawned: in state.heroes", ctx.state.heroes.indexOf(hero) >= 0);
		check("heroSpawned: account, hero and level set", hero.accountId != 0 && hero.heroId != 0 && hero.heroName != "" && hero.level > 0);
		var weapons = hero.weapons;
		check("heroSpawned: at least one weapon", weapons.length > 0);
		weapons.push(null);
		check("hero.weapons is a copy", hero.weapons.length == weapons.length - 1);
		// Social actions are left out on purpose: a test must not send a friend request, a block or a report.
		check("local hero is no one to act on", !hero.local || !hero.addFriend());
		// Art is loaded and released by the sprites themselves; building and dropping them must not throw.
		var portrait = hero.createPortrait(32);
		ctx.overlay.addChild(portrait);
		ctx.overlay.removeChild(portrait);
		if (weapons[0] != null) {
			var icon = weapons[0].createIcon(32);
			ctx.overlay.addChild(icon);
			ctx.overlay.removeChild(icon);
		}
		ctx.log("hero " + hero.id + " " + hero.name + (hero.local ? " (local)" : "") + ", " + hero.heroName + " lv " + hero.level
			+ ", friend " + hero.isFriend);
	}

	function onHeroDespawned(hero:ModHero):Void {
		check("heroDespawned: out of state.heroes", ctx.state.heroes.indexOf(hero) < 0);
		check("heroDespawned: live fields read empty", hero.accountId == 0 && hero.level == 0 && hero.weapons.length == 0);
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
