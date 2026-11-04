package distributedObjects;

import actor.ActorData;
import actor.ActorGameObject;
import actor.DamageCurve;
import actor.HeroData;
import actor.player.HeroStateMachine;
import actor.player.HeroView;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import combat.attack.AttackTimeline;
import combat.weapon.ConsumableWeaponGameObject;
import dBGlobals.DBGlobal;
import events.BusterPointsEvent;
import events.ExperienceEvent;
import events.GameObjectEvent;
import events.HpEvent;
import events.LevelUpPostEvent;
import events.ManaEvent;
import facade.DBFacade;
import facade.Locale;
import dr_floor.FloorMessageView;
import dr_floor.FloorView;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.GMSuperStat;
import gameMasterDictionary.StatVector;
import generatedCode.AttackChoreography;
import generatedCode.ConsumableDetails;
import generatedCode.HeroGameObjectNetworkComponent;
import generatedCode.IHeroGameObject;
import generatedCode.WeaponDetails;

class HeroGameObject extends ActorGameObject implements IHeroGameObject {
	public static inline final LEGENDARY_MOD_STAMINA = (1 : UInt);

	public static inline final LEGENDARY_MOD_APTITUDE = (2 : UInt);

	public static inline final LEGENDARY_MOD_ACCELERATION = (3 : UInt);

	public static inline final LEGENDARY_MOD_BEASTMASTER = (4 : UInt);

	public static inline final LEGENDARY_MOD_BARRIER = (10 : UInt);

	public static inline final LEGENDARY_MOD_COVER = (11 : UInt);

	public static inline final LEGENDARY_MOD_COMPREHENSION = (12 : UInt);

	static inline final LEGENDARY_MOD_DEFENSE:Float = 0.5;

	public static inline final MAX_HEALTH_BOMBS_PER_DUNGEON = (3 : UInt);

	public static inline final MAX_PARTY_BOMBS_PER_DUNGEON = (3 : UInt);

	var mHeroGameObjectNetworkComponent:HeroGameObjectNetworkComponent;

	var mCanMove:Bool = true;

	var mMana:UInt = 0;

	var mMaxBusterPoints:UInt = (ASCompat.floatToInt(4294967295) : UInt);

	var mBusterPoints:UInt = 0;

	var mExperiencePoints:UInt = 0;

	var mAscensionLevel:UInt = 0;

	var mHeroView:HeroView;

	var mHeroStateMachine:HeroStateMachine;

	var mPlayerID:UInt = 0;

	var mSlotPoints:Vector<UInt>;

	var mChatEventComponent:EventComponent;

	var mCanInitiateAnAttack:Bool = false;

	var mHeroData:HeroData;

	var mGMSkin:GMSkin;

	var mPartyBombsUsed:UInt = (0 : UInt);

	var mHealthBombsUsed:UInt = (0 : UInt);

	var mStaminaModMultiplier:Float = 0;

	var mAptitudeModMultiplier:Float = 0;

	var mAccelerationModMultiplier:Float = 0;

	var mBeastMasterModMultiplier:Float = 0;

	var mBarrierModMultiplier:Float = 0;

	var mCoverModMultiplier:Float = 0;

	var mComprehensionModMultiplier:Float = 0;

	var mConsumableDetails:Vector<ConsumableDetails>;

	var mConsumableWeapons:Vector<ConsumableWeaponGameObject>;

	public function new(dbFacade:DBFacade, remoteId:UInt) {
		super(dbFacade, remoteId);
		mWantNavCollisions = true;
		mChatEventComponent = new EventComponent(dbFacade);
		mCanInitiateAnAttack = true;
	}

	override function processJsonNavCollisions(navCollisions:Array<ASAny>, addFunc:ASFunction) {
		super.processJsonNavCollisions(navCollisions, addFunc);
	}

	override public function get_belongsToRemotePlayer():Bool {
		return !isOwner;
	}

	override function buildView() {
		var _loc1_ = new HeroView(mDBFacade, this);
		MemoryTracker.track(_loc1_, "HeroView - created in HeroGameObject.buildView()");
		view = _loc1_;
	}

	override public function set_view(actorView:FloorView):FloorView {
		mHeroView = ASCompat.reinterpretAs(actorView, HeroView);
		return super.view = actorView;
	}

	@:isVar public var heroView(get, never):HeroView;

	public function get_heroView():HeroView {
		return mHeroView;
	}

