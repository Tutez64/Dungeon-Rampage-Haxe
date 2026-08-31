package distributedObjects;

import account.StackableInfo;
import actor.ActorGameObject;
import actor.player.HeroOwnerView;
import actor.player.InputController;
import box2D.dynamics.B2Body;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.render.Layer;
import brain.utils.MemoryTracker;
import brain.workLoop.Task;
import camera.FollowTargetCameraStrategy;
import combat.attack.PlayerOwnerAttackController;
import combat.attack.TavernPlayerOwnerAttackController;
import combat.weapon.WeaponController;
import combat.weapon.WeaponGameObject;
import dungeon.NavCollider;
import dungeon.Tile;
import events.HpEvent;
import events.ManaEvent;
import facade.DBFacade;
import dr_floor.FloorObject;
import dr_floor.FloorView;
import gameMasterDictionary.GMAttack;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;
import generatedCode.HeroGameObjectOwnerNetworkComponent;
import generatedCode.IHeroGameObjectOwner;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import org.as3commons.collections.Map;
import org.as3commons.collections.Set;
import org.as3commons.collections.framework.IMapIterator;

class HeroGameObjectOwner extends HeroGameObject implements IHeroGameObjectOwner {
	public static inline final BROADCAST_INTERVAL:Float = 0.2;

	public static inline final DEFAULT_CAMERA_ZOOM:Float = 1;

	public static inline final CAMERA_ZOOM_DELTA:Float = 0.05;

	public static inline final CAMERA_ZOOM_TWEEN_DURATION:Float = 0.5;

	public static inline final COLLISION_CIRCLE_RADIUS:Float = 20;

	public static var HERO_OWNER_READY:String = "HERO_OWNER_READY";

	public static var currentHeroOwnerId:UInt = (0 : UInt);

	static inline final FOLLOW_NEXT_ALLY_KEYCODE = 32;

	var mBroadcastTask:Task;

	var mInputTask:Task;

	var mVisibleTiles:Vector<Tile>;

	var mFollowCamera:FollowTargetCameraStrategy;

	var mButtonsDown:Set;

	var mPlayerOwnerAttackController:PlayerOwnerAttackController;

	var mHeroGameObjectOwnerNetworkComponent:HeroGameObjectOwnerNetworkComponent;

	var mCurrentWeaponIndex:Int = -1;

	var mBroadcastLastPosition:Vector3D = new Vector3D();

	var mBroadcastLastHeading:Float = 0;

	var mInputHeading:Float = 0;

	var mInputController:InputController;

	public var autoAimEnabled:Bool = false;

	public var actorClickedToAttack:ActorGameObject;

	var mInputVelocity:Vector3D;

	public var autoMoveVelocity:Vector3D;

	var mEventComponent:EventComponent;

	var mFromNetAttackChoreography:AttackChoreography;

	var mCanSuffer:Bool = false;

	var mSelectedTargets:Map;

	var mCurrentAttemptedRevivee:HeroGameObject;

	public var mTeleportDestination:Vector3D;

	public function new(dbFacade:DBFacade, remoteId:UInt) {
		Logger.debug("New  HeroGameObjectOwner******************************");
		super(dbFacade, remoteId);
		mWantNavCollisions = true;
		mVisibleTiles = new Vector<Tile>();
		mButtonsDown = new Set();
		mEventComponent = new EventComponent(dbFacade);
		mInputController = new InputController(this, dbFacade);
		MemoryTracker.track(mInputController, "InputController - created in HeroGameObjectOwner.constructor()");
		mInputVelocity = new Vector3D(0, 0, 0);
		autoMoveVelocity = new Vector3D(0, 0, 0);
		HeroGameObjectOwner.currentHeroOwnerId = this.id;
		autoAimEnabled = true;
		mCanSuffer = true;
		actorClickedToAttack = null;
	}

	override public function get_isOwner():Bool {
		return true;
	}

	public function clearWeaponInput() {
		mPlayerOwnerAttackController.clearInput();
	}

	@:isVar public var weaponControllers(get, never):Vector<WeaponController>;

	public function get_weaponControllers():Vector<WeaponController> {
		return mPlayerOwnerAttackController.weaponControllers;
	}

	override function buildView() {
		var _loc1_ = new HeroOwnerView(mDBFacade, this);
		MemoryTracker.track(_loc1_, "HeroOwnerView - created in HeroGameObjectOwner.buildView()");
		view = _loc1_;
	}

