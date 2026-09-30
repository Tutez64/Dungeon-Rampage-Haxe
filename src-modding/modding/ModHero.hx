package modding;

import brain.jsonRPC.JSONRPCService;
import distributedObjects.HeroGameObject;
import distributedObjects.PresenceManager;
import events.FriendSummaryNewsFeedEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import flash.display.Sprite;
import flash.text.TextFormat;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMWeaponItem;
import uI.friendManager.UIFriendManager;
import uI.popup.DBUITwoButtonPopup;
import uI.popup.UIReportPopup;

/**
 * One hero in the world. Fields read the live object and go empty once it is gone.
 *
 * `addFriend`, `block` and `report` act on the player behind the hero, so they keep working
 * after the hero has left. Each returns false when there is nobody to act on (the local
 * player, or no account). `sent` runs once the server accepted, never on cancel or error.
 */
class ModHero {
	public var id(default, null):UInt;

	/** True for the local player, false for everyone else. */
	public var local(default, null):Bool;

	public var name(get, never):String;

	/** Account of the player behind the hero, 0 once the hero is gone. */
	public var accountId(get, never):UInt;

	/** GameMaster hero id, 0 once the hero is gone. */
	public var heroId(get, never):UInt;

	/** Display name of the hero class, empty once the hero is gone. */
	public var heroName(get, never):String;

	public var level(get, never):UInt;

	/** Equipped weapons by slot, empty slots left out. A copy. */
	public var weapons(get, never):Array<ModWeapon>;

	/** Whether the local account has this player as a friend. */
	public var isFriend(get, never):Bool;

	var hero:HeroGameObject;

	/** Last values read from the live hero, for the actions after it is gone. */
	var knownAccount:UInt = 0;

	var knownName:String = "";

	var knownHeroId:UInt = 0;

	var knownExperience:UInt = 0;

	var knownSkin:UInt = 0;

	@:allow(modding.Host)
	function new(hero:HeroGameObject, local:Bool) {
		this.hero = hero;
		this.local = local;
		id = hero.id;
		remember();
	}

	@:allow(modding.Host)
	function remember():Void {
		if (!alive())
			return;
		knownAccount = hero.playerID;
		var value = hero.screenName;
		if (value != null)
			knownName = value;
		knownHeroId = hero.type;
		knownExperience = hero.experiencePoints;
		knownSkin = hero.skinType;
	}

	/** At `heroDespawned`, before its handlers: fields read empty from there on, actions keep what was last read. */
	@:allow(modding.Host)
	function detach():Void {
		remember();
		hero = null;
	}

	function alive():Bool {
		return hero != null && !hero.isDestroyed;
	}

	function get_name():String {
		if (!alive())
			return "";
		var value = hero.screenName;
		return value == null ? "" : value;
	}

	function get_accountId():UInt {
		return alive() ? hero.playerID : 0;
	}

	function get_heroId():UInt {
		return alive() ? hero.type : 0;
	}

	function get_heroName():String {
		if (!alive())
			return "";
		var gm = hero.gMHero;
		return gm == null || gm.Name == null ? "" : gm.Name;
	}

	function get_level():UInt {
		return alive() ? hero.level : 0;
	}

	function get_weapons():Array<ModWeapon> {
		var out:Array<ModWeapon> = [];
		var facade = Host.facade;
		if (!alive() || facade == null || facade.gameMaster == null)
			return out;
		var details = @:privateAccess hero.mWeaponDetails;
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

	/**
	 * The player's picture, as on the end screen: the icon of the hero's skin, centred in a `size`
	 * square. Still drawn once the hero is gone. Released when removed from its parent.
	 */
	public function createPortrait(size:Float):Sprite {
		remember();
		return ModArt.skinPortrait(knownSkin, size);
	}

	function get_isFriend():Bool {
		remember();
		var facade = Host.facade;
		return facade != null && facade.dbAccountInfo != null && facade.dbAccountInfo.isFriend(knownAccount);
	}

	/** Sends a friend request, as the end screen does. */
	public function addFriend(?sent:Void->Void):Bool {
		var facade = actor();
		if (facade == null)
			return false;
		var info = facade.dbAccountInfo;
		var rpc = JSONRPCService.getFunction("DRFriendRequest", facade.rpcRoot + "friendrequests");
		var onError = UIFriendManager.createFriendRPCErrorCallback(facade, "modding addFriend");
		rpc(info.name, info.trophies, info.activeAvatarSkinId, info.facebookId, info.id, knownAccount, facade.demographics, facade.validationToken,
			function(result:Dynamic) {
				if (!answered(result))
					return;
				// As the end screen: [friends, request] once the other side had already asked.
				if (Std.isOfType(result, Array)) {
					var list:Array<Dynamic> = result;
					var ids = new flash.Vector<UInt>();
					ids.push(ASCompat.asUint(Reflect.field(list[1], "account_id")));
					PresenceManager.instance().addFriends(ids);
					facade.dbAccountInfo.addFriendCallback(list[0]);
				}
				Host.callback(sent);
			}, onError);
		return true;
	}

	/** Asks for confirmation with the game's popup, then blocks the player. */
	public function block(?sent:Void->Void):Bool {
		var facade = actor();
		if (facade == null)
			return false;
		var account = knownAccount;
		var person = knownName;
		var popup = new DBUITwoButtonPopup(facade, Locale.getString("BLOCK") + " " + person + "?",
			person + Locale.getString("VICTORY_SCREEN_BLOCK_POPUP_MESSAGE"), Locale.getString("BLOCK"), function() {
				var rpc = JSONRPCService.getFunction("IgnoreFriend", facade.rpcRoot + "friendrequests");
				rpc(facade.dbAccountInfo.id, account, facade.validationToken, function(result:Dynamic) {
					if (answered(result))
						Host.callback(sent);
				});
			}, Locale.getString("CANCEL"), null);
		var format = new TextFormat();
		format.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
		popup.colorizeMessage(format, 0, person.length);
		return true;
	}

	/** Opens the game's report popup, with every hero on the floor as the match. */
	public function report(?sent:Void->Void):Bool {
		var facade = actor();
		if (facade == null)
			return false;
		var match:Array<Dynamic> = [];
		var reportedListed = false;
		for (other in Host.knownHeroes()) {
			other.remember();
			if (other.knownAccount == 0)
				continue;
			if (other.knownAccount == knownAccount)
				reportedListed = true;
			match.push({"accountId": other.knownAccount, "heroType": other.knownHeroId, "xp": other.knownExperience});
		}
		if (!reportedListed)
			match.push({"accountId": knownAccount, "heroType": knownHeroId, "xp": knownExperience});
		new UIReportPopup(facade, knownName, knownAccount, cast match, function() {}, function(result:Dynamic) {
			if (answered(result))
				Host.callback(sent);
		});
		return true;
	}

	/**
	 * The end screen's test for a successful answer, kept as written: an object answer has no length,
	 * reads NaN, and passes.
	 */
	static function answered(result:Dynamic):Bool {
		return result != null && !(ASCompat.toNumberField(result, "length") <= 0);
	}

	/** The facade when there is someone else to act on, null otherwise. */
	function actor():Null<DBFacade> {
		remember();
		var facade = Host.facade;
		if (local || knownAccount == 0 || facade == null || facade.dbAccountInfo == null)
			return null;
		if (knownAccount == facade.dbAccountInfo.id)
			return null;
		return facade;
	}
}
