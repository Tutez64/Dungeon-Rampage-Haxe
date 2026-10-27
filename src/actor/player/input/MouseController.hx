package actor.player.input;

import actor.ActorGameObject;
import actor.player.input.dBMouseEvents.MouseDownOnActorEvent;
import actor.player.input.dBMouseEvents.MouseOutOnActorEvent;
import actor.player.input.dBMouseEvents.MouseOverOnActorEvent;
import actor.player.input.dBMouseEvents.MouseUpOnActorEvent;
import brain.event.EventComponent;
import brain.logger.Logger;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import flash.events.MouseEvent;
import flash.geom.Vector3D;

class MouseController implements IMouseController {
	var mDBFacade:DBFacade;

	var mHeroGameObjectOwner:HeroGameObjectOwner;

	var mEventComponent:EventComponent;

	var mInputVelocity:Vector3D;

	var mInputHeading:Vector3D;

	var mMouseDownActorThisFrame:ActorGameObject;

	var mMouseUpActorThisFrame:ActorGameObject;

	var mMouseOverActorThisFrame:ActorGameObject;

	var mMouseOutActorThisFrame:ActorGameObject;

	var mMouseDownThisFrame:Bool = false;

	var mMouseUpThisFrame:Bool = false;

	var mMouseDownPosition:Vector3D;

	var mMouseUpPosition:Vector3D;

	var mRightMouseDown:Bool = false;

	var mMiddleMouseDown:Bool = false;

	var mDungeonBusterControlActivatedThisFrame:Bool = false;

	var mMouseDownActorPrevious:ActorGameObject;

	var mMouseUpActorPrevious:ActorGameObject;

	var mMouseOverActorPrevious:ActorGameObject;

	var mMouseOutActorPrevious:ActorGameObject;

	var mActorMousedOver:ActorGameObject;

	var mPotentialAttacksThisFrame:Array<ASAny>;

	var mCombatDisabled:Bool = false;

	public function new(dbFacade:DBFacade, heroOwner:HeroGameObjectOwner) {
		mDBFacade = dbFacade;
		mHeroGameObjectOwner = heroOwner;
		mEventComponent = new EventComponent(mDBFacade);
		mPotentialAttacksThisFrame = [];
		mInputVelocity = new Vector3D();
		mCombatDisabled = false;
	}

	function addListeners() {
		mEventComponent.addListener("MouseDownOnActorEvent", handleMouseDownOnActor);
		mEventComponent.addListener("MouseUpOnActorEvent", handleMouseUpOnActor);
		mEventComponent.addListener("MouseOverOnActorEvent", handleMouseOverOnActor);
		mEventComponent.addListener("MouseOutOnActorEvent", handleMouseOutOnActor);
		mEventComponent.addListener("DungeonBusterControlActivatedEvent", handleDungeonBusterControlActivated);
		mDBFacade.stageRef.addEventListener("mouseDown", handleMouseDown);
		mDBFacade.stageRef.addEventListener("mouseUp", handleMouseUp);
		mDBFacade.stageRef.addEventListener("rightMouseDown", handleRightMouseDown);
		mDBFacade.stageRef.addEventListener("rightMouseUp", handleRightMouseUp);
		mDBFacade.stageRef.addEventListener("middleMouseDown", handleMiddleMouseDown);
		mDBFacade.stageRef.addEventListener("middleMouseUp", handleMiddleMouseUp);
	}

	function removeListeners() {
		mEventComponent.removeAllListeners();
		mDBFacade.stageRef.removeEventListener("mouseDown", handleMouseDown);
		mDBFacade.stageRef.removeEventListener("mouseUp", handleMouseUp);
		mDBFacade.stageRef.removeEventListener("rightMouseDown", handleRightMouseDown);
		mDBFacade.stageRef.removeEventListener("rightMouseUp", handleRightMouseUp);
		mDBFacade.stageRef.removeEventListener("middleMouseDown", handleMiddleMouseDown);
		mDBFacade.stageRef.removeEventListener("middleMouseUp", handleMiddleMouseUp);
	}

	function handleMouseDownOnActor(mouseDownEvent:MouseDownOnActorEvent) {
		mMouseDownActorThisFrame = mouseDownEvent.actor;
	}

	function handleMouseUpOnActor(mouseUpEvent:MouseUpOnActorEvent) {
		mMouseUpActorThisFrame = mouseUpEvent.actor;
	}

