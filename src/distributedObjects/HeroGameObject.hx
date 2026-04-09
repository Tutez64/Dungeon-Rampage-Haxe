package distributedObjects
;
   import actor.ActorData;
   import actor.ActorGameObject;
   import actor.HeroData;
   import actor.player.HeroStateMachine;
   import actor.player.HeroView;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import combat.attack.AttackTimeline;
   import combat.weapon.ConsumableWeaponGameObject;
   import events.BusterPointsEvent;
   import events.ExperienceEvent;
   import events.FacebookLevelUpPostEvent;
   import events.GameObjectEvent;
   import events.HpEvent;
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
   
    class HeroGameObject extends ActorGameObject implements IHeroGameObject
   {
      
      public static inline final LEGENDARY_MOD_STAMINA= (1 : UInt);
      
      public static inline final LEGENDARY_MOD_APTITUDE= (2 : UInt);
      
      public static inline final LEGENDARY_MOD_ACCELERATION= (3 : UInt);
      
      public static inline final MAX_HEALTH_BOMBS_PER_DUNGEON= (3 : UInt);
      
      public static inline final MAX_PARTY_BOMBS_PER_DUNGEON= (3 : UInt);
      
      var mHeroGameObjectNetworkComponent:HeroGameObjectNetworkComponent;
      
      var mCanMove:Bool = true;
      
      var mMana:UInt = 0;
      
      var mMaxBusterPoints:UInt = (Std.int(4294967295) : UInt);
      
      var mBusterPoints:UInt = 0;
      
      var mExperiencePoints:UInt = 0;
      
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
      
      var mStaminaModMultiplier:Float = Math.NaN;
      
      var mAptitudeModMultiplier:Float = Math.NaN;
      
      var mAccelerationModMultiplier:Float = Math.NaN;
      
      var mConsumableDetails:Vector<ConsumableDetails>;
      
      var mConsumableWeapons:Vector<ConsumableWeaponGameObject>;
      
      public function new(param1:DBFacade, param2:UInt)
      {
         super(param1,param2);
         mWantNavCollisions = true;
         mLogicalWorkComponent = new LogicalWorkComponent(mFacade);
         mChatEventComponent = new EventComponent(param1);
         mCanInitiateAnAttack = true;
      }
      
      override function processJsonNavCollisions(param1:Array<ASAny>, param2:ASFunction) 
      {
         super.processJsonNavCollisions(param1,param2);
      }
      
      override function buildView() 
      {
         var _loc1_= new HeroView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"HeroView - created in HeroGameObject.buildView()");
         view = _loc1_;
      }
      
      override public function  set_view(param1:FloorView) :FloorView      {
         mHeroView = ASCompat.reinterpretAs(param1 , HeroView);
         return super.view = param1;
      }
      
      @:isVar public var heroView(get,never):HeroView;
public function  get_heroView() : HeroView
      {
         return mHeroView;
      }
      
      override function buildStateMachine() 
      {
         mHeroStateMachine = new HeroStateMachine(mDBFacade,this,this.mHeroView);
         MemoryTracker.track(mHeroStateMachine,"HeroStateMachine - created in HeroGameObject.buildStateMachine()");
         stateMachine = mHeroStateMachine;
      }
      
      @:isVar public var heroStateMachine(get,never):HeroStateMachine;
public function  get_heroStateMachine() : HeroStateMachine
      {
         return mHeroStateMachine;
      }
      
            
      @:isVar public var canInitiateAnAttack(get,set):Bool;
public function  get_canInitiateAnAttack() : Bool
      {
         return mCanInitiateAnAttack;
      }
function  set_canInitiateAnAttack(param1:Bool) :Bool      {
         return mCanInitiateAnAttack = param1;
      }
      
      public function setNetworkComponentDistributedPlayer(param1:HeroGameObjectNetworkComponent) 
      {
         mHeroGameObjectNetworkComponent = param1;
      }
      
      override public function attack(param1:UInt, param2:ActorGameObject, param3:Float, param4:AttackTimeline, param5:ASFunction = null, param6:ASFunction = null, param7:Bool = false, param8:Bool = false) 
      {
         if(mCanInitiateAnAttack)
         {
            param4.currentAttackType = param1;
            mHeroStateMachine.enterChoreographyState(param3,param2,param4,param5,param6,param7,param8);
         }
      }
      
      override public function destroy() 
      {
         mChatEventComponent.destroy();
         mHeroStateMachine.destroy();
         mHeroStateMachine = null;
         mHeroView = null;
         super.destroy();
      }
      
      override function determineState() 
      {
         var _loc1_= mState;
         if("down" != _loc1_)
         {
            super.determineState();
         }
         else
         {
            if(this.heroStateMachine.currentStateName == "ActorReviveState")
            {
               return;
            }
            mHeroStateMachine.enterReviveState();
         }
      }
      
      public function setState(param1:String) 
      {
         state = param1;
      }
      
            
      @:isVar public var skinType(get,set):UInt;