	override public function set_view(actorView:FloorView):FloorView {
		return super.view = actorView;
	}

	override public function addNavCollision(value:NavCollider) {
		value.type = B2Body.b2_dynamicBody;
		super.addNavCollision(value);
	}

	public override function set_canSuffer(has:Bool):Bool {
		return mCanSuffer = has;
	}

	override public function get_canSuffer():Bool {
		return mCanSuffer;
	}

	override function initializeToFirstValidWeapon() {
		var _loc3_:WeaponController = null;
		var _loc1_:WeaponGameObject = null;
		var _loc2_ = 0;
		if (weaponControllers.length > 0) {
			_loc2_ = 0;
			while (_loc2_ < weaponControllers.length) {
				_loc3_ = weaponControllers[_loc2_];
				if (_loc3_ != null) {
					_loc1_ = _loc3_.weapon;
					if (_loc1_ != null) {
						mCurrentWeaponIndex = _loc2_;
						this.currentWeapon = _loc1_;
						return;
					}
				}
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
		}
	}

	public function startUserInput() {
		mBroadcastTask = mLogicalWorkComponent.doEverySeconds(0.2, broadcastTelemetry);
		mInputController.init();
		mInputTask = mLogicalWorkComponent.doEveryFrame(inputUpCall);
	}

	function inputUpCall(gameClock:GameClock) {
		mInputController.perFrameUpCall();
	}

	public function stopUserInput() {
		mInputController.stop();
		mInputTask.destroy();
		mInputTask = null;
	}

	override public function init() {
		super.init();
		mDBFacade.camera.targetObject = mDBFacade.sceneGraphManager.worldTransformNode;
		mDBFacade.sceneGraphManager.worldTransformNode.parent.x = mDBFacade.viewWidth * 0.5;
		mDBFacade.sceneGraphManager.worldTransformNode.parent.y = mDBFacade.viewHeight * 0.5;
		mDBFacade.camera.defaultZoom = 1;
		mDBFacade.camera.zoom = mDBFacade.camera.defaultZoom;
		mDBFacade.camera.centerCameraOnPoint(position);
		mFollowCamera = new FollowTargetCameraStrategy(mDBFacade.camera, mHeroView.root);
		MemoryTracker.track(mFollowCamera, "FollowTargetCameraStrategy - created in HeroGameObjectOwner.init()");
		mFollowCamera.start(mPreRenderWorkComponent);
		autoAimEnabled = true;
		actorClickedToAttack = null;
		mPreRenderWorkComponent.doEveryFrame(this.doVisibility);
		mDBFacade.hud.initializeHud(this);
		mDBFacade.stageRef.addEventListener("keyDown", this.debugKey, false, 0, true);
		Logger.debug(" Sending HERO_OWNER_READY ");
		mEventComponent.dispatchEvent(new Event(HERO_OWNER_READY));
		if (this.actorData.movment > 250) {
			mDBFacade.iamaCheater("test_fbcheats");
		}
	}

	function debugKey(event:KeyboardEvent) {
		var _loc7_:Layer = null;
		var _loc3_ = false;
		var _loc2_:IMapIterator = null;
		var _loc5_:HeroGameObject = null;
		var _loc8_ = mDBFacade.dbConfigManager.getConfigString("test_effect_swf", "");
		var _loc6_ = mDBFacade.dbConfigManager.getConfigString("test_effect_name", "");
		var _loc4_:FloorObject = this;
		switch (event.keyCode) {
			case 98:
				_loc7_ = mDBFacade.sceneGraphManager.getLayer(50);
				_loc3_ = !_loc7_.visible;
				_loc7_.visible = _loc3_;
				if (actorNametag != null) {
					actorNametag.visible = _loc3_;
				}
				_loc2_ = ASCompat.reinterpretAs(distributedDungeonFloor.remoteHeroes.iterator(), IMapIterator);
				while (_loc2_.hasNext()) {
					_loc5_ = ASCompat.dynamicAs(_loc2_.next(), distributedObjects.HeroGameObject);
					_loc5_.actorNametag.visible = _loc3_;
				}

			case 69:
				if (ASCompat.stringAsBool(_loc8_) && ASCompat.stringAsBool(_loc6_) && distributedDungeonFloor != null) {
					distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(_loc8_), _loc6_,
						new Vector3D(Math.random() * 100, Math.random() * 100, 0), _loc4_);
				}
		}
	}