	override function buildStateMachine() {
		mHeroStateMachine = new HeroStateMachine(mDBFacade, this, this.mHeroView);
		MemoryTracker.track(mHeroStateMachine, "HeroStateMachine - created in HeroGameObject.buildStateMachine()");
		stateMachine = mHeroStateMachine;
	}

	@:isVar public var heroStateMachine(get, never):HeroStateMachine;

	public function get_heroStateMachine():HeroStateMachine {
		return mHeroStateMachine;
	}

	@:isVar public var canInitiateAnAttack(get, set):Bool;

	public function get_canInitiateAnAttack():Bool {
		return mCanInitiateAnAttack;
	}

	function set_canInitiateAnAttack(val:Bool):Bool {
		return mCanInitiateAnAttack = val;
	}

	public function setNetworkComponentDistributedPlayer(iface:HeroGameObjectNetworkComponent) {
		mHeroGameObjectNetworkComponent = iface;
	}

	override public function attack(attackType:UInt, targetActor:ActorGameObject, attackSpeedMultiplier:Float, attackTimeline:AttackTimeline,
			finishedCallback:ASFunction = null, stopCallback:ASFunction = null, loop:Bool = false, autoAim:Bool = false) {
		if (mCanInitiateAnAttack) {
			attackTimeline.currentAttackType = attackType;
			mHeroStateMachine.enterChoreographyState(attackSpeedMultiplier, targetActor, attackTimeline, finishedCallback, stopCallback, loop, autoAim);
		}
	}

	override public function destroy() {
		mChatEventComponent.destroy();
		mHeroStateMachine.destroy();
		mHeroStateMachine = null;
		var _loc1_:ConsumableWeaponGameObject;
		final __ax4_iter_317 = mConsumableWeapons;
		if (checkNullIteratee(__ax4_iter_317))
			for (_tmp_ in __ax4_iter_317) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		mConsumableWeapons = null;
		mHeroView = null;
		super.destroy();
	}

	override function determineState() {
		var _loc1_ = mState;
		if ("down" != _loc1_) {
			super.determineState();
		} else {
			if (this.heroStateMachine.currentStateName == "ActorReviveState") {
				return;
			}
			mHeroStateMachine.enterReviveState();
		}
	}

	public function setState(val:String) {
		state = val;
	}

	@:isVar public var skinType(get, set):UInt;

	public function set_skinType(val:UInt):UInt {
		mGMSkin = mDBFacade.gameMaster.getSkinByType(val);
		if (mGMSkin == null) {
			Logger.error("Unable to find GMSkin for skin type: " + val + " Loading default skin for heroType: " + type);
			mGMSkin = mDBFacade.gameMaster.getSkinByConstant(gMHero.DefaultSkin);
			if (mGMSkin == null) {
				Logger.error("Unable to find default skin with constant: " + gMHero.DefaultSkin);
			}
		}
		return val;
	}

	function get_skinType():UInt {
		return mGMSkin.Id;
	}

	override public function get_gmSkin():GMSkin {
		return mGMSkin;
	}

	override function buildActorData():ActorData {
		mHeroData = new HeroData(mDBFacade, this, mGMSkin);
		return mHeroData;
	}

	@:isVar public var manaPoints(get, set):UInt;

	public function set_manaPoints(mana:UInt):UInt {
		mMana = mana;
		mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE", id, mMana, (ASCompat.floatToInt(this.maxManaPoints) : UInt)));
		return mana;
	}

	function get_manaPoints():UInt {
		return mMana;
	}

	@:isVar public var experiencePoints(get, set):UInt;

	public function set_experiencePoints(exp:UInt):UInt {
		var _loc2_ = mLevel;
		var _loc3_ = (ASCompat.toInt(actorData != null ? this.gMHero.getBaseLevelFromExp(mExperiencePoints) : 0) : UInt);
		mExperiencePoints = exp;
		if (actorData != null) {
			this.level = this.gMHero.getLevelFromExp(mExperiencePoints, mAscensionLevel);
			if (this.gMHero.getBaseLevelFromExp(mExperiencePoints) != _loc3_) {
				refreshStatVector();
			}
		}
		if (mLevel != _loc2_) {
			mHeroView.playHeroLevelUpEffects();
			if (Std.isOfType(this, HeroGameObjectOwner)) {
				mDBFacade.steamAchievementsHelper.updateHeroLevelStat(this.gMHero.Constant, mLevel, mAscensionLevel);
				mFacade.eventManager.dispatchEvent(new LevelUpPostEvent("LevelUpPostEvent", mLevel));
			}
		}
		mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE", id, mExperiencePoints));
		return exp;
	}

