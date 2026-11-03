package actor;

import actor.buffs.BuffHandler;
import actor.stateMachine.ActorMacroStateMachine;
import box2D.dynamics.B2FilterData;
import brain.clock.GameClock;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.PreRenderWorkComponent;
import brain.workLoop.Task;
import combat.attack.AttackTimeline;
import combat.attack.ScriptTimeline;
import combat.weapon.WeaponGameObject;
import dBGlobals.DBGlobal;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObjectOwner;
import dungeon.Tile;
import events.HpEvent;
import facade.DBFacade;
import dr_floor.FloorObject;
import dr_floor.FloorView;
import gameMasterDictionary.GMAttack;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.StatVector;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;
import generatedCode.WeaponDetails;
import steamInput.RumbleEffect;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Vector3D;

class ActorGameObject extends FloorObject {
	public static inline final PROP_CHAR_TYPE = "PROP";

	public static inline final PET_CHAR_TYPE = "PET";

	static inline final SUFFER_TIMELINE_NAME = "GENERIC_STUN";

	static inline final GENERIC_SUFFER_KNOCKBACK = "GENERIC_SUFFER_KNOCKBACK";

	static inline final TELEPORT = "TELEPORT";

	public static inline final ATTEMPT_REVIVE_LONG_TIMELINE_NAME = "TM_ATTEMPT_REVIVE_LONG";

	static inline final ATTEMPT_REVIVE_LONG_ATTACK_ID = (910900 : UInt);

	static inline final RUMBLE_MIN_DAMAGE_SCALE:Float = 0.2;

	static inline final RUMBLE_MAX_DAMAGE_SCALE:Float = 2;

	static inline final RUMBLE_FULL_DAMAGE_FRACTION:Float = 0.8;

	static inline final PERSISTENT_HIDE_OFFSTAGE_GRACE_MS = 2000;

	static inline final RUN_HOLD_MS = 200;

	var mScreenName:String = "";

	var mHeading:Float = 0;

	var mActorView:ActorView;

	var mActorStateMachine:ActorMacroStateMachine;

	var mMovementController:MovementController;

	var mMouseEventHandler:MouseEventHandler;

	var mPreRenderWorkComponent:PreRenderWorkComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mRunIdleMonitorTask:Task;

	var mHitPoints:UInt = 0;

	var mShowHitFloater:Bool = false;

	var objPlayerDist:Int = 0;

	var mState:String;

	var mActorType:UInt = 0;

	var mActorData:ActorData;

	var mWeapons:Vector<WeaponGameObject>;

	var mWeaponDetails:Vector<WeaponDetails>;

	var mStats:StatVector;

	var mLevel:UInt = 0;

	public var buffHandler:BuffHandler;

	var mCurrentWeapon:WeaponGameObject;

	var mHasOwnership:Bool = false;

	var mTeam:Int = 0;

	var mFlip:UInt = (0 : UInt);

	var mSufferTimeline:ScriptTimeline;

	var mSufferKnockBackTimeline:ScriptTimeline;

	var mTeleportInTimeline:ScriptTimeline;

	var mTeleportOutTimeline:ScriptTimeline;

	var mAFK:Bool = false;

	var mPersistentHideAt:Int = -1;

	var mForceFlash:Bool = false;

	var mIsBlocking:Bool = false;

	var mMaximumDotForBlock:Float = -1.1;

	public var effectivenessShown:Bool = false;

	var mAttemptReviveScript:AttackTimeline;

	var mCanBeKnockedBack:Bool = true;

	var mLastMovingTime:Float = Math.NEGATIVE_INFINITY;

	var mOneShotHoldUntil:Int = 0;

