package actor
;
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
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
    class ActorGameObject extends FloorObject
   {
      
      public static inline final PROP_CHAR_TYPE= "PROP";
      
      public static inline final PET_CHAR_TYPE= "PET";
      
      static inline final SUFFER_TIMELINE_NAME= "GENERIC_STUN";
      
      static inline final GENERIC_SUFFER_KNOCKBACK= "GENERIC_SUFFER_KNOCKBACK";
      
      static inline final TELEPORT= "TELEPORT";
      
      public static inline final ATTEMPT_REVIVE_INSTANT_TIMELINE_NAME= "TM_ATTEMPT_REVIVE_INSTANT";
      
      public static inline final ATTEMPT_REVIVE_LONG_TIMELINE_NAME= "TM_ATTEMPT_REVIVE_LONG";
      
      static inline final ATTEMPT_REVIVE_LONG_ATTACK_ID= (910900 : UInt);
      
      static inline final ATTEMPT_REVIVE_INSTANT_ATTACK_ID= (910901 : UInt);
      
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
      
      var mIsBlocking:Bool = false;
      
      var mMaximumDotForBlock:Float = -1.1;
      
      public var effectivenessShown:Bool = false;
      
      var mAttemptReviveScript:AttackTimeline;
      
      var mCanBeKnockedBack:Bool = true;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
         mStats = new StatVector();
         mTeam = 0;
         mAFK = false;
         mMovementController = new MovementController(this,mActorView,mDBFacade);
         mMouseEventHandler = new MouseEventHandler(this,mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         buildStateMachine();
         mLevel = (0 : UInt);
         this.layer = 20;
         buffHandler = new BuffHandler(param1,this);
         mShowHitFloater = mDBFacade.dbConfigManager.getConfigBoolean("show_hit_floater",true);
      }
      
      @:isVar public var isOwner(get,never):Bool;
public function  get_isOwner() : Bool
      {
         return false;
      }
      
      @:isVar public var projectileLaunchOffset(get,never):Vector3D;
public function  get_projectileLaunchOffset() : Vector3D
      {
         return new Vector3D(0,mActorData.gMActor.scaled_ProjEmitOffset);
      }
      
      override public function  set_tile(param1:Tile) :Tile      {
         if(param1 == mTile)
         {
            super.tile = param1;
            return param1;
         }
         if(mHasOwnership && mTile != null)
         {
            mTile.removeOwnedFloorObject(this);
         }
         super.tile = param1;
         if(mHasOwnership && mTile != null)
         {
            mTile.addOwnedFloorObject(this);
         }
return param1;
      }
      
      @:isVar public var hasOwnership(never,set):Bool;
public function  set_hasOwnership(param1:Bool) :Bool      {
         mHasOwnership = param1;
         if(mHasOwnership)
         {
            if(this.tile != null)
            {
               this.tile.addOwnedFloorObject(this);
            }
         }
         else if(this.tile != null)
         {
            this.tile.removeOwnedFloorObject(this);
         }
return param1;
      }
      
      override public function newNetworkChild(param1:GameObject) 
      {
      }
      
      @:isVar public var isNavigable(get,never):Bool;
public function  get_isNavigable() : Bool
      {
         return false;
      }
      
      @:isVar public var isAttackable(get,never):Bool;
public function  get_isAttackable() : Bool
      {
         return true;
      }
      
      override public function init() 
      {
         var _loc2_:String = null;
         super.init();
         this.createNavCollisions(this.actorData.constant);
         mMouseEventHandler.Init();
         setupWeapons();
         initializeToFirstValidWeapon();
         determineState();
         var _loc3_= this.actorData.gMActor.TeleportInTimeline;
         var _loc1_= this.actorData.gMActor.TeleportOutTimeline;
         if(ASCompat.stringAsBool(_loc3_) && ASCompat.stringAsBool(_loc1_))
         {
            mTeleportInTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc3_,this,mDistributedDungeonFloor);
            mTeleportOutTimeline = mDBFacade.timelineFactory.createScriptTimeline(_loc1_,this,mDistributedDungeonFloor);
         }
         if(mAttemptReviveScript == null)
         {
            if(mDBFacade.dbConfigManager.getConfigBoolean("use_long_revive",true))
            {
               _loc2_ = "TM_ATTEMPT_REVIVE_LONG";
            }
            else
            {
               _loc2_ = "TM_ATTEMPT_REVIVE_INSTANT";
            }
            mAttemptReviveScript = mDBFacade.timelineFactory.createAttackTimeline(_loc2_,null,this,mDistributedDungeonFloor);
         }
      }
      
      @:isVar public var actorView(get,never):ActorView;
