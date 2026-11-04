package actor;

import actor.player.HeroOwnerView;
import actor.player.input.dBMouseEvents.MouseDownOnActorEvent;
import actor.player.input.dBMouseEvents.MouseOutOnActorEvent;
import actor.player.input.dBMouseEvents.MouseOverOnActorEvent;
import actor.player.input.dBMouseEvents.MouseUpOnActorEvent;
import brain.event.EventComponent;
import brain.event.EventListeners;
import facade.DBFacade;
import dr_floor.FloorView;
import flash.events.Event;
import flash.events.MouseEvent;

class MouseEventHandler {
	var mDBFacade:DBFacade;

	var mActorGameObject:ActorGameObject;

	var mEventComponent:EventComponent;

	var mWantsClicks:Bool = false;

	public function new(actorGameObject:ActorGameObject, dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mActorGameObject = actorGameObject;
		mEventComponent = new EventComponent(mDBFacade);
	}

	public function destroy() {
		removeListeners();
		mEventComponent.destroy();
		mEventComponent = null;
		mDBFacade = null;
		mActorGameObject = null;
	}

	public function Init() {
		addListeners();
	}

	@:isVar public var actorView(get, never):ActorView;

	public function get_actorView():ActorView {
		return mActorGameObject.actorView;
	}

	@:isVar public var floorView(get, never):FloorView;

	public function get_floorView():FloorView {
		return mActorGameObject.view;
	}

	@:isVar public var heroOwnerView(get, never):HeroOwnerView;

	public function get_heroOwnerView():HeroOwnerView {
		return ASCompat.reinterpretAs(mActorGameObject.actorView, HeroOwnerView);
	}

	function addListeners() {
		ActorMousePicker.unregister(this);
		mEventComponent.removeAllListeners();
		mActorGameObject.view.root.mouseEnabled = false;
		if (!mActorGameObject.isAttackable || mActorGameObject.isPet) {
			return;
		}
		if (mActorGameObject.navCollisions.length == 0) {
			return;
		}
		if (mActorGameObject.isHeroType && !mActorGameObject.isOwner) {
			return;
		}
		if (heroOwnerView != null && !heroOwnerView.wantMouseEnabled) {
			return;
		}
		mActorGameObject.view.root.mouseChildren = false;
		actorView.mousePickedCentrally = true;
		mWantsClicks = !mActorGameObject.isHeroType;
		ActorMousePicker.register(this, mDBFacade);
		EventListeners.add(actorView.root, "rollOver", onMouseOver);
		EventListeners.add(actorView.root, "rollOut", onMouseOut);
		if (mWantsClicks) {
			EventListeners.add(actorView.root, "mouseDown", onMouseDown);
			EventListeners.add(actorView.root, "mouseUp", onMouseUp);
		}
	}

	@:isVar public var wantsClicks(get, never):Bool;

	public function get_wantsClicks():Bool {
		return mWantsClicks;
	}

	@:isVar public var actorId(get, never):UInt;

	public function get_actorId():UInt {
		return mActorGameObject != null ? mActorGameObject.id : (0 : UInt);
	}

	function removeListeners() {
		ActorMousePicker.unregister(this);
		mEventComponent.removeAllListeners();
		EventListeners.remove(actorView.root, "rollOver", onMouseOver);
		EventListeners.remove(actorView.root, "rollOut", onMouseOut);
		EventListeners.remove(actorView.root, "mouseDown", onMouseDown);
		EventListeners.remove(actorView.root, "mouseUp", onMouseUp);
	}

	public function onMouseOver(event:MouseEvent) {
		mEventComponent.dispatchEvent(new MouseOverOnActorEvent(mActorGameObject));
	}

	public function onMouseOut(event:MouseEvent) {
		mEventComponent.dispatchEvent(new MouseOutOnActorEvent(mActorGameObject));
	}

	public function onMouseDown(event:MouseEvent) {
		mEventComponent.dispatchEvent(new MouseDownOnActorEvent(mActorGameObject));
	}

	public function onMouseUp(event:MouseEvent) {
		mEventComponent.dispatchEvent(new MouseUpOnActorEvent(mActorGameObject));
	}

	public function sendGotHitEvent() {
		mEventComponent.dispatchEvent(new Event("GotHit_" + mActorGameObject.id));
	}
}
