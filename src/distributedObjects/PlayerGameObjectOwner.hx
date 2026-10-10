package distributedObjects;

import brain.event.EventComponent;
import brain.logger.Logger;
import events.ChatEvent;
import events.GameObjectEvent;
import facade.DBFacade;
import generatedCode.IPlayerGameObjectOwner;
import generatedCode.PlayerGameObjectOwnerNetworkComponent;
import flash.events.Event;

class PlayerGameObjectOwner extends PlayerGameObject implements IPlayerGameObjectOwner {
	public static inline final REQUEST_ENTRY_PLAYER_FLOOR = "REQUEST_ENTRY_PLAYER_FLOOR";

	public static inline final REQUEST_ENTRY_PLAYER_HERO = "REQUEST_ENTRY_PLAYER_HERO";

	var mEventComponent:EventComponent;

	var mBasicCurrency:UInt = 0;

	var mPlayerGameObjectOwnerNetworkComponent:PlayerGameObjectOwnerNetworkComponent;

	public function new(dbFacade:DBFacade, remoteId:UInt = (0 : UInt)) {
		Logger.debug("New  PlayerGameObjectOwner******************************");
		super(dbFacade, remoteId);
		mBasicCurrency = (0 : UInt);
		mEventComponent = new EventComponent(dbFacade);
		mEventComponent.addListener("REQUEST_ENTRY_PLAYER_FLOOR", event_request_entry);
		mEventComponent.addListener("REQUEST_ENTRY_PLAYER_HERO", event_request_entry_hero);
		mEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_OUTGOING_CHAT_UPDATE", (0 : UInt)), this.handleOutgoingChat);
	}

	function event_request_entry_hero(e:Event) {
		Logger.debug(" Sending Request Hero");
		mPlayerGameObjectOwnerNetworkComponent.send_requesthero();
	}

	function event_request_entry(e:Event) {
		Logger.debug(" Sending Request Entry Floor");
		mPlayerGameObjectOwnerNetworkComponent.send_requestentry();
	}

	public function setOwnerNetworkComponentPlayerGameObject(iface:PlayerGameObjectOwnerNetworkComponent) {
		mPlayerGameObjectOwnerNetworkComponent = iface;
	}

	function handleOutgoingChat(event:ChatEvent) {
		var _loc2_ = this.screenName + ": " + event.message;
		this.sendChat(_loc2_);
	}

	public function sendChat(message:String) {
		this.Chat(message);
		mPlayerGameObjectOwnerNetworkComponent.send_Chat(message);
	}

	public function sendPlayerIsTyping(value:Bool) {
		if (value) {
			this.ShowPlayerIsTyping((1 : UInt));
			mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping((1 : UInt));
		} else {
			this.ShowPlayerIsTyping((0 : UInt));
			mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping((0 : UInt));
		}
	}

	override public function get_basicCurrency():UInt {
		return mBasicCurrency;
	}

	public override function set_basicCurrency(val:UInt):UInt {
		mBasicCurrency = val;
		if (mDBFacade.hud != null) {
			mDBFacade.hud.setBasicCurrency((mBasicCurrency : Int));
		}
		return val;
	}

	override public function destroy() {
		super.destroy();
		mEventComponent.destroy();
		mEventComponent = null;
	}
}