public function  get_actorView() : ActorView
      {
         return mActorView;
      }
      
            
      @:isVar public var currentWeapon(get,set):WeaponGameObject;
public function  set_currentWeapon(param1:WeaponGameObject) :WeaponGameObject      {
         mCurrentWeapon = param1;
         if(mActorView != null)
         {
            if(param1 != null)
            {
               mActorView.currentWeapon = param1.weaponView;
            }
            else
            {
               Logger.warn("Trying to equip a null weapon game object on actor.");
            }
         }
return param1;
      }
function  get_currentWeapon() : WeaponGameObject
      {
         return mCurrentWeapon;
      }
      
      function buildStateMachine() 
      {
      }
      
            
      @:isVar public var stateMachine(get,set):ActorMacroStateMachine;
public function  set_stateMachine(param1:ActorMacroStateMachine) :ActorMacroStateMachine      {
         return mActorStateMachine = param1;
      }
function  get_stateMachine() : ActorMacroStateMachine
      {
         return mActorStateMachine;
      }
      
      @:isVar public var actorData(get,never):ActorData;
public function  get_actorData() : ActorData
      {
         return mActorData;
      }
      
      @:isVar public var actorNametag(get,never):ActorNametag;
public function  get_actorNametag() : ActorNametag
      {
         return mActorView.nametag;
      }
      
      override public function  set_view(param1:FloorView) :FloorView      {
         mActorView = ASCompat.reinterpretAs(param1 , ActorView);
         if(mCurrentWeapon != null)
         {
            mActorView.currentWeapon = mCurrentWeapon.weaponView;
         }
         return super.view = param1;
      }
      
            
      @:isVar public var screenName(get,set):String;
public function  set_screenName(param1:String) :String      {
         mScreenName = param1;
         mActorView.screenName = screenName;
return param1;
      }
      
      @:isVar public var AFK(get,never):Bool;
public function  get_AFK() : Bool
      {
         return mAFK;
      }
function  get_screenName() : String
      {
         return mScreenName;
      }
      
      public function Chat(param1:String) 
      {
         mActorView.setChat(param1);
      }
      
      public function ShowPlayerisTyping(param1:Bool) 
      {
         if(mActorView != null && mActorView.nametag != null)
         {
            mActorView.nametag.showPlayerIsTypingNotification(param1);
         }
      }
      
      @:isVar public var maxHitPoints(get,never):Float;
public function  get_maxHitPoints() : Float
      {
         return mStats.maxHitPoints * this.buffHandler.multiplier.maxHitPoints;
      }
      
      @:isVar public var attackCooldownMultiplier(get,never):Float;
public function  get_attackCooldownMultiplier() : Float
      {
         return buffHandler.attackCooldownMultiplier;
      }
      
      @:isVar public var maxManaPoints(get,never):Float;
public function  get_maxManaPoints() : Float
      {
         return mStats.maxManaPoints * this.buffHandler.multiplier.maxManaPoints;
      }
      
      @:isVar public var movementSpeed(get,never):Float;
public function  get_movementSpeed() : Float
      {
         var _loc2_= mStats.movementSpeed;
         var _loc3_= this.buffHandler.multiplier.movementSpeed;
         return _loc2_ * _loc3_;
      }
      
            
      @:isVar public var heading(get,set):Float;
public function  get_heading() : Float
      {
         return mHeading;
      }
function  set_heading(param1:Float) :Float      {
         mHeading = param1;
         this.move();
return param1;
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         super.position = param1;
         this.move();
return param1;
      }
      
      function move() 
      {
         mMovementController.move(this.position,this.heading);
      }
      
      public function getHeadingAsVector(param1:Float = 0) : Vector3D
      {
         var _loc4_= new Vector3D();
         var _loc2_= (heading + param1) * 3.141592653589793 / 180;
         var _loc5_= Math.cos(_loc2_);
         var _loc3_= Math.sin(_loc2_);
         return new Vector3D(_loc5_,_loc3_);
      }
      
            
      @:isVar public var movementControllerType(get,set):String;
public function  set_movementControllerType(param1:String) :String      {
         return this.mMovementController.movementType = param1;
      }
function  get_movementControllerType() : String
      {
         return this.mMovementController.movementType;
      }
      
      @:isVar public var canMoveR(get,never):Bool;