	public function new(dbFacade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(dbFacade, remoteId);
		mStats = new StatVector();
		mTeam = 0;
		mAFK = false;
		mMovementController = new MovementController(this, mActorView, mDBFacade);
		mMouseEventHandler = new MouseEventHandler(this, mDBFacade);
		mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade, "ActorGameObject");
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "ActorGameObject");
		buildStateMachine();
		mLevel = (0 : UInt);
		this.layer = 20;
		buffHandler = new BuffHandler(dbFacade, this);
		mShowHitFloater = mDBFacade.dbConfigManager.getConfigBoolean("show_hit_floater", true);
	}

	@:isVar public var isOwner(get, never):Bool;

	public function get_isOwner():Bool {
		return false;
	}

	@:isVar public var belongsToRemotePlayer(get, never):Bool;

	public function get_belongsToRemotePlayer():Bool {
		return false;
	}

	@:isVar public var projectileLaunchOffset(get, never):Vector3D;

	public function get_projectileLaunchOffset():Vector3D {
		return new Vector3D(0, mActorData.gMActor.scaled_ProjEmitOffset);
	}

	override public function set_tile(value:Tile):Tile {
		if (value == mTile) {
			super.tile = value;
			return value;
		}
		if (mHasOwnership && mTile != null) {
			mTile.removeOwnedFloorObject(this);
		}
		super.tile = value;
		if (mHasOwnership && mTile != null) {
			mTile.addOwnedFloorObject(this);
		}
		return value;
	}

	@:isVar public var hasOwnership(never, set):Bool;

	public function set_hasOwnership(value:Bool):Bool {
		mHasOwnership = value;
		if (mHasOwnership) {
			if (this.tile != null) {
				this.tile.addOwnedFloorObject(this);
			}
		} else if (this.tile != null) {
			this.tile.removeOwnedFloorObject(this);
		}
		return value;
	}

	override public function newNetworkChild(child:GameObject) {}

	@:isVar public var isNavigable(get, never):Bool;

	public function get_isNavigable():Bool {
		return false;
	}

	@:isVar public var isAttackable(get, never):Bool;

	public function get_isAttackable():Bool {
		return true;
	}

	override public function init() {
		super.init();
		this.createNavCollisions(this.actorData.constant);
		mMouseEventHandler.Init();
		setupWeapons();
		initializeToFirstValidWeapon();
		if (mTile != null && mTile.isOnStage) {
			mActorView.addToStage();
		}
		determineState();
		var _loc2_ = this.actorData.gMActor.TeleportInTimeline;
		var _loc1_ = this.actorData.gMActor.TeleportOutTimeline;
		if (ASCompat.stringAsBool(_loc2_) && ASCompat.stringAsBool(_loc1_)) {
			mTeleportInTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc2_, this, mDistributedDungeonFloor);
			mTeleportOutTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc1_, this, mDistributedDungeonFloor);
		}
		if (mAttemptReviveScript == null) {
			mAttemptReviveScript = mDBFacade.timelineFactory.createAttackTimeline("TM_ATTEMPT_REVIVE_LONG", null, this, mDistributedDungeonFloor);
		}
	}

	@:isVar public var actorView(get, never):ActorView;

	public function get_actorView():ActorView {
		return mActorView;
	}

	@:isVar public var currentWeapon(get, set):WeaponGameObject;

	public function set_currentWeapon(weaponGameObject:WeaponGameObject):WeaponGameObject {
		mCurrentWeapon = weaponGameObject;
		if (mActorView != null) {
			if (weaponGameObject != null) {
				mActorView.currentWeapon = weaponGameObject.weaponView;
			} else {
				Logger.warn("Trying to equip a null weapon game object on actor.");
			}
		}
		return weaponGameObject;
	}

	function get_currentWeapon():WeaponGameObject {
		return mCurrentWeapon;
	}

	function buildStateMachine() {}

	@:isVar public var stateMachine(get, set):ActorMacroStateMachine;

	public function set_stateMachine(actorStateMachine:ActorMacroStateMachine):ActorMacroStateMachine {
		return mActorStateMachine = actorStateMachine;
	}

	function get_stateMachine():ActorMacroStateMachine {
		return mActorStateMachine;
	}

	@:isVar public var actorData(get, never):ActorData;

	public function get_actorData():ActorData {
		return mActorData;
	}

	@:isVar public var actorNametag(get, never):ActorNametag;

	public function get_actorNametag():ActorNametag {
		return mActorView.nametag;
	}

	override public function set_view(actorView:FloorView):FloorView {
		mActorView = ASCompat.reinterpretAs(actorView, ActorView);
		if (mCurrentWeapon != null) {
			mActorView.currentWeapon = mCurrentWeapon.weaponView;
		}
		return super.view = actorView;
	}

	@:isVar public var screenName(get, set):String;

	public function set_screenName(value:String):String {
		mScreenName = value;
		mActorView.screenName = screenName;
		return value;
	}

	@:isVar public var AFK(get, never):Bool;

	public function get_AFK():Bool {
		return mAFK;
	}

	function get_screenName():String {
		return mScreenName;
	}

	public function Chat(message:String) {
		mActorView.setChat(message);
	}

	public function ShowPlayerisTyping(value:Bool) {
		if (mActorView != null && mActorView.nametag != null) {
			mActorView.nametag.showPlayerIsTypingNotification(value);
		}
	}

	@:isVar public var maxHitPoints(get, never):Float;

	public function get_maxHitPoints():Float {
		return mStats.maxHitPoints * this.buffHandler.multiplier.maxHitPoints;
	}

	@:isVar public var attackCooldownMultiplier(get, never):Float;

	public function get_attackCooldownMultiplier():Float {
		return buffHandler.attackCooldownMultiplier;
	}

	@:isVar public var maxManaPoints(get, never):Float;

	public function get_maxManaPoints():Float {
		return mStats.maxManaPoints * this.buffHandler.multiplier.maxManaPoints;
	}

	@:isVar public var movementSpeed(get, never):Float;

	public function get_movementSpeed():Float {
		var _loc2_ = mStats.movementSpeed;
		var _loc3_ = this.buffHandler.multiplier.movementSpeed;
		return _loc2_ * _loc3_;
	}

	@:isVar public var heading(get, set):Float;

	public function get_heading():Float {
		return mHeading;
	}

	function set_heading(value:Float):Float {
		mHeading = value;
		this.move();
		return value;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		this.move();
		return pos;
	}

	function move() {
		mMovementController.move(mPosition, this.heading);
	}

	public function getHeadingAsVector(degreesOffset:Float = 0):Vector3D {
		var _loc4_ = new Vector3D();
		var _loc2_ = (heading + degreesOffset) * 3.141592653589793 / 180;
		var _loc5_ = Math.cos(_loc2_);
		var _loc3_ = Math.sin(_loc2_);
		return new Vector3D(_loc5_, _loc3_);
	}

	@:isVar public var movementControllerType(get, set):String;

	public function set_movementControllerType(value:String):String {
		return this.mMovementController.movementType = value;
	}

	function get_movementControllerType():String {
		return this.mMovementController.movementType;
	}

	@:isVar public var canMoveR(get, never):Bool;

	public function get_canMoveR():Bool {
		return this.mMovementController.canMoveR;
	}

	public function postGenerate() {
		mActorData = buildActorData();
		refreshStatVector();
		checkIfReadyForInit();
		mActorView.position = position;
	}

	function buildActorData():ActorData {
		return new ActorData(mDBFacade, this);
	}

	public function playEffectAtActor(effectPath:String, effectName:String, scale:Float, layer:String) {
		distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(effectPath), effectName, actorView.position, null, false, scale, 0, 0,
			0, 0, false, layer);
	}

	override public function destroy() {
		if (mTile != null && mTile.hasOwnedFloorObject(this)) {
			mTile.removeOwnedFloorObject(this);
		}
		if (mDistributedDungeonFloor != null) {
			mDistributedDungeonFloor.RemoveNetworkChild(this);
		}
		if (mSufferTimeline != null) {
			mSufferTimeline.destroy();
			mSufferTimeline = null;
		}
		if (mSufferKnockBackTimeline != null) {
			mSufferKnockBackTimeline.destroy();
			mSufferKnockBackTimeline = null;
		}
		if (mTeleportInTimeline != null) {
			mTeleportInTimeline.destroy();
			mTeleportInTimeline = null;
		}
		if (mTeleportOutTimeline != null) {
			mTeleportOutTimeline.destroy();
			mTeleportOutTimeline = null;
		}
		if (mAttemptReviveScript != null) {
			mAttemptReviveScript.destroy();
			mAttemptReviveScript = null;
		}
		mPosition = null;
		mMovementController.destroy();
		mMovementController = null;
		mMouseEventHandler.destroy();
		mMouseEventHandler = null;
		mPreRenderWorkComponent.destroy();
		mPreRenderWorkComponent = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		mActorStateMachine = null;
		mStats.destroy();
		mStats = null;
		buffHandler.destroy();
		buffHandler = null;
		mActorView = null;
		if (mActorData != null) {
			mActorData.destroy();
			mActorData = null;
		}
		mCurrentWeapon = null;
		mWeaponDetails = null;
		var _loc1_:WeaponGameObject;
		final __ax4_iter_12 = mWeapons;
		if (checkNullIteratee(__ax4_iter_12))
			for (_tmp_ in __ax4_iter_12) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		mWeapons = null;
		if (mRunIdleMonitorTask != null) {
			mRunIdleMonitorTask.destroy();
			mRunIdleMonitorTask = null;
		}
		super.destroy();
	}

	override public function set_distributedDungeonFloor(value:DistributedDungeonFloor):DistributedDungeonFloor {
		super.distributedDungeonFloor = value;
		checkIfReadyForInit();
		return value;
	}

	function checkIfReadyForInit() {
		if (mDistributedDungeonFloor != null && mActorData != null) {
			init();
		}
	}

	public function attack(attackType:UInt, targetActor:ActorGameObject, attackSpeedMultiplier:Float, attackTimeline:AttackTimeline,
			finishedCallback:ASFunction = null, stopCallback:ASFunction = null, loop:Bool = false, autoAim:Bool = false) {
		attackTimeline.currentAttackType = attackType;
		mActorStateMachine.enterChoreographyState(attackSpeedMultiplier, targetActor, attackTimeline, finishedCallback, stopCallback, loop, autoAim);
	}

	@:isVar public var hitPoints(get, set):UInt;

	public function set_hitPoints(val:UInt):UInt {
		mHitPoints = val;
		mActorView.setHp(mHitPoints, (ASCompat.floatToInt(this.maxHitPoints) : UInt));
		mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE", id, mHitPoints, (ASCompat.floatToInt(this.maxHitPoints) : UInt)));
		if (mHitPoints == 0 && this.actorData != null && this.isProp) {
			removeNavColliders();
		}
		return val;
	}

	function get_hitPoints():UInt {
		return mHitPoints;
	}

	@:isVar public var gmSkin(get, never):GMSkin;

	public function get_gmSkin():GMSkin {
		return null;
	}

	public function ReceiveAttackChoreography(attackChoreography:AttackChoreography) {
		var _loc4_ = Math.NaN;
		var _loc5_:ActorGameObject = null;
		var _loc2_ = this.mWeaponDetails[attackChoreography.attack.weaponSlot];
		var _loc3_:WeaponGameObject = null;
		if (_loc2_.type != 0) {
			_loc3_ = getWeaponForId(_loc2_.type);
			if (_loc3_ == null) {
				Logger.error("Weapon type: " + _loc2_.type + " on incoming attackChoreography does not match any weapon type currently equipped on actor.");
				return;
			}
			currentWeapon = _loc3_;
		} else {
			_loc3_ = currentWeapon;
		}
		var _loc6_ = ASCompat.coerce(mDBFacade.gameMaster.attackById.itemFor(attackChoreography.attack.attackType), gameMasterDictionary.GMAttack);
		if (_loc6_ == null) {
			Logger.error("Unable to find GMAttack for attacktype: " + attackChoreography.attack.attackType);
			return;
		}
		var _loc7_ = _loc3_.getAttackTimeline(_loc6_.Id);
		if (_loc7_ != null) {
			_loc4_ = attackChoreography.playSpeed;
			if (attackChoreography.attack.targetActorDoid != 0) {
				_loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(attackChoreography.attack.targetActorDoid), ActorGameObject);
			}
			mActorStateMachine.enterAttackChoreographyState(_loc4_, _loc5_, _loc7_, attackChoreography);
		}
	}

	public function ReceiveCombatResult(combatResult:CombatResult) {
		var _loc2_ = ASCompat.coerce(mDBFacade.gameMaster.attackById.itemFor(combatResult.attack.attackType), gameMasterDictionary.GMAttack);
		if (_loc2_ != null) {
			if (_loc2_.DamageMod > 0) {
				this.actorView.receiveHeal(combatResult, _loc2_);
			} else if (combatResult.blocked == 0) {
				this.actorView.receiveDamage(combatResult, _loc2_);
				receiveDamage(combatResult);
				playCombatRumble(combatResult);
			}
		}
	}

	function playCombatRumble(combatResult:CombatResult) {
		var _loc2_:RumbleEffect = null;
		var _loc3_ = HeroGameObjectOwner.currentHeroOwnerId;
		if (this.id == _loc3_) {
			_loc2_ = RumbleEffect.PLAYER_TAKING_DAMAGE.scaled(takingDamageRumbleScale(combatResult.damage));
			mDBFacade.steamInputManager.playRumble(_loc2_);
		} else if (combatResult.attacker == _loc3_) {
			mDBFacade.steamInputManager.playRumble(RumbleEffect.PLAYER_DEALING_DAMAGE);
		}
	}

	function takingDamageRumbleScale(damage:Int):Float {
		var _loc2_ = this.maxHitPoints;
		if (_loc2_ <= 0 || damage <= 0) {
			return 0.2;
		}
		var _loc3_ = damage / _loc2_ / 0.8;
		if (_loc3_ > 1) {
			_loc3_ = 1;
		}
		return 0.2 + (2 - 0.2) * _loc3_;
	}

	@:isVar public var canSuffer(get, set):Bool;

	public function get_canSuffer():Bool {
		return !this.hasAbility(DBGlobal.ABILITY_SUFFER_IMMUNITY);
	}

	@:isVar public var canBeKnockedBack(get, set):Bool;

	public function get_canBeKnockedBack():Bool {
		return mCanBeKnockedBack;
	}

	function set_canBeKnockedBack(val:Bool):Bool {
		return mCanBeKnockedBack = val;
	}

	function receiveDamage(combatResult:CombatResult) {
		if (isHeroType && combatResult.attacker != combatResult.attackee) {
			mMouseEventHandler.sendGotHitEvent();
		}
		var _loc2_:Float = 1;
		if (combatResult.knockback == 1 && canBeKnockedBack && (!isProp || canSuffer)) {
			if (mSufferKnockBackTimeline == null) {
				mSufferKnockBackTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_SUFFER_KNOCKBACK", this, mDistributedDungeonFloor);
			}
			mSufferKnockBackTimeline.currentAttackType = combatResult.attack.attackType;
			mActorStateMachine.enterCombatResultChoreographyState(_loc2_, null, mSufferKnockBackTimeline, combatResult,
				mDistributedDungeonFloor.getActor(combatResult.attacker));
		} else if (combatResult.suffer == 1 && canSuffer) {
			if (mSufferTimeline == null) {
				mSufferTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_STUN", this, mDistributedDungeonFloor);
			}
			mActorStateMachine.enterCombatResultChoreographyState(_loc2_, null, mSufferTimeline, combatResult,
				mDistributedDungeonFloor.getActor(combatResult.attacker));
		}
	}

	public function ReceiveTimelineAction(timelineAction:String) {
		if (mTeleportInTimeline != null && timelineAction == mTeleportInTimeline.attackName) {
			mActorStateMachine.enterChoreographyState(1, null, mTeleportInTimeline);
		}
		if (mTeleportOutTimeline != null && timelineAction == mTeleportOutTimeline.attackName) {
			mActorStateMachine.enterChoreographyState(1, null, mTeleportOutTimeline);
		}
	}

	function getWeaponForId(weaponType:UInt):WeaponGameObject {
		var _loc2_:WeaponGameObject;
		final __ax4_iter_13 = mWeapons;
		if (checkNullIteratee(__ax4_iter_13))
			for (_tmp_ in __ax4_iter_13) {
				_loc2_ = _tmp_;
				if (_loc2_ != null && _loc2_.weaponType == weaponType) {
					return _loc2_;
				}
			}
		return null;
	}

	@:isVar public var weapons(get, never):Vector<WeaponGameObject>;

	public function get_weapons():Vector<WeaponGameObject> {
		return mWeapons;
	}

	@:isVar public var type(get, set):UInt;

	public function set_type(value:UInt):UInt {
		return mActorType = value;
	}

	function get_type():UInt {
		return mActorType;
	}

	@:isVar public var isHeroType(get, never):Bool;

	public function get_isHeroType():Bool {
		if (mActorType > 100 && mActorType < 200) {
			return true;
		}
		return false;
	}

	@:isVar public var isProp(get, never):Bool;

	public function get_isProp():Bool {
		return this.actorData.gMActor.CharType == "PROP";
	}

	@:isVar public var isPet(get, never):Bool;

	public function get_isPet():Bool {
		return this.actorData.gMActor.CharType == "PET";
	}

	@:isVar public var usePetUI(get, never):Bool;

	public function get_usePetUI():Bool {
		return false;
	}

	@:isVar public var hasShowHealNumbers(get, never):Bool;

	public function get_hasShowHealNumbers():Bool {
		return false;
	}

	@:isVar public var state(never, set):String;

	public function set_state(value:String):String {
		if (mState != value) {
			mState = value;
			determineState();
		}
		return value;
	}

	@:isVar public var weaponDetails(never, set):Vector<WeaponDetails>;

	public function set_weaponDetails(val:Vector<WeaponDetails>):Vector<WeaponDetails> {
		mWeaponDetails = val;
		if (mActorData != null && mDistributedDungeonFloor != null) {
			setupWeapons();
			initializeToFirstValidWeapon();
		}
		return val;
	}

	function setupWeapons() {
		var _loc1_:WeaponGameObject;
		final __ax4_iter_14 = mWeapons;
		if (checkNullIteratee(__ax4_iter_14))
			for (_tmp_ in __ax4_iter_14) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		var _loc2_:Float = 0;
		mWeapons = new Vector<WeaponGameObject>();
		var _loc3_:WeaponDetails;
		final __ax4_iter_15 = mWeaponDetails;
		if (checkNullIteratee(__ax4_iter_15))
			for (_tmp_ in __ax4_iter_15) {
				_loc3_ = _tmp_;
				if (_loc3_.type != 0) {
					_loc1_ = new WeaponGameObject(_loc3_, this, mActorView, mDBFacade, mDistributedDungeonFloor, _loc2_);
					MemoryTracker.track(_loc1_, "WeaponGameObject - created in ActorGameObject.setupWeapons()");
					mWeapons.push(_loc1_);
				} else {
					mWeapons.push(null);
				}
				_loc2_++;
			}
		setupConsumables();
	}

	function setupConsumables() {}

	function initializeToFirstValidWeapon() {
		var _loc1_:WeaponGameObject = null;
		var _loc2_ = (0 : UInt);
		if (mWeapons.length > 0) {
			_loc2_ = (0 : UInt);
			while (_loc2_ < (mWeapons.length:UInt)) {
				_loc1_ = mWeapons[(_loc2_ : Int)];
				if (_loc1_ != null) {
					this.currentWeapon = _loc1_;
					break;
				}
				_loc2_++;
			}
		}
	}

	public function isDead():Bool {
		if (mActorStateMachine == null) {
			return false;
		}
		return mActorStateMachine.currentStateName == "ActorDeadState";
	}

	public function isInReviveState():Bool {
		if (mActorStateMachine == null) {
			return false;
		}
		return mActorStateMachine.currentStateName == "ActorReviveState";
	}

	public function localToGlobal(point:Point):Point {
		return mDBFacade.designLocalToGlobal(this.view.root, point);
	}

	public function globalToLocal(point:Point):Point {
		return this.view.root.globalToLocal(point);
	}

	public function hitTestObject(grobj:DisplayObject):Bool {
		return this.view.root.hitTestObject(grobj);
	}

	public function localCombatHit(combatResult:CombatResult) {
		mActorView.localCombatHit(combatResult);
	}

	@:isVar public var scale(never, set):Float;

	public function set_scale(val:Float):Float {
		this.view.root.scaleX = val;
		return this.view.root.scaleY = val;
	}

	@:isVar public var flip(get, set):UInt;

	public function set_flip(val:UInt):UInt {
		mFlip = val;
		if (mFlip != 0) {
			this.actorView.body.scaleX = -Math.abs(this.actorView.body.scaleX);
		}
		return val;
	}

	function get_flip():UInt {
		return mFlip;
	}

	@:isVar public var level(get, set):UInt;

	public function set_level(val:UInt):UInt {
		return mLevel = val;
	}

	function get_level():UInt {
		return mLevel;
	}

	@:isVar public var stats(get, set):StatVector;

	public function get_stats():StatVector {
		return mStats;
	}

	function set_stats(value:StatVector):StatVector {
		mStats = value;
		mActorView.setHp(mHitPoints, (ASCompat.floatToInt(this.maxHitPoints) : UInt));
		mDBFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE", id, mHitPoints, (ASCompat.floatToInt(this.maxHitPoints) : UInt)));
		return value;
	}

	function determineState() {
		if (this.actorData != null) {
			switch (mState) {
				case "dead":
					mActorStateMachine.enterDeadState(finishedDeathCallback);

				case "":
					mActorStateMachine.enterDefaultState();

				default:
					Logger.error("No case handled for state: " + mState + " for actorGameObject.");
			}
		}
	}

	function finishedDeathCallback(gameClock:GameClock = null) {
		if (mHasOwnership) {
			this.destroy();
		}
	}

	function refreshStatVector() {
		var _loc1_ = (0 : UInt);
		_loc1_ = (5 : UInt);
		var _loc4_ = mTeam == 5 ? mLevel : Math.pow(mLevel, 1.5);
		var _loc3_ = StatVector.add(mActorData.baseValues, StatVector.multiplyScalar(mActorData.levelValues, _loc4_));
		var _loc2_ = StatVector.add(StatVector.multiply(_loc3_, mDBFacade.gameMaster.stat_BonusMultiplier), mDBFacade.gameMaster.stat_bias);
		_loc2_.values[DBGlobal.HP_BOOST] = mActorData.hp + _loc2_.values[DBGlobal.HP_BOOST];
		_loc2_.values[DBGlobal.MP_BOOST] = mActorData.mp + _loc2_.values[DBGlobal.MP_BOOST];
		_loc2_.values[DBGlobal.MOVEMENT] = mActorData.gMActor.BaseMove + _loc2_.values[DBGlobal.MOVEMENT];
		stats = _loc2_;
	}

	override function buildFilter():B2FilterData {
		var _loc1_ = new B2FilterData();
		_loc1_.maskBits = 0;
		_loc1_.categoryBits = 0;
		_loc1_.categoryBits = _loc1_.categoryBits | (DBGlobal.b2dMaskForTeam((team : UInt)) : Int);
		if (!this.isNavigable) {
			_loc1_.maskBits = _loc1_.maskBits | (DBGlobal.B2D_ENVIRONMENT_MASK : Int);
			_loc1_.maskBits = _loc1_.maskBits | (DBGlobal.b2dMaskForAllTeamsBut((team : UInt)) : Int);
			if (this.actorData.gMActor.CollideWithTeam || this.isOwner) {
				_loc1_.maskBits = _loc1_.maskBits | (DBGlobal.b2dMaskForTeam((team : UInt)) : Int);
			}
		}
		if (actorData.gMActor.Species != "TRAP") {
			_loc1_.maskBits = _loc1_.maskBits | (DBGlobal.B2D_COMBAT_MASK : Int);
		}
		return _loc1_;
	}

	@:isVar public var team(get, set):Int;

	public function set_team(val:Int):Int {
		return mTeam = val;
	}

	function get_team():Int {
		return mTeam;
	}

	public function hasAbility(ability:UInt):Bool {
		return ((actorData.gMActor.Ability : Int) & (ability : Int)) != 0 || buffHandler.HasAbility(ability);
	}

	public function startRunIdleMonitoring() {
		if (mRunIdleMonitorTask == null) {
			mRunIdleMonitorTask = mPreRenderWorkComponent.doEveryFrame(runIdleMonitor);
		}
	}

	public function stopRunIdleMonitoring() {
		if (mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states")
			&& !isOwner
			&& flash.Lib.getTimer() - mLastMovingTime < 200
			&& mActorView != null
			&& mActorView.velocity.lengthSquared == 0
			&& mActorView.hasAnim("idle")) {
			mActorView.playAnim("idle");
		}
		mLastMovingTime = Math.NEGATIVE_INFINITY;
		mOneShotHoldUntil = 0;
		if (mRunIdleMonitorTask != null) {
			mRunIdleMonitorTask.destroy();
			mRunIdleMonitorTask = null;
		}
	}

	public function holdOneShotUntilMoving(seconds:Float) {
		mOneShotHoldUntil = seconds > 0 ? flash.Lib.getTimer() + ASCompat.floatToInt(seconds * 1000) : 0;
	}

	function runIdleMonitor(gameClock:GameClock) {
		if (hasAbandonedPersistentHide) {
			healAbandonedPersistentHide();
		}
		var _loc2_ = mActorView.bodyAnimRenderer;
		if (_loc2_ != null && _loc2_.isCulled) {
			if (mActorView.velocity.lengthSquared != 0) {
				mLastMovingTime = flash.Lib.getTimer();
			}
			return;
		}
		updateRunIdleAnim();
	}

	public function refreshRunIdleAnim() {
		if (mRunIdleMonitorTask != null) {
			updateRunIdleAnim();
		}
	}

	public function notePersistentHide() {
		mPersistentHideAt = flash.Lib.getTimer();
	}

	public function cancelPersistentHideWatch() {
		mPersistentHideAt = -1;
	}

	@:isVar public var persistentHidePending(get, never):Bool;

	public function get_persistentHidePending():Bool {
		return mPersistentHideAt >= 0;
	}

	@:isVar public var hasAbandonedPersistentHide(get, never):Bool;

	public function get_hasAbandonedPersistentHide():Bool {
		return mPersistentHideAt >= 0 && flash.Lib.getTimer() - mPersistentHideAt >= 2000;
	}

	public function healAbandonedPersistentHide() {
		mPersistentHideAt = -1;
		if (mHitPoints != 0 && mActorView != null && mActorView.root != null) {
			mActorView.root.visible = true;
		}
	}

	function updateRunIdleAnim() {
		if (this.actorData == null || this.actorData.gMActor == null) {
			return;
		}
		if (this.actorData.gMActor.CharType == "PROP") {
			return;
		}
		if (mOneShotHoldUntil != 0) {
			if (flash.Lib.getTimer() < mOneShotHoldUntil && mActorView.velocity.lengthSquared == 0) {
				return;
			}
			mOneShotHoldUntil = 0;
		}
		if (mActorView.velocity.lengthSquared == 0 || !mActorView.hasAnim("run")) {
			if (mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states")
				&& !isOwner
				&& flash.Lib.getTimer() - mLastMovingTime < 200
				&& mActorView.hasAnim("run")) {
				mActorView.playAnim("run");
				return;
			}
			mActorView.playAnim("idle");
		} else {
			mLastMovingTime = flash.Lib.getTimer();
			mActorView.playAnim("run");
		}
	}

	@:isVar public var setAFK(never, set):UInt;

	public function set_setAFK(flag:UInt):UInt {
		this.mAFK = flag != 0;
		mActorView.AFK = this.mAFK;
		return flag;
	}

	@:isVar public var forceFlash(get, set):Bool;

	public function get_forceFlash():Bool {
		return mForceFlash;
	}

	function set_forceFlash(value:Bool):Bool {
		return mForceFlash = value;
	}

	@:isVar public var isBlocking(get, set):Bool;

	public function get_isBlocking():Bool {
		return mIsBlocking;
	}

	function set_isBlocking(blocking:Bool):Bool {
		return mIsBlocking = blocking;
	}

	@:isVar public var maximumDotForBlocking(get, set):Float;

	public function get_maximumDotForBlocking():Float {
		return mMaximumDotForBlock;
	}

	function set_maximumDotForBlocking(value:Float):Float {
		return mMaximumDotForBlock = value;
	}

	public function ponderBuffChanges() {}

	function set_canSuffer(value:Bool):Bool {
		return value;
	}
}