public function  set_skinType(param1:UInt) :UInt      {
         mGMSkin = mDBFacade.gameMaster.getSkinByType(param1);
         if(mGMSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin type: " + param1 + " Loading default skin for heroType: " + type);
            mGMSkin = mDBFacade.gameMaster.getSkinByConstant(gMHero.DefaultSkin);
            if(mGMSkin == null)
            {
               Logger.error("Unable to find default skin with constant: " + gMHero.DefaultSkin);
               return param1;
            }
         }
return param1;
      }
function  get_skinType() : UInt
      {
         return mGMSkin.Id;
      }
      
      override public function  get_gmSkin() : GMSkin
      {
         return mGMSkin;
      }
      
      override function buildActorData() : ActorData
      {
         mHeroData = new HeroData(mDBFacade,this,mGMSkin);
         return mHeroData;
      }
      
            
      @:isVar public var manaPoints(get,set):UInt;
public function  set_manaPoints(param1:UInt) :UInt      {
         mMana = param1;
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,(Std.int(this.maxManaPoints) : UInt)));
return param1;
      }
function  get_manaPoints() : UInt
      {
         return mMana;
      }
      
            
      @:isVar public var experiencePoints(get,set):UInt;
public function  set_experiencePoints(param1:UInt) :UInt      {
         var _loc2_= mLevel;
         mExperiencePoints = param1;
         if(actorData != null)
         {
            this.level = this.gMHero.getLevelFromExp(mExperiencePoints);
         }
         if(mLevel != _loc2_)
         {
            mHeroView.playHeroLevelUpEffects();
            if(Std.isOfType(this , HeroGameObjectOwner))
            {
               mFacade.eventManager.dispatchEvent(new FacebookLevelUpPostEvent("FacebookLevelUpPostEvent",mLevel));
            }
         }
         mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE",id,mExperiencePoints));
return param1;
      }
      
            
      @:isVar public var dungeonBusterPoints(get,set):UInt;
public function  set_dungeonBusterPoints(param1:UInt) :UInt      {
         mBusterPoints = param1;
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
return param1;
      }
function  get_dungeonBusterPoints() : UInt
      {
         return mBusterPoints;
      }
function  get_experiencePoints() : UInt
      {
         return mExperiencePoints;
      }
      
            
      @:isVar public var maxBusterPoints(get,set):UInt;
public function  set_maxBusterPoints(param1:UInt) :UInt      {
         mMaxBusterPoints = param1;
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
return param1;
      }
function  get_maxBusterPoints() : UInt
      {
         return mMaxBusterPoints;
      }
      
      @:isVar public var healthBombUsesRemaining(get,never):Int;
public function  get_healthBombUsesRemaining() : Int
      {
         var _loc1_:Float = 3 - mHealthBombsUsed;
         if(_loc1_ < 0)
         {
            Logger.warn("More healthbombs have been consumed than allowed in limited use dungeons.");
            _loc1_ = 0;
         }
         return Std.int(_loc1_);
      }
      
      @:isVar public var partyBombUsesRemaining(get,never):Int;
public function  get_partyBombUsesRemaining() : Int
      {
         var _loc1_:Float = 3 - mPartyBombsUsed;
         if(_loc1_ < 0)
         {
            Logger.warn("More partybombs have been consumed than allowed in limited use dungeons.");
            _loc1_ = 0;
         }
         return Std.int(_loc1_);
      }
      
      @:isVar public var healthBombsUsed(never,set):UInt;
public function  set_healthBombsUsed(param1:UInt) :UInt      {
         return mHealthBombsUsed = param1;
      }
      
      @:isVar public var partyBombsUsed(never,set):UInt;