public function  get_canMoveR() : Bool
      {
         return this.mMovementController.canMoveR;
      }
      
      public function postGenerate() 
      {
         mActorData = buildActorData();
         refreshStatVector();
         checkIfReadyForInit();
         mActorView.position = position;
      }
      
      function buildActorData() : ActorData
      {
         return new ActorData(mDBFacade,this);
      }
      
      public function playEffectAtActor(param1:String, param2:String, param3:Float, param4:String) 
      {
         distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(param1),param2,actorView.position,null,false,param3,0,0,0,0,false,param4);
      }
      
      override public function destroy() 
      {
         if(mTile != null && mTile.hasOwnedFloorObject(this))
         {
            mTile.removeOwnedFloorObject(this);
         }
         if(mDistributedDungeonFloor != null)
         {
            mDistributedDungeonFloor.RemoveNetworkChild(this);
         }
         if(mSufferTimeline != null)
         {
            mSufferTimeline.destroy();
            mSufferTimeline = null;
         }
         if(mSufferKnockBackTimeline != null)
         {
            mSufferKnockBackTimeline.destroy();
            mSufferKnockBackTimeline = null;
         }
         if(mTeleportInTimeline != null)
         {
            mTeleportInTimeline.destroy();
            mTeleportInTimeline = null;
         }
         if(mTeleportOutTimeline != null)
         {
            mTeleportOutTimeline.destroy();
            mTeleportOutTimeline = null;
         }
         mPosition = null;
         mMovementController.destroy();
         mMovementController = null;
         mMouseEventHandler.destroy();
         mMouseEventHandler = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         mActorStateMachine = null;
         mStats.destroy();
         mStats = null;
         buffHandler.destroy();
         buffHandler = null;
         mActorView = null;
         if(mActorData != null)
         {
            mActorData.destroy();
            mActorData = null;
         }
         mCurrentWeapon = null;
         mWeaponDetails = null;
         var _loc1_:WeaponGameObject;
         final __ax4_iter_19 = mWeapons;
         if (checkNullIteratee(__ax4_iter_19)) for (_tmp_ in __ax4_iter_19)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
         }
         mWeapons = null;
         if(mRunIdleMonitorTask != null)
         {
            mRunIdleMonitorTask.destroy();
            mRunIdleMonitorTask = null;
         }
         super.destroy();
      }
      
      override public function  set_distributedDungeonFloor(param1:DistributedDungeonFloor) :DistributedDungeonFloor      {
         super.distributedDungeonFloor = param1;
         checkIfReadyForInit();
return param1;
      }
      
      function checkIfReadyForInit() 
      {
         if(mDistributedDungeonFloor != null && mActorData != null)
         {
            init();
         }
      }
      
      public function attack(param1:UInt, param2:ActorGameObject, param3:Float, param4:AttackTimeline, param5:ASFunction = null, param6:ASFunction = null, param7:Bool = false, param8:Bool = false) 
      {
         param4.currentAttackType = param1;
         mActorStateMachine.enterChoreographyState(param3,param2,param4,param5,param6,param7,param8);
      }
      
            
      @:isVar public var hitPoints(get,set):UInt;
public function  set_hitPoints(param1:UInt) :UInt      {
         mHitPoints = param1;
         mActorView.setHp(mHitPoints,(Std.int(this.maxHitPoints) : UInt));
         mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,(Std.int(this.maxHitPoints) : UInt)));
return param1;
      }
function  get_hitPoints() : UInt
      {
         return mHitPoints;
      }
      
      @:isVar public var gmSkin(get,never):GMSkin;
