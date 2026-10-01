package modding;

import brain.jsonRPC.JSONRPCService;
import distributedObjects.PresenceManager;
import events.FriendSummaryNewsFeedEvent;
import facade.DBFacade;
import facade.Locale;
import flash.display.Sprite;
import flash.text.TextFormat;
import uI.friendManager.UIFriendManager;
import uI.popup.DBUITwoButtonPopup;
import uI.popup.UIReportPopup;

/**
 * A player met in the dungeon in progress, the local one included. One instance per account from
 * its first hero until the return to town, kept after the player has left: `hero` is then null,
 * and the rest holds what was last read from their hero.
 *
 * `addFriend`, `block` and `report` act as the end screen does. Each returns false when there is
 * nobody to act on (the local player). `sent` runs once the server accepted, never on cancel or error.
 */
class ModPlayer {
	public var accountId(default, null):UInt;

	/** True for the local player. */
	public var local(default, null):Bool;

	/** Screen name. */
	public var name(get, never):String;

	/** The player's hero on the current floor; null between floors and once they have left. */
	public var hero(default, null):Null<ModHero>;

	/** Whether the local account has this player as a friend. */
	public var isFriend(get, never):Bool;

	/** Last values read from the player's hero, for the portrait and the report. */
	var knownName:String = "";

	var knownClass:UInt = 0;

	var knownExperience:UInt = 0;

	var knownSkin:UInt = 0;

	@:allow(modding.Host)
	function new(accountId:UInt, local:Bool) {
		this.accountId = accountId;
		this.local = local;
	}

	@:allow(modding.Host)
	@:allow(modding.ModHero)
	function setHero(value:Null<ModHero>):Void {
		remember();
		hero = value;
		remember();
	}

	/** Reads the current hero, if it is still there. */
	function remember():Void {
		var live = hero == null ? null : @:privateAccess hero.live();
		if (live == null)
			return;
		var value = live.screenName;
		if (value != null)
			knownName = value;
		knownClass = live.type;
		knownExperience = live.experiencePoints;
		knownSkin = live.skinType;
	}

	function get_name():String {
		remember();
		return knownName;
	}

	function get_isFriend():Bool {
		var facade = Host.facade;
		return facade != null && facade.dbAccountInfo != null && facade.dbAccountInfo.isFriend(accountId);
	}

	/**
	 * The player's picture, as on the end screen: the icon of their hero's skin, centred in a `size`
	 * square. Released when removed from its parent.
	 */
	public function createPortrait(size:Float):Sprite {
		remember();
		return ModArt.skinPortrait(knownSkin, size);
	}

	/** Sends a friend request, as the end screen does. */
	public function addFriend(?sent:Void->Void):Bool {
		var facade = actor();
		if (facade == null)
			return false;
		var info = facade.dbAccountInfo;
		var rpc = JSONRPCService.getFunction("DRFriendRequest", facade.rpcRoot + "friendrequests");
		var onError = UIFriendManager.createFriendRPCErrorCallback(facade, "modding addFriend");
		rpc(info.name, info.trophies, info.activeAvatarSkinId, info.facebookId, info.id, accountId, facade.demographics, facade.validationToken,
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
		var person = name;
		var popup = new DBUITwoButtonPopup(facade, Locale.getString("BLOCK") + " " + person + "?",
			person + Locale.getString("VICTORY_SCREEN_BLOCK_POPUP_MESSAGE"), Locale.getString("BLOCK"), function() {
				var rpc = JSONRPCService.getFunction("IgnoreFriend", facade.rpcRoot + "friendrequests");
				rpc(facade.dbAccountInfo.id, accountId, facade.validationToken, function(result:Dynamic) {
					if (answered(result))
						Host.callback(sent);
				});
			}, Locale.getString("CANCEL"), null);
		var format = new TextFormat();
		format.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
		popup.colorizeMessage(format, 0, person.length);
		return true;
	}

	/**
	 * Opens the game's report popup. The match lists the players with a hero on the floor, plus this
	 * one if they have left, close to the end screen's four slots.
	 */
	public function report(?sent:Void->Void):Bool {
		var facade = actor();
		if (facade == null)
			return false;
		var match:Array<Dynamic> = [];
		var listed = false;
		for (other in Host.knownPlayers()) {
			if (other.hero == null && other != this)
				continue;
			other.remember();
			if (other == this)
				listed = true;
			match.push({"accountId": other.accountId, "heroType": other.knownClass, "xp": other.knownExperience});
		}
		if (!listed)
			match.push({"accountId": accountId, "heroType": knownClass, "xp": knownExperience});
		new UIReportPopup(facade, name, accountId, cast match, function() {}, function(result:Dynamic) {
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
		var facade = Host.facade;
		if (local || facade == null || facade.dbAccountInfo == null || accountId == facade.dbAccountInfo.id)
			return null;
		return facade;
	}
}