public function  set_partyBombsUsed(param1:UInt) :UInt      {
         return mPartyBombsUsed = param1;
      }
      
      public function canUseHealthBombs() : Bool
      {
         if(mDistributedDungeonFloor.isInfiniteDungeon)
         {
            return mHealthBombsUsed < 3;
         }
         return true;
      }
      
      public function canUsePartyBombs() : Bool
      {
         if(mDistributedDungeonFloor.isInfiniteDungeon)
         {
            return mPartyBombsUsed < 3;
         }
         return true;
      }
      
      override public function postGenerate() 
      {
         super.postGenerate();
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,(Std.int(this.maxManaPoints) : UInt)));
         mFacade.eventManager.dispatchEvent(new BusterPointsEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",id,mBusterPoints,mMaxBusterPoints));
         mFacade.eventManager.dispatchEvent(new ExperienceEvent("ExperienceEvent_EXPERIENCE_UPDATE",id,mExperiencePoints));
         mFacade.eventManager.dispatchEvent(new HpEvent("HpEvent_HP_UPDATE",id,mHitPoints,(Std.int(this.maxHitPoints) : UInt)));
         mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",mPlayerID),function(param1:events.ChatEvent)
         {
            Chat(param1.message);
         });
         mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",mPlayerID),function(param1:events.PlayerIsTypingEvent)
         {
            if(param1.subtype == "CHAT_BOX_FOCUS_IN")
            {
               ShowPlayerisTyping(true);
            }
            else
            {
               ShowPlayerisTyping(false);
            }
         });
         processLegendaryModifiers();
      }
      
      public function processLegendaryModifiers() 
      {
         mStaminaModMultiplier = 0;
         mAptitudeModMultiplier = 0;
         mAccelerationModMultiplier = 0;
         var _loc1_:WeaponDetails;
         final __ax4_iter_203 = mWeaponDetails;
         if (checkNullIteratee(__ax4_iter_203)) for (_tmp_ in __ax4_iter_203)
         {
            _loc1_ = _tmp_;
            switch(ASCompat.toInt(_loc1_.legendarymodifier) - 1)
            {
               case 0:
                  mStaminaModMultiplier += ASCompat.toNumber(10 + ASCompat.toNumberField(_loc1_, "requiredlevel") * 0.9);
                  
               case 1:
                  mAptitudeModMultiplier += ASCompat.toNumber(10 + ASCompat.toNumberField(_loc1_, "requiredlevel") * 0.4);
                  
               case 2:
                  mAccelerationModMultiplier += 0.1;
            }
         }
      }
      
      override public function  get_maxHitPoints() : Float
      {
         return this.buffHandler.multiplier.maxHitPoints * (mStats.maxHitPoints + mStaminaModMultiplier);
      }
      
      override public function  get_maxManaPoints() : Float
      {
         return this.buffHandler.multiplier.maxManaPoints * (mStats.maxManaPoints + mAptitudeModMultiplier);
      }
      
      override public function  get_movementSpeed() : Float
      {
         var _loc2_= mStats.movementSpeed;
         var _loc3_= this.buffHandler.multiplier.movementSpeed;
         return _loc2_ * _loc3_ * (1 + mAccelerationModMultiplier);
      }
      
      @:isVar public var slotPoints(never,set):Vector<UInt>;
public function  set_slotPoints(param1:Vector<UInt>) :Vector<UInt>      {
         return mSlotPoints = param1;
      }
      
      public function setNetworkComponentHeroGameObject(param1:HeroGameObjectNetworkComponent) 
      {
      }
      
      override public function  set_stats(param1:StatVector) :StatVector      {
         super.stats = param1;
         mFacade.eventManager.dispatchEvent(new ManaEvent("ManaEvent_MANA_UPDATE",id,mMana,(Std.int(this.maxManaPoints) : UInt)));
return param1;
      }
      
            
      @:isVar public var playerID(get,set):UInt;
public function  set_playerID(param1:UInt) :UInt      {
         return mPlayerID = param1;
      }
function  get_playerID() : UInt
      {
         return mPlayerID;
      }
      
      public function TriggerEffect(param1:String) 
      {
      }
      
      @:isVar public var gMHero(get,never):GMHero;