	function handleMouseOverOnActor(mouseUpEvent:MouseOverOnActorEvent) {
		mMouseOverActorThisFrame = mouseUpEvent.actor;
		mActorMousedOver = mMouseOverActorThisFrame;
		if (mMouseOverActorThisFrame.actorView != null && mActorMousedOver.team != mHeroGameObjectOwner.team) {
			mMouseOverActorThisFrame.actorView.mouseOverHighlight();
		}
	}

	function handleMouseOutOnActor(mouseOutEvent:MouseOutOnActorEvent) {
		mMouseOutActorThisFrame = mouseOutEvent.actor;
		if (mMouseOutActorThisFrame.actorView != null && mMouseOutActorThisFrame.team != mHeroGameObjectOwner.team) {
			mMouseOutActorThisFrame.actorView.mouseOverUnhighlight();
		}
		if (mActorMousedOver == mMouseOutActorThisFrame) {
			mActorMousedOver = null;
		}
	}

	function handleDungeonBusterControlActivated(event:DungeonBusterControlActivatedEvent) {
		mDungeonBusterControlActivatedThisFrame = true;
	}

	function handleMouseUp(mouseUpEvent:MouseEvent) {
		mMouseUpThisFrame = true;
		mMouseDownPosition = new Vector3D(mouseUpEvent.stageX, mouseUpEvent.stageY);
	}

	function handleMouseDown(mouseDownEvent:MouseEvent) {
		mMouseDownThisFrame = true;
		mMouseDownPosition = new Vector3D(mouseDownEvent.stageX, mouseDownEvent.stageY);
	}

	function handleRightMouseDown(mouseDownEvent:MouseEvent) {
		mRightMouseDown = true;
	}

	function handleRightMouseUp(mouseDownEvent:MouseEvent) {
		mRightMouseDown = false;
	}

	function handleMiddleMouseDown(mouseDownEvent:MouseEvent) {
		mMiddleMouseDown = true;
	}

	function handleMiddleMouseUp(mouseDownEvent:MouseEvent) {
		mMiddleMouseDown = false;
	}

	@:isVar public var combatDisabled(never, set):Bool;

	public function set_combatDisabled(disableCombat:Bool):Bool {
		return mCombatDisabled = disableCombat;
	}

	public function perFrameUpCall() {
		mPotentialAttacksThisFrame.resize(0);
		determineSelection();
		if (!mCombatDisabled) {
			determineAttacks();
		}
		determineMotion();
		flushMouseEventVars();
	}

	function determineMotion() {
		Logger.error("determineMotion function is meant to be virtual and overriden by the subclasses.");
	}

	function determineAttacks() {
		Logger.error("determineAttacks function is meant to be virtual and overriden by the subclasses.");
	}

	function determineSelection() {
		Logger.error("determineSelection function is meant to be virtual and overriden by the subclasses.");
	}

	function flushMouseEventVars() {
		mMouseDownActorPrevious = mMouseDownActorThisFrame;
		mMouseUpActorPrevious = mMouseUpActorThisFrame;
		mMouseOverActorPrevious = mMouseOverActorThisFrame;
		mMouseOutActorPrevious = mMouseOutActorThisFrame;
		mMouseUpActorThisFrame = null;
		mMouseDownActorThisFrame = null;
		mMouseOverActorThisFrame = null;
		mMouseOutActorThisFrame = null;
		mMouseUpThisFrame = false;
		mMouseDownThisFrame = false;
		mDungeonBusterControlActivatedThisFrame = false;
		mMouseUpPosition = new Vector3D();
		mMouseDownPosition = new Vector3D();
	}

	public function move(inputType:String):Bool {
		Logger.error("move function is meant to be virtual and overriden by the subclasses.");
		return false;
	}

	public function init() {
		addListeners();
	}

	public function stop() {
		removeListeners();
	}

	public function clearMovement() {
		Logger.error("clearMovement is meant to be virtual and overriden by the subclasses.");
	}

	@:isVar public var potentialAttacksThisFrame(get, never):Array<ASAny>;

	public function get_potentialAttacksThisFrame():Array<ASAny> {
		return mPotentialAttacksThisFrame;
	}

	@:isVar public var inputVelocity(get, never):Vector3D;

	public function get_inputVelocity():Vector3D {
		return mInputVelocity;
	}

	@:isVar public var inputHeading(get, never):Vector3D;

	public function get_inputHeading():Vector3D {
		return mInputHeading;
	}

	public function destroy() {
		stop();
		mEventComponent.destroy();
		mEventComponent = null;
	}
}