	@:isVar public var visibleTiles(get, never):Vector<Tile>;

	public function get_visibleTiles():Vector<Tile> {
		return mVisibleTiles;
	}

	function doVisibility(gameClock:GameClock) {
		var __ax4_iter_214:Vector<Tile>;
		var _loc3_:Rectangle = null;
		var _loc2_:Vector<Tile> = /*undefined*/ null;
		var _loc4_:Tile = null;
		if (mDistributedDungeonFloor != null && mDistributedDungeonFloor.tileGrid != null) {
			_loc3_ = mFacade.camera.visibleRectangle;
			_loc2_ = mDistributedDungeonFloor.tileGrid.getVisibleTiles(_loc3_);
			__ax4_iter_214 = mVisibleTiles;
			if (checkNullIteratee(__ax4_iter_214))
				for (_tmp_ in __ax4_iter_214) {
					_loc4_ = _tmp_;
					if (ASCompat.toNumber(_loc2_.indexOf(_loc4_)) < 0) {
						_loc4_.removeFromStage();
					}
				}
			if (checkNullIteratee(_loc2_))
				for (_tmp_ in _loc2_) {
					_loc4_ = _tmp_;
					if (mVisibleTiles.indexOf(_loc4_) < 0) {
						_loc4_.addToStage();
					}
				}
			mVisibleTiles = _loc2_;
		}
	}

	@:isVar var canMoveXY(get, never):Bool;

	function get_canMoveXY():Bool {
		return this.mMovementController.canMoveXY && !mFacade.inputManager.check(16);
	}

	@:isVar public var inputVelocity(never, set):Vector3D;

	public function set_inputVelocity(val:Vector3D):Vector3D {
		return mInputVelocity = val;
	}

	@:isVar public var inputHeading(get, set):Float;

	public function set_inputHeading(angle:Float):Float {
		return mInputHeading = angle;
	}

	function get_inputHeading():Float {
		return mInputHeading;
	}

	override function move() {
		this.actorView.position = this.position;
		this.actorView.heading = this.heading;
	}

	public function broadcastTelemetry(gameClock:GameClock = null) {
		if (Vector3D.distance(mBroadcastLastPosition, position) > 0.5) {
			mHeroGameObjectOwnerNetworkComponent.send_position(position);
			mBroadcastLastPosition = position;
		}
		if (mBroadcastLastHeading != heading) {
			mHeroGameObjectOwnerNetworkComponent.send_heading(heading);
			mBroadcastLastHeading = heading;
		}
	}

	public function getNextFramePosition():Vector3D {
		var _loc1_ = this.position;
		_loc1_.x += this.actorView.velocity.x * 0.04;
		_loc1_.y += this.actorView.velocity.y * 0.04;
		return _loc1_;
	}

	override function setupWeapons() {
		if (mPlayerOwnerAttackController != null) {
			mPlayerOwnerAttackController.destroy();
		}
		super.setupWeapons();
		var _loc1_ = mDistributedDungeonFloor.gmMapNode.NodeType == "TAVERN";
		if (_loc1_) {
			mPlayerOwnerAttackController = new TavernPlayerOwnerAttackController(this, mHeroView, mDBFacade);
			MemoryTracker.track(mPlayerOwnerAttackController, "TavernPlayerOwnerAttackController - created in HeroGameObjectOwner.setupWeapons()");
		} else {
			mPlayerOwnerAttackController = new PlayerOwnerAttackController(this, mHeroView, mDBFacade);
			MemoryTracker.track(mPlayerOwnerAttackController, "PlayerOwnerAttackController - created in HeroGameObjectOwner.setupWeapons()");
		}
		initializeToFirstValidWeapon();
	}

	@:isVar public var currentWeaponRange(get, never):UInt;

	public function get_currentWeaponRange():UInt {
		Logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TODO!!!!!!!!!!!!!!!!!!!!!111: Make this make sense with the new weaponControllers code!");
		return mPlayerOwnerAttackController.weaponControllers[mCurrentWeaponIndex].weaponRange;
	}

	public function setViewVelocity() {
		this.mHeroView.velocity = mInputVelocity.add(autoMoveVelocity);
		this.navCollisions[0].velocity = this.mHeroView.velocity;
	}