public function  get_gmSkin() : GMSkin
      {
         return null;
      }
      
      public function ReceiveAttackChoreography(param1:AttackChoreography) 
      {
         var _loc4_= Math.NaN;
         var _loc5_:ActorGameObject = null;
         var _loc2_= this.mWeaponDetails[param1.attack.weaponSlot];
         var _loc3_:WeaponGameObject = null;
         if(_loc2_.type != 0)
         {
            _loc3_ = getWeaponForId(_loc2_.type);
            if(_loc3_ == null)
            {
               Logger.error("Weapon type: " + _loc2_.type + " on incoming attackChoreography does not match any weapon type currently equipped on actor.");
               return;
            }
            currentWeapon = _loc3_;
         }
         else
         {
            _loc3_ = currentWeapon;
         }
         var _loc6_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1.attack.attackType), gameMasterDictionary.GMAttack);
         if(_loc6_ == null)
         {
            Logger.error("Unable to find GMAttack for attacktype: " + param1.attack.attackType);
            return;
         }
         var _loc7_= _loc3_.getAttackTimeline(_loc6_.Id);
         if(_loc7_ != null)
         {
            _loc4_ = param1.playSpeed;
            if(param1.attack.targetActorDoid != 0)
            {
               _loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1.attack.targetActorDoid) , ActorGameObject);
            }
            mActorStateMachine.enterAttackChoreographyState(_loc4_,_loc5_,_loc7_,param1);
         }
      }
      
      public function ReceiveCombatResult(param1:CombatResult) 
      {
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1.attack.attackType), gameMasterDictionary.GMAttack);
         if(_loc2_ != null)
         {
            if(_loc2_.DamageMod > 0)
            {
               this.actorView.receiveHeal(param1,_loc2_);
            }
            else if(param1.blocked == 0)
            {
               this.actorView.receiveDamage(param1,_loc2_);
               receiveDamage(param1);
            }
            else
            {
               trace("TODO: Implement blocked view things and such!   BLOCKED!!!!!");
            }
         }
      }
      
      @:isVar public var canSuffer(get,set):Bool;
public function  get_canSuffer() : Bool
      {
         return !this.hasAbility((1 : UInt));
      }
      
            
      @:isVar public var canBeKnockedBack(get,set):Bool;
public function  get_canBeKnockedBack() : Bool
      {
         return mCanBeKnockedBack;
      }