	@:isVar public var dungeonBusterPoints(get, set):UInt;

	public function set_dungeonBusterPoints(val:UInt):UInt {
		mBusterPoints = val;
		mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE", id, mBusterPoints, mMaxBusterPoints));
		return val;
	}

	function get_dungeonBusterPoints():UInt {
		return mBusterPoints;
	}

	function get_experiencePoints():UInt {
		return mExperiencePoints;
	}

	@:isVar public var ascensionLevel(get, set):UInt;

	public function set_ascensionLevel(val:UInt):UInt {
		return mAscensionLevel = val;
	}

	function get_ascensionLevel():UInt {
		return mAscensionLevel;
	}

	@:isVar public var maxBusterPoints(get, set):UInt;

	public function set_maxBusterPoints(val:UInt):UInt {
		mMaxBusterPoints = val;
		mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE", id, mBusterPoints, mMaxBusterPoints));
		return val;
	}

	function get_maxBusterPoints():UInt {
		return mMaxBusterPoints;
	}

	@:isVar public var healthBombUsesRemaining(get, never):Int;

	public function get_healthBombUsesRemaining():Int {
		var _loc1_ = 3 - (mHealthBombsUsed : Float);
		if (_loc1_ < 0) {
			Logger.warn("More healthbombs have been consumed than allowed in limited use dungeons.");
			_loc1_ = 0;
		}
		return ASCompat.floatToInt(_loc1_);
	}

	@:isVar public var partyBombUsesRemaining(get, never):Int;

	public function get_partyBombUsesRemaining():Int {
		var _loc1_ = 3 - (mPartyBombsUsed : Float);
		if (_loc1_ < 0) {
			Logger.warn("More partybombs have been consumed than allowed in limited use dungeons.");
			_loc1_ = 0;
		}
		return ASCompat.floatToInt(_loc1_);
	}

	@:isVar public var healthBombsUsed(never, set):UInt;

	public function set_healthBombsUsed(val:UInt):UInt {
		mHealthBombsUsed = val;
		if (isOwner) {
			mDBFacade.steamAchievementsHelper.setHighestStatValueAchieved((mHealthBombsUsed : Int), "MOST_HEALTH_BOMBS_IN_DUNGEON");
		}
		return val;
	}

	@:isVar public var partyBombsUsed(never, set):UInt;

	public function set_partyBombsUsed(val:UInt):UInt {
		return mPartyBombsUsed = val;
	}

	public function canUseHealthBombs():Bool {
		if (mDistributedDungeonFloor.isInfiniteDungeon) {
			return mHealthBombsUsed < 3;
		}
		return true;
	}

	public function canUsePartyBombs():Bool {
		if (mDistributedDungeonFloor.isInfiniteDungeon) {
			return mPartyBombsUsed < 3;
		}
		return true;
	}