	override public function set_movementControllerType(value:String):String {
		super.movementControllerType = value;
		if (!canMoveXY) {
			mInputVelocity.scaleBy(0);
		}
		return value;
	}

	public function forceHeading(tv:Vector3D) {
		tv.normalize();
		var _loc2_ = Math.atan2(tv.y, tv.x) * 180 / 3.141592653589793;
		this.heading = _loc2_;
		this.mHeroView.heading = _loc2_;
	}

	public function placeAt(pos:Vector3D) {
		mMovementController.stopLerp();
		position = pos;
		mInputVelocity.x = 0;
		mInputVelocity.y = 0;
		this.navCollisions[0].position = pos;
		this.navCollisions[0].velocity = mInputVelocity;
		mMovementController.move(pos, this.heading);
		mInputVelocity.x = 0;
		mInputVelocity.y = 0;
	}

	public function setTeleDest(pos:Vector3D) {
		mTeleportDestination = pos;
	}

	public function doAttackOnHit(newAttack:String, weaponFromAttack:WeaponGameObject) {
		var _loc3_:WeaponController;
		final __ax4_iter_215 = weaponControllers;
		if (checkNullIteratee(__ax4_iter_215))
			for (_tmp_ in __ax4_iter_215) {
				_loc3_ = _tmp_;
				if (_loc3_ != null && _loc3_.weapon == weaponFromAttack) {
					_loc3_.queueAttack(newAttack);
					_loc3_.doQueue();
				}
			}
	}

	public function moveBodyTo(cameraPos:Vector3D) {
		mMovementController.moveBody(cameraPos, this.heading);
	}

	public function stopMovement() {
		mMovementController.stopLerp();
	}

	public function moveToTeleDest() {
		mMovementController.stopLerp();
		position = mTeleportDestination;
		this.navCollisions[0].position = mTeleportDestination;
		this.navCollisions[0].velocity = mInputVelocity;
		mMovementController.move(mTeleportDestination, this.heading);
	}

	override public function set_position(pos:Vector3D):Vector3D {
		return super.position = pos;
	}

	@:isVar public var currentWeaponIndex(get, set):Int;

	public function set_currentWeaponIndex(val:Int):Int {
		mCurrentWeaponIndex = val;
		if (weaponControllers[mCurrentWeaponIndex] != null && weaponControllers[mCurrentWeaponIndex].weapon != null) {
			this.currentWeapon = weaponControllers[mCurrentWeaponIndex].weapon;
			mDBFacade.hud.setWeaponHighlight(val);
		}
		return val;
	}

	function get_currentWeaponIndex():Int {
		return mCurrentWeaponIndex;
	}

	@:isVar public var PlayerAttack(get, never):PlayerOwnerAttackController;

	public function get_PlayerAttack():PlayerOwnerAttackController {
		return mPlayerOwnerAttackController;
	}

	@:isVar public var ActorClickedToAttack(never, set):ActorGameObject;

	public function set_ActorClickedToAttack(value:ActorGameObject):ActorGameObject {
		return actorClickedToAttack = value;
	}

	public function sendChat(message:String) {
		var _loc2_ = mFacade.gameObjectManager.getReferenceFromId(mPlayerID);
		var _loc3_ = ASCompat.reinterpretAs(_loc2_, PlayerGameObjectOwner);
		if (_loc3_ != null) {
			_loc3_.sendChat(message);
		}
	}

	public function showPlayerIsTyping(value:Bool) {
		var _loc2_ = mFacade.gameObjectManager.getReferenceFromId(mPlayerID);
		var _loc3_ = ASCompat.reinterpretAs(_loc2_, PlayerGameObjectOwner);
		if (_loc3_ != null) {
			_loc3_.sendPlayerIsTyping(value);
		}
	}

	override public function destroy() {
		mDBFacade.stageRef.removeEventListener("keyDown", this.debugKey);
		if (mPlayerOwnerAttackController != null) {
			mPlayerOwnerAttackController.destroy();
		}
		mVisibleTiles = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mDBFacade.hud.detachHero();
		mFollowCamera.destroy();
		mFollowCamera = null;
		mHeroGameObjectOwnerNetworkComponent = null;
		HeroGameObjectOwner.currentHeroOwnerId = (0 : UInt);
		mInputController.destroy();
		mInputController = null;
		mEventComponent.destroy();
		mEventComponent = null;
		super.destroy();
	}