function  set_canBeKnockedBack(param1:Bool) :Bool      {
         return mCanBeKnockedBack = param1;
      }
      
      function receiveDamage(param1:CombatResult) 
      {
         if(isHeroType && param1.attacker != param1.attackee)
         {
            mMouseEventHandler.sendGotHitEvent();
         }
         var _loc2_:Float = 1;
         if(param1.knockback == 1 && canBeKnockedBack)
         {
            if(mSufferKnockBackTimeline == null)
            {
               mSufferKnockBackTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_SUFFER_KNOCKBACK",this,mDistributedDungeonFloor);
            }
            mSufferKnockBackTimeline.currentAttackType = param1.attack.attackType;
            mActorStateMachine.enterCombatResultChoreographyState(_loc2_,null,mSufferKnockBackTimeline,param1,mDistributedDungeonFloor.getActor(param1.attacker));
         }
         else if(param1.suffer == 1 && canSuffer)
         {
            if(mSufferTimeline == null)
            {
               mSufferTimeline = mDBFacade.timelineFactory.createScriptTimeline("GENERIC_STUN",this,mDistributedDungeonFloor);
            }
            mActorStateMachine.enterCombatResultChoreographyState(_loc2_,null,mSufferTimeline,param1,mDistributedDungeonFloor.getActor(param1.attacker));
         }
      }
      
      public function ReceiveTimelineAction(param1:String) 
      {
         if(mTeleportInTimeline != null && param1 == mTeleportInTimeline.attackName)
         {
            mActorStateMachine.enterChoreographyState(1,null,mTeleportInTimeline);
         }
         if(mTeleportOutTimeline != null && param1 == mTeleportOutTimeline.attackName)
         {
            mActorStateMachine.enterChoreographyState(1,null,mTeleportOutTimeline);
         }
      }
      
      function getWeaponForId(param1:UInt) : WeaponGameObject
      {
         var _loc2_:WeaponGameObject;
         final __ax4_iter_20 = mWeapons;
         if (checkNullIteratee(__ax4_iter_20)) for (_tmp_ in __ax4_iter_20)
         {
            _loc2_ = _tmp_;
            if(_loc2_ != null && ASCompat.toNumberField(_loc2_, "weaponType") == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      @:isVar public var weapons(get,never):Vector<WeaponGameObject>;
public function  get_weapons() : Vector<WeaponGameObject>
      {
         return mWeapons;
      }
      
            
      @:isVar public var type(get,set):UInt;
public function  set_type(param1:UInt) :UInt      {
         return mActorType = param1;
      }
function  get_type() : UInt
      {
         return mActorType;
      }
      
      @:isVar public var isHeroType(get,never):Bool;
public function  get_isHeroType() : Bool
      {
         if(mActorType > 100 && mActorType < 200)
         {
            return true;
         }
         return false;
      }
      
      @:isVar public var isProp(get,never):Bool;
public function  get_isProp() : Bool
      {
         return this.actorData.gMActor.CharType == "PROP";
      }
      
      @:isVar public var isPet(get,never):Bool;
public function  get_isPet() : Bool
      {
         return this.actorData.gMActor.CharType == "PET";
      }
      
      @:isVar public var usePetUI(get,never):Bool;
public function  get_usePetUI() : Bool
      {
         return false;
      }
      
      @:isVar public var hasShowHealNumbers(get,never):Bool;
public function  get_hasShowHealNumbers() : Bool
      {
         return false;
      }
      
      @:isVar public var state(never,set):String;
public function  set_state(param1:String) :String      {
         if(mState != param1)
         {
            mState = param1;
            determineState();
         }
return param1;
      }
      
      @:isVar public var weaponDetails(never,set):Vector<WeaponDetails>;
public function  set_weaponDetails(param1:Vector<WeaponDetails>) :Vector<WeaponDetails>      {
         mWeaponDetails = param1;
         if(mActorData != null && mDistributedDungeonFloor != null)
         {
            setupWeapons();
            initializeToFirstValidWeapon();
         }
return param1;
      }
      
      function setupWeapons() 
      {
         var _loc1_:WeaponGameObject;
         final __ax4_iter_21 = mWeapons;
         if (checkNullIteratee(__ax4_iter_21)) for (_tmp_ in __ax4_iter_21)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
         }
         var _loc2_:Float = 0;
         mWeapons = new Vector<WeaponGameObject>();
         var _loc3_:WeaponDetails;
         final __ax4_iter_22 = mWeaponDetails;
         if (checkNullIteratee(__ax4_iter_22)) for (_tmp_ in __ax4_iter_22)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toNumberField(_loc3_, "type") != 0)
            {
               _loc1_ = new WeaponGameObject(_loc3_,this,mActorView,mDBFacade,mDistributedDungeonFloor,_loc2_);
               MemoryTracker.track(_loc1_,"WeaponGameObject - created in ActorGameObject.setupWeapons()");
               mWeapons.push(_loc1_);
            }
            else
            {
               mWeapons.push(null);
            }
            _loc2_++;
         }
         setupConsumables();
      }
      
      function setupConsumables() 
      {
      }
      
      function initializeToFirstValidWeapon() 
      {
         var _loc1_:WeaponGameObject = null;
         var _loc2_= 0;
         if(mWeapons.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < mWeapons.length)
            {
               _loc1_ = mWeapons[_loc2_];
               if(_loc1_ != null)
               {
                  this.currentWeapon = _loc1_;
                  break;
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
         }
      }
      
      public function isDead() : Bool
      {
         if(mActorStateMachine == null)
         {
            return false;
         }
         return mActorStateMachine.currentStateName == "ActorDeadState";
      }
      
      public function isInReviveState() : Bool
      {
         if(mActorStateMachine == null)
         {
            return false;
         }
         return mActorStateMachine.currentStateName == "ActorReviveState";
      }
      
      public function localToGlobal(param1:Point) : Point
      {
         return this.view.root.localToGlobal(param1);
      }
      
      public function globalToLocal(param1:Point) : Point
      {
         return this.view.root.globalToLocal(param1);
      }
      
      public function hitTestObject(param1:DisplayObject) : Bool
      {
         return this.view.root.hitTestObject(param1);
      }
      
      public function localCombatHit(param1:CombatResult) 
      {
         mActorView.localCombatHit(param1);
      }
      
      @:isVar public var scale(never,set):Float;
public function  set_scale(param1:Float) :Float      {
         this.view.root.scaleX = param1;
         return this.view.root.scaleY = param1;
      }
      
            
      @:isVar public var flip(get,set):UInt;
public function  set_flip(param1:UInt) :UInt      {
         mFlip = param1;
         if(mFlip != 0)
         {
            this.actorView.body.scaleX = -Math.abs(this.actorView.body.scaleX);
         }
return param1;
      }
function  get_flip() : UInt
      {
         return mFlip;
      }
      
            
      @:isVar public var level(get,set):UInt;
public function  set_level(param1:UInt) :UInt      {
         return mLevel = param1;
      }
function  get_level() : UInt
      {
         return mLevel;
      }
      
            
      @:isVar public var stats(get,set):StatVector;
public function  get_stats() : StatVector
      {
         return mStats;
      }
function  set_stats(param1:StatVector) :StatVector      {
         mStats = param1;
         mActorView.setHp(mHitPoints,(Std.int(this.maxHitPoints) : UInt));
         mDBFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,(Std.int(this.maxHitPoints) : UInt)));