public function  get_gMHero() : GMHero
      {
         return ASCompat.reinterpretAs(mActorData.gMActor , GMHero);
      }
      
      override function refreshStatVector() 
      {
         var _loc7_:Int;
         var _loc8_:Float;
         var _loc3_= 0;
         var _loc5_= 0;
         var _loc1_= gMHero;
         this.level = _loc1_.getLevelFromExp(mExperiencePoints);
         var _loc2_= new StatVector();
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc1_.UpgradeToSlotOffset[_loc3_].length)
            {
               _loc7_ = _loc1_.UpgradeToSlotOffset[_loc3_][_loc5_];
               _loc8_ = _loc2_.values[_loc7_] + mSlotPoints[_loc3_];
               _loc2_.values[_loc7_] = _loc8_;
               _loc5_++;
            }
            _loc3_++;
         }
         var _loc6_= StatVector.add(mActorData.baseValues,StatVector.multiplyScalar(mActorData.levelValues,mLevel));
         _loc6_ = StatVector.add(_loc6_,StatVector.multiply(_loc1_.Normalized_upgrades,_loc2_));
         var _loc4_= StatVector.add(StatVector.multiply(_loc6_,mDBFacade.gameMaster.stat_BonusMultiplier),mDBFacade.gameMaster.stat_bias);
         mStats = StatVector.clone(_loc4_);
         mStats.values[0] = mActorData.hp + _loc4_.values[0];
         mStats.values[1] = mActorData.mp + _loc4_.values[1];
         mStats.values[13] = _loc1_.BaseMove * _loc4_.values[13];
      }
      
      public function IsInvulnerable() : Bool
      {
         return buffHandler.IsInvulnerable();
      }
      
      public function setStateAndAttackChoreography(param1:String, param2:AttackChoreography) 
      {
         state = param1;
         ReceiveAttackChoreography(param2);
      }
      
      public function StopChoreography() 
      {
         if(this.stateMachine != null && this.stateMachine.currentSubState != null && this.stateMachine.currentSubState.name == "ActorChoreographySubState")
         {
            this.stateMachine.enterNavigationState();
         }
      }
      
      public function PartyBomb(param1:UInt) 
      {
         var _loc3_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(param1) , HeroGameObject);
         var _loc4_= _loc3_.screenName + "\n" + Locale.getString("BOMB_DROPPER");
         var _loc2_= new FloorMessageView(mDBFacade,"",_loc4_.toUpperCase());
         MemoryTracker.track(_loc2_,"FloorMessageView - created in HeroGameObject.on_party_bomb()");
      }
      
      @:isVar public var consumableDetails(never,set):Vector<ConsumableDetails>;
public function  set_consumableDetails(param1:Vector<ConsumableDetails>) :Vector<ConsumableDetails>      {
         mConsumableDetails = param1;
         var _loc5_= (0 : UInt);
         var _loc2_= (0 : UInt);
         var _loc4_= (0 : UInt);
         var _loc3_= (0 : UInt);
         if(param1.length > 0)
         {
            _loc5_ = param1[0].type;
            _loc2_ = param1[0].count;
         }
         if(param1.length > 1)
         {
            _loc4_ = param1[1].type;
            _loc3_ = param1[1].count;
         }
         if(mActorData != null && mDistributedDungeonFloor != null)
         {
            setupConsumables();
         }
return param1;
      }
      
      override function setupConsumables() 
      {
         var _loc4_:ConsumableWeaponGameObject = null;
         var _loc2_:ConsumableWeaponGameObject;
         final __ax4_iter_204 = mConsumableWeapons;
         if (checkNullIteratee(__ax4_iter_204)) for (_tmp_ in __ax4_iter_204)
         {
            _loc2_ = _tmp_;
            if(_loc2_ != null)
            {
               _loc2_.destroy();
            }
         }
         var _loc1_= (0 : UInt);
         mConsumableWeapons = new Vector<ConsumableWeaponGameObject>();
         var _loc3_:ConsumableDetails;
         final __ax4_iter_205 = mConsumableDetails;
         if (checkNullIteratee(__ax4_iter_205)) for (_tmp_ in __ax4_iter_205)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toNumberField(_loc3_, "type") != 0)
            {
               _loc4_ = new ConsumableWeaponGameObject(_loc3_,this,mActorView,mDBFacade,mDistributedDungeonFloor,_loc1_);
               MemoryTracker.track(_loc4_,"ConsumableWeaponGameObject - created in HeroGameObject.setupConsumables()");
               mConsumableWeapons.push(_loc4_);
            }
            else
            {
               mConsumableWeapons.push(null);
            }
            _loc1_++;
         }
      }
      
      @:isVar public var consumables(get,never):Vector<ConsumableWeaponGameObject>;
public function  get_consumables() : Vector<ConsumableWeaponGameObject>
      {
         return mConsumableWeapons;
      }
      
      override public function  get_attackCooldownMultiplier() : Float
      {
         var _loc1_:GMSuperStat = null;
         if(gMHero.StatUpgrade3 == "MAGIC_COOLDOWN")
         {
            _loc1_ = ASCompat.dynamicAs(mDBFacade.gameMaster.superStatByConstant.itemFor(gMHero.StatUpgrade3), gameMasterDictionary.GMSuperStat);
            return 0.01 * (mSlotPoints[2] * gMHero.AmtStat3 * _loc1_.CooldownReduction);
         }
         return buffHandler.attackCooldownMultiplier - 1;
      }
   }