	public function setOwnerNetworkComponentHeroGameObject(iface:HeroGameObjectOwnerNetworkComponent) {
		mHeroGameObjectOwnerNetworkComponent = iface;
	}

	public function sendChoreography(attackChoreography:AttackChoreography) {
		if (mFromNetAttackChoreography == null || mFromNetAttackChoreography.attack.attackType != attackChoreography.attack.attackType) {
			if (mHeroGameObjectOwnerNetworkComponent != null) {
				mHeroGameObjectOwnerNetworkComponent.send_ProposeAttackChoreography(attackChoreography);
			}
		}
	}

	public function sendStopChoreography() {
		StopChoreography();
		if (mHeroGameObjectOwnerNetworkComponent != null) {
			mHeroGameObjectOwnerNetworkComponent.send_StopChoreography();
		}
	}

	public function attemptRevive(revivee:HeroGameObject) {
		var _loc2_ = 0;
		mCurrentAttemptedRevivee = revivee;
		if (mDBFacade.dbConfigManager.getConfigBoolean("use_long_revive", true)) {
			_loc2_ = 910900;
		} else {
			_loc2_ = 910901;
		}
		attack((_loc2_ : UInt), revivee, 1, mAttemptReviveScript, this.stateMachine.enterNavigationState, sendStopChoreography);
	}

	public function proposeCombatResults(combatResults:Vector<CombatResult>) {
		if (mHeroGameObjectOwnerNetworkComponent != null) {
			mHeroGameObjectOwnerNetworkComponent.send_ProposeCombatResults(combatResults);
		}
	}

	public function proposeRevive() {
		if (mCurrentAttemptedRevivee != null && mCurrentAttemptedRevivee.isInReviveState()) {
			if (mHeroGameObjectOwnerNetworkComponent != null) {
				mHeroGameObjectOwnerNetworkComponent.send_ProposeRevive(mCurrentAttemptedRevivee.id);
			}
		}
	}

	public function proposeSelfRevive(isParty:UInt) {
		if (mHeroGameObjectOwnerNetworkComponent != null) {
			mHeroGameObjectOwnerNetworkComponent.send_ProposeSelfRevive(isParty);
		}
	}

	public function ProposeSelfRevive_Resp(yesno:UInt, isParty:UInt) {
		var _loc8_:UInt;
		var __tmpIncObj0:ASAny;
		var _loc6_:Map = null;
		var _loc5_:Array<ASAny> = null;
		var _loc7_ = 0;
		var _loc3_:StackableInfo = null;
		var _loc4_ = 0;
		if (yesno != 0) {
			_loc6_ = mDBFacade.dbAccountInfo.inventoryInfo.stackables;
			_loc5_ = _loc6_.keysToArray();
			_loc7_ = 60001;
			if (isParty != 0) {
				_loc7_ = 60018;
			}
			if (checkNullIteratee(_loc5_))
				for (_tmp_ in _loc5_) {
					_loc8_ = (ASCompat.toInt(_tmp_) : UInt);
					_loc3_ = ASCompat.dynamicAs(_loc6_.itemFor(_loc8_), account.StackableInfo);
					if (_loc3_.gmId == (_loc7_ : UInt)) {
						_loc4_ = ASCompat.toInt(_loc6_.itemFor(_loc8_).count);
						__tmpIncObj0 = _loc6_.itemFor(_loc8_);
						__tmpIncObj0.count = __tmpIncObj0.count - 1;
					}
				}
		} else {
			mEventComponent.dispatchEvent(new Event("purchaseReviveAll-failed"));
		}
	}

	public function ProposeCreateNPC(npcId:UInt, weaponSlot:UInt, x:Int, y:Int) {
		if (mHeroGameObjectOwnerNetworkComponent != null) {
			mHeroGameObjectOwnerNetworkComponent.send_ProposeCreateNPC(npcId, weaponSlot, x, y);
		}
	}

	@:isVar public var weaponRange(get, never):UInt;