return param1;
      }
      
      function determineState() 
      {
         if(this.actorData != null)
         {
            switch(mState)
            {
               case "dead":
                  mActorStateMachine.enterDeadState(finishedDeathCallback);
                  
               case "":
                  mActorStateMachine.enterDefaultState();
                  
               default:
                  Logger.error("No case handled for state: " + mState + " for actorGameObject.");
            }
         }
      }
      
      function finishedDeathCallback(param1:GameClock = null) 
      {
         if(mHasOwnership)
         {
            this.destroy();
         }
      }
      
      function refreshStatVector() 
      {
         var _loc1_= 0;
         _loc1_ = 5;
         var _loc4_= mTeam == 5 ? mLevel : Math.pow(mLevel,1.5);
         var _loc3_= StatVector.add(mActorData.baseValues,StatVector.multiplyScalar(mActorData.levelValues,_loc4_));
         var _loc2_= StatVector.add(StatVector.multiply(_loc3_,mDBFacade.gameMaster.stat_BonusMultiplier),mDBFacade.gameMaster.stat_bias);
         _loc2_.values[0] = mActorData.hp + _loc2_.values[0];
         _loc2_.values[1] = mActorData.mp + _loc2_.values[1];
         _loc2_.values[13] = mActorData.gMActor.BaseMove + _loc2_.values[13];
         stats = _loc2_;
      }
      
      override function buildFilter() : B2FilterData
      {
         var _loc1_= new B2FilterData();
         _loc1_.maskBits = (0 : UInt);
         _loc1_.categoryBits = (0 : UInt);
         _loc1_.categoryBits = ((_loc1_.categoryBits | DBGlobal.b2dMaskForTeam((team : UInt)) : UInt) : UInt);
         if(!this.isNavigable)
         {
            _loc1_.maskBits = ((_loc1_.maskBits | (1 : UInt) : UInt) : UInt);
            _loc1_.maskBits = ((_loc1_.maskBits | DBGlobal.b2dMaskForAllTeamsBut((team : UInt)) : UInt) : UInt);
            if(this.actorData.gMActor.CollideWithTeam || this.isOwner)
            {
               _loc1_.maskBits = ((_loc1_.maskBits | DBGlobal.b2dMaskForTeam((team : UInt)) : UInt) : UInt);
            }
         }
         if(actorData.gMActor.Species != "TRAP")
         {
            _loc1_.maskBits = ((_loc1_.maskBits | (2 : UInt) : UInt) : UInt);
         }
         return _loc1_;
      }
      
            
      @:isVar public var team(get,set):Int;
public function  set_team(param1:Int) :Int      {
         return mTeam = param1;
      }
function  get_team() : Int
      {
         return mTeam;
      }
      
      public function hasAbility(param1:UInt) : Bool
      {
         return ((actorData.gMActor.Ability : Int) & (param1 : Int)) != 0 || buffHandler.HasAbility(param1);
      }
      
      public function startRunIdleMonitoring() 
      {
         if(mRunIdleMonitorTask == null)
         {
            mRunIdleMonitorTask = mPreRenderWorkComponent.doEveryFrame(runIdleMonitor);
         }
      }
      
      public function stopRunIdleMonitoring() 
      {
         if(mRunIdleMonitorTask != null)
         {
            mRunIdleMonitorTask.destroy();
            mRunIdleMonitorTask = null;
         }
      }
      
      function runIdleMonitor(param1:GameClock) 
      {
         if(mActorView.velocity.lengthSquared == 0)
         {
            mActorView.playAnim("idle");
         }
         else
         {
            mActorView.playAnim("run");
         }
      }
      
      @:isVar public var setAFK(never,set):UInt;
public function  set_setAFK(param1:UInt) :UInt      {
         this.mAFK = param1 != 0;
         mActorView.AFK = this.mAFK;
return param1;
      }
      
            
      @:isVar public var isBlocking(get,set):Bool;
public function  get_isBlocking() : Bool
      {
         return mIsBlocking;
      }
function  set_isBlocking(param1:Bool) :Bool      {
         return mIsBlocking = param1;
      }
      
            
      @:isVar public var maximumDotForBlocking(get,set):Float;
public function  get_maximumDotForBlocking() : Float
      {
         return mMaximumDotForBlock;
      }
function  set_maximumDotForBlocking(param1:Float) :Float      {
         return mMaximumDotForBlock = param1;
      }
      
      public function ponderBuffChanges() 
      {
      }
function set_canSuffer(value:Bool):Bool{
	return value;
}   }