	override public function postGenerate() {
		processLegendaryModifiers();
		super.postGenerate();
		mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE", id, mMana, (ASCompat.floatToInt(this.maxManaPoints) : UInt)));
		mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE", id, mBusterPoints, mMaxBusterPoints));
		mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE", id, mExperiencePoints));
		mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE", id, mHitPoints, (ASCompat.floatToInt(this.maxHitPoints) : UInt)));
		mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE", mPlayerID), function(param1:events.ChatEvent) {
			Chat(param1.message);
		});
		mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING", mPlayerID), function(param1:events.PlayerIsTypingEvent) {
			if (param1.subtype == "CHAT_BOX_FOCUS_IN") {
				ShowPlayerisTyping(true);
			} else {
				ShowPlayerisTyping(false);
			}
		});
	}

	public function processLegendaryModifiers() {
		mStaminaModMultiplier = 0;
		mAptitudeModMultiplier = 0;
		mAccelerationModMultiplier = 0;
		mBeastMasterModMultiplier = 0;
		mBarrierModMultiplier = 0;
		mCoverModMultiplier = 0;
		mComprehensionModMultiplier = 0;
		var _loc1_:WeaponDetails;
		final __ax4_iter_318 = mWeaponDetails;
		if (checkNullIteratee(__ax4_iter_318))
			for (_tmp_ in __ax4_iter_318) {
				_loc1_ = _tmp_;
				switch (_loc1_.legendarymodifier - 1) {
					case 0:
						mStaminaModMultiplier += 10 + _loc1_.requiredlevel * 0.9;

					case 1:
						mAptitudeModMultiplier += 10 + _loc1_.requiredlevel * 0.4;

					case 2:
						mAccelerationModMultiplier += 0.1;

					case 3:
						mBeastMasterModMultiplier += 10 + _loc1_.requiredlevel * 0.9;

					case 9:
						mBarrierModMultiplier = 0.5;

					case 10:
						mCoverModMultiplier = 0.5;

					case 11:
						mComprehensionModMultiplier = 0.5;
				}
			}
	}

	@:isVar public var beastMasterModMultiplier(get, never):Float;

	public function get_beastMasterModMultiplier():Float {
		return mBeastMasterModMultiplier;
	}

	override public function get_maxHitPoints():Float {
		return this.buffHandler.multiplier.maxHitPoints * (mStats.maxHitPoints + mStaminaModMultiplier);
	}

	override public function get_maxManaPoints():Float {
		return this.buffHandler.multiplier.maxManaPoints * (mStats.maxManaPoints + mAptitudeModMultiplier);
	}

	override public function get_movementSpeed():Float {
		var _loc2_ = mStats.movementSpeed;
		var _loc3_ = this.buffHandler.multiplier.movementSpeed;
		return _loc2_ * _loc3_ * (1 + mAccelerationModMultiplier);
	}

	@:isVar public var slotPoints(never, set):Vector<UInt>;

	public function set_slotPoints(val:Vector<UInt>):Vector<UInt> {
		return mSlotPoints = val;
	}

	public function setNetworkComponentHeroGameObject(iface:HeroGameObjectNetworkComponent) {}

	override public function set_stats(value:StatVector):StatVector {
		super.stats = value;
		mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE", id, mMana, (ASCompat.floatToInt(this.maxManaPoints) : UInt)));
		return value;
	}

	@:isVar public var playerID(get, set):UInt;

	public function set_playerID(val:UInt):UInt {
		return mPlayerID = val;
	}

	function get_playerID():UInt {
		return mPlayerID;
	}

	public function TriggerEffect(effect:String) {}

	@:isVar public var gMHero(get, never):GMHero;

	public function get_gMHero():GMHero {
		return ASCompat.reinterpretAs(mActorData.gMActor, GMHero);
	}

	override function refreshStatVector() {
		var _loc12_:Int;
		var _loc13_:Float;
		var _loc7_ = 0;
		var _loc9_ = 0;
		var _loc2_ = gMHero;
		this.level = _loc2_.getLevelFromExp(mExperiencePoints, mAscensionLevel);
		var _loc3_ = _loc2_.getBaseLevelFromExp(mExperiencePoints);
		var _loc5_ = new StatVector();
		_loc7_ = 0;
		while (_loc7_ < 4) {
			_loc9_ = 0;
			while (_loc9_ < _loc2_.UpgradeToSlotOffset[_loc7_].length) {
				_loc12_ = _loc2_.UpgradeToSlotOffset[_loc7_][_loc9_];
				_loc13_ = _loc5_.values[_loc12_] + mSlotPoints[_loc7_];
				_loc5_.values[_loc12_] = _loc13_;
				_loc9_++;
			}
			_loc7_++;
		}
		var _loc11_ = StatVector.multiply(_loc2_.Normalized_upgrades, _loc5_);
		var _loc10_ = StatVector.add(mActorData.baseValues, StatVector.multiplyScalar(mActorData.levelValues, _loc3_));
		_loc10_ = StatVector.add(_loc10_, _loc11_);
		var _loc8_ = StatVector.add(StatVector.multiply(_loc10_, mDBFacade.gameMaster.stat_BonusMultiplier), mDBFacade.gameMaster.stat_bias);
		var _loc4_ = StatVector.add(mActorData.baseValues, StatVector.multiplyScalar(mActorData.levelValues, DamageCurve.heroAttackCurve(_loc3_)));
		_loc4_ = StatVector.add(_loc4_, _loc11_);
		var _loc6_ = StatVector.add(StatVector.multiply(_loc4_, mDBFacade.gameMaster.stat_BonusMultiplier), mDBFacade.gameMaster.stat_bias);
		var _loc1_ = StatVector.clone(_loc8_);
		_loc1_.values[DBGlobal.HP_BOOST] = mActorData.hp + _loc8_.values[DBGlobal.HP_BOOST];
		_loc1_.values[DBGlobal.MP_BOOST] = mActorData.mp + _loc8_.values[DBGlobal.MP_BOOST];
		_loc1_.values[DBGlobal.MELEE_ATK] = _loc6_.values[DBGlobal.MELEE_ATK];
		_loc1_.values[DBGlobal.SHOOT_ATK] = _loc6_.values[DBGlobal.SHOOT_ATK];
		_loc1_.values[DBGlobal.MAGIC_ATK] = _loc6_.values[DBGlobal.MAGIC_ATK];
		_loc1_.values[DBGlobal.MELEE_DEF] += mBarrierModMultiplier;
		_loc1_.values[DBGlobal.SHOOT_DEF] += mCoverModMultiplier;
		_loc1_.values[DBGlobal.MAGIC_DEF] += mComprehensionModMultiplier;
		_loc1_.values[DBGlobal.MOVEMENT] = _loc2_.BaseMove * _loc8_.values[DBGlobal.MOVEMENT];
		stats = _loc1_;
	}

	public function IsInvulnerable():Bool {
		return buffHandler.IsInvulnerable();
	}

	public function setStateAndAttackChoreography(targetState:String, attackChoreography:AttackChoreography) {
		state = targetState;
		ReceiveAttackChoreography(attackChoreography);
	}

	public function StopChoreography() {
		if (this.stateMachine != null
			&& this.stateMachine.currentSubState != null
			&& this.stateMachine.currentSubState.name == "ActorChoreographySubState") {
			this.stateMachine.enterNavigationState();
		}
	}

	public function PartyBomb(bomberId:UInt) {
		var _loc3_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(bomberId), HeroGameObject);
		var _loc4_ = _loc3_.screenName + "\n" + Locale.getString("BOMB_DROPPER");
		var _loc2_ = new FloorMessageView(mDBFacade, "", _loc4_.toUpperCase());
		MemoryTracker.track(_loc2_, "FloorMessageView - created in HeroGameObject.on_party_bomb()");
	}

	@:isVar public var consumableDetails(never, set):Vector<ConsumableDetails>;

	public function set_consumableDetails(val:Vector<ConsumableDetails>):Vector<ConsumableDetails> {
		mConsumableDetails = val;
		var _loc5_ = (0 : UInt);
		var _loc2_ = (0 : UInt);
		var _loc4_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		if (val.length > 0) {
			_loc5_ = val[0].type;
			_loc2_ = val[0].count;
		}
		if (val.length > 1) {
			_loc4_ = val[1].type;
			_loc3_ = val[1].count;
		}
		if (mActorData != null && mDistributedDungeonFloor != null) {
			setupConsumables();
		}
		return val;
	}

	override function setupConsumables() {
		var _loc4_:ConsumableWeaponGameObject = null;
		var _loc2_:ConsumableWeaponGameObject;
		final __ax4_iter_319 = mConsumableWeapons;
		if (checkNullIteratee(__ax4_iter_319))
			for (_tmp_ in __ax4_iter_319) {
				_loc2_ = _tmp_;
				if (_loc2_ != null) {
					_loc2_.destroy();
				}
			}
		var _loc1_ = (0 : UInt);
		mConsumableWeapons = new Vector<ConsumableWeaponGameObject>();
		var _loc3_:ConsumableDetails;
		final __ax4_iter_320 = mConsumableDetails;
		if (checkNullIteratee(__ax4_iter_320))
			for (_tmp_ in __ax4_iter_320) {
				_loc3_ = _tmp_;
				if (_loc3_.type != 0) {
					_loc4_ = new ConsumableWeaponGameObject(_loc3_, this, mActorView, mDBFacade, mDistributedDungeonFloor, _loc1_);
					MemoryTracker.track(_loc4_, "ConsumableWeaponGameObject - created in HeroGameObject.setupConsumables()");
					mConsumableWeapons.push(_loc4_);
				} else {
					mConsumableWeapons.push(null);
				}
				_loc1_++;
			}
	}

	@:isVar public var consumables(get, never):Vector<ConsumableWeaponGameObject>;

	public function get_consumables():Vector<ConsumableWeaponGameObject> {
		return mConsumableWeapons;
	}

	override public function get_attackCooldownMultiplier():Float {
		var _loc1_:GMSuperStat = null;
		if (gMHero.StatUpgrade3 == "MAGIC_COOLDOWN") {
			_loc1_ = ASCompat.coerce(mDBFacade.gameMaster.superStatByConstant.itemFor(gMHero.StatUpgrade3), gameMasterDictionary.GMSuperStat);
			return 0.01 * (mSlotPoints[2] * gMHero.AmtStat3 * _loc1_.CooldownReduction);
		}
		return buffHandler.attackCooldownMultiplier - 1;
	}
}