	public function get_weaponRange():UInt {
		var _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(30), gameMasterDictionary.GMAttack);
		return (Std.int(_loc1_.Range) : UInt);
	}

	@:isVar public var inputController(get, never):InputController;

	public function get_inputController():InputController {
		return mInputController;
	}

	override public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) {
		super.ReceiveAttackChoreography(attackChoreography);
	}

	override public function set_state(value:String):String {
		super.state = value;
		if (value == "down") {
			if (Std.isOfType(this.view, HeroOwnerView)) {
				ASCompat.reinterpretAs(this.view, HeroOwnerView).stopHeartbeatSound();
			}
			this.mHeroView.velocity.scaleBy(0);
			this.navCollisions[0].velocity = this.mHeroView.velocity;
		}
		return value;
	}

	override public function setStateAndAttackChoreography(targetState:String, attackChoreography:AttackChoreography) {
		mFromNetAttackChoreography = attackChoreography;
		state = targetState;
		ReceiveAttackChoreography(attackChoreography);
		mFromNetAttackChoreography = null;
	}

	override public function ponderBuffChanges() {
		mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE", id, mMana, (Std.int(this.maxManaPoints) : UInt)));
		mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE", id, mHitPoints, (Std.int(this.maxHitPoints) : UInt)));
	}

	public function ReportBuffEffect(byWho:UInt, amount:Int, buffId:UInt, effectiveness:Int) {
		var _loc5_ = mDistributedDungeonFloor.getActor(byWho);
		if (_loc5_ != null) {
			if (amount < 0) {
				_loc5_.actorView.spawnDamageFloater(false, amount, true, true, effectiveness, buffId, "BUFF_DAMAGE_MOVEMENT_TYPE");
			} else {
				_loc5_.actorView.spawnHealFloater(amount, true, true, effectiveness, buffId, "BUFF_DAMAGE_MOVEMENT_TYPE");
			}
		}
	}

	public function ReceivedBuffEffect(amount:Int, buffId:UInt, effectiveness:Int) {
		if (amount < 0) {
			this.actorView.spawnDamageFloater(false, amount, true, true, effectiveness, buffId, "BUFF_DAMAGE_MOVEMENT_TYPE");
		} else {
			this.actorView.spawnHealFloater(amount, true, true, effectiveness, buffId, "BUFF_DAMAGE_MOVEMENT_TYPE");
		}
	}

	public function pauseMovement() {
		inputController.inputType = "lock_xy";
	}

	public function unPauseMovement() {
		inputController.inputType = "free";
	}

	public function TooFullForDoober(isHealthDoober:UInt) {
		if (isHealthDoober == ASCompat.toNumber(true)) {
			mDBFacade.hud.showHealthFullMessage();
		} else {
			mDBFacade.hud.showManaFullMessage();
		}
	}

	public function tryToUseConsumable(num:UInt) {
		mPlayerOwnerAttackController.tryToDoConsumableAttack(num);
	}

	public function startDeathCamInput() {
		mSelectedTargets = new Map();
		mDBFacade.stageRef.addEventListener("keyDown", checkDeathCamKeyEvent);
	}

	function checkDeathCamKeyEvent(kEvt:KeyboardEvent) {
		if (kEvt.keyCode == 32) {
			followNextAlly();
		}
	}

	public function stopDeathCamInput() {
		mDBFacade.stageRef.removeEventListener("keyDown", checkDeathCamKeyEvent);
		if (mSelectedTargets != null) {
			mSelectedTargets.clear();
		}
		mSelectedTargets = null;
		resetCamera();
	}

	public function followNextAlly() {
		var _loc2_:ActorGameObject = null;
		if (mSelectedTargets == null || mFollowCamera == null) {
			return;
		}
		if (mDistributedDungeonFloor == null || mDistributedDungeonFloor.remoteHeroes == null) {
			return;
		}
		var _loc3_:ActorGameObject = null;
		var _loc1_ = ASCompat.reinterpretAs(mDistributedDungeonFloor.remoteHeroes.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), ActorGameObject);
			if (!(_loc2_ == null || ASCompat.toBool(mSelectedTargets.itemFor(_loc2_)))) {
				_loc3_ = _loc2_;
				if (!(_loc3_.actorView == null || _loc3_.actorView.root == null)) {
					mFollowCamera.changeTarget(_loc3_.actorView.root);
				}
			}
		}
		if (_loc3_ == null) {
			mSelectedTargets.clear();
			resetCamera();
		} else {
			mSelectedTargets.add(_loc3_, true);
		}
	}

	public function resetCamera() {
		mFollowCamera.changeTarget(mHeroView.root);
	}
}
