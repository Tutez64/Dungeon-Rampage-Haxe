package combat.attack
;
   import actor.buffs.BuffHandler;
   import actor.player.HeroView;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import combat.weapon.ChargeWeaponController;
   import combat.weapon.ConsumableWeaponController;
   import combat.weapon.ConsumableWeaponGameObject;
   import combat.weapon.RepeaterWeaponController;
   import combat.weapon.ScalingWeaponController;
   import combat.weapon.ShieldWeaponController;
   import combat.weapon.WeaponController;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.HeroGameObjectOwner;
   import events.GameObjectEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMStackable;
   
    class PlayerOwnerAttackController
   {
      
      public static inline final DUNGEON_BUSTER_WEAPON_INDEX= (3 : UInt);
      
      var CHARGE_UP:String = "CHARGE_UP";
      
      var SCALING:String = "SCALING";
      
      var REPEATER:String = "REPEATER";
      
      var SHIELD:String = "BLOCKING";
      
      var mDistributedPlayerOwner:HeroGameObjectOwner;
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mPotentialWeaponInputQueue:Array<ASAny>;
      
      var mQueueNextAttackWindow:Float = Math.NaN;
      
      var mNextWeaponCommand:PotentialWeaponInputQueueStruct;
      
      var mDungeonBusterGMAttack:GMAttack;
      
      var mDungeonBusterAttackTimeline:AttackTimeline;
      
      var mIsDungeonBusterUsed:Bool = false;
      
      var mWeaponControllers:Vector<WeaponController>;
      
      var mConsumableControllers:Vector<ConsumableWeaponController>;
      
      public function new(param1:HeroGameObjectOwner, param2:HeroView, param3:DBFacade)
      {
         
         mDistributedPlayerOwner = param1;
         mDBFacade = param3;
         mPotentialWeaponInputQueue = [];
         mLogicalWorkComponent = new LogicalWorkComponent(param3);
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.BERSERK_MODE_START,mDistributedPlayerOwner.id),berserkModeStart);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.BERSERK_MODE_DONE,mDistributedPlayerOwner.id),berserkModeEnd);
         mIsDungeonBusterUsed = false;
         buildWeaponControllers();
         buildConsumableControllers();
         buildDungeonBuster();
         mQueueNextAttackWindow = mDBFacade.dbConfigManager.getConfigNumber("QUEUE_NEXT_ATTACK_WINDOW",0.4);
      }
      
      function buildWeaponControllers() 
      {
         var _loc3_:WeaponController = null;
         mWeaponControllers = new Vector<WeaponController>();
         var _loc2_= (0 : UInt);
         var _loc1_:WeaponGameObject;
         final __ax4_iter_41 = mDistributedPlayerOwner.weapons;
         if (checkNullIteratee(__ax4_iter_41)) for (_tmp_ in __ax4_iter_41)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc3_ = determineWeaponController(_loc1_);
            }
            else
            {
               _loc3_ = null;
            }
            mWeaponControllers.push(_loc3_);
            _loc2_++;
         }
      }
      
      function buildConsumableControllers() 
      {
         var _loc1_:ConsumableWeaponController = null;
         mConsumableControllers = new Vector<ConsumableWeaponController>();
         var _loc2_= (0 : UInt);
         var _loc3_:ConsumableWeaponGameObject;
         final __ax4_iter_42 = mDistributedPlayerOwner.consumables;
         if (checkNullIteratee(__ax4_iter_42)) for (_tmp_ in __ax4_iter_42)
         {
            _loc3_ = _tmp_;
            if(_loc3_ != null)
            {
               _loc1_ = new ConsumableWeaponController(mDBFacade,_loc3_,mDistributedPlayerOwner);
            }
            else
            {
               _loc1_ = null;
            }
            mConsumableControllers.push(_loc1_);
            _loc2_++;
         }
      }
      
      function determineWeaponController(param1:WeaponGameObject) : WeaponController
      {
         var _loc2_:WeaponController = null;
         switch(param1.weaponData.WeaponController)
         {
            case (_ == CHARGE_UP => true):
               _loc2_ = new ChargeWeaponController(mDBFacade,param1,mDistributedPlayerOwner);
               
            case (_ == SCALING => true):
               _loc2_ = new ScalingWeaponController(mDBFacade,param1,mDistributedPlayerOwner);
               
            case (_ == REPEATER => true):
               _loc2_ = new RepeaterWeaponController(mDBFacade,param1,mDistributedPlayerOwner);
               
            case (_ == SHIELD => true):
               _loc2_ = new ShieldWeaponController(mDBFacade,param1,mDistributedPlayerOwner);
               
            default:
               Logger.warn("Unable to determine weapon controller for GMWeaponItem.WeaponController: " + param1.weaponData.WeaponController + ".  Using ChargeWeaponController as default.");
               _loc2_ = new ChargeWeaponController(mDBFacade,param1,mDistributedPlayerOwner);
         }
         return _loc2_;
      }
      
      function buildDungeonBuster() 
      {
         var _loc1_= mDistributedPlayerOwner.gMHero.DBuster1;
         mDungeonBusterGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc1_), gameMasterDictionary.GMAttack);
         mDungeonBusterAttackTimeline = mDBFacade.timelineFactory.createAttackTimeline(mDungeonBusterGMAttack.AttackTimeline,null,mDistributedPlayerOwner,mDistributedPlayerOwner.distributedDungeonFloor);
         mDistributedPlayerOwner.maxBusterPoints = mDungeonBusterGMAttack.CrowdCost;
      }
      
      @:isVar public var weaponControllers(get,never):Vector<WeaponController>;
public function  get_weaponControllers() : Vector<WeaponController>
      {
         return mWeaponControllers;
      }
      
      public function scrollWeapons(param1:Bool) 
      {
         if(currentWeaponController.currentTimeline == null)
         {
            if(param1)
            {
               equipNextWeapon();
            }
            else
            {
               equipPreviousWeapon();
            }
         }
      }
      
      function equipNextWeapon() 
      {
         var _loc2_= this.mDistributedPlayerOwner.currentWeaponIndex;
         var _loc1_= _loc2_ + 1;
         while(_loc2_ != _loc1_)
         {
            if(_loc1_ >= mWeaponControllers.length)
            {
               _loc1_ = 0;
            }
            if(mWeaponControllers[_loc1_] != null)
            {
               mDistributedPlayerOwner.currentWeaponIndex = _loc1_;
               return;
            }
            _loc1_++;
         }
      }
      
      function equipPreviousWeapon() 
      {
         var _loc2_= this.mDistributedPlayerOwner.currentWeaponIndex;
         var _loc1_= _loc2_ - 1;
         while(_loc2_ != _loc1_)
         {
            if(_loc1_ < 0)
            {
               _loc1_ = mWeaponControllers.length - 1;
            }
            if(mWeaponControllers[_loc1_] != null)
            {
               mDistributedPlayerOwner.currentWeaponIndex = _loc1_;
               return;
            }
            _loc1_--;
         }
      }
      
      public function playDungeonBusterAttack() 
      {
         if(mDistributedPlayerOwner.stateMachine.currentStateName == "ActorDefaultState" && mDistributedPlayerOwner.canInitiateAnAttack)
         {
            if(mDungeonBusterAttackTimeline == null)
            {
               buildDungeonBuster();
            }
            mNextWeaponCommand = null;
            mDistributedPlayerOwner.attack(mDungeonBusterGMAttack.Id,null,mDungeonBusterGMAttack.AttackSpdF,mDungeonBusterAttackTimeline);
            mDBFacade.hud.hideBustSign();
         }
      }
      
      public function canPlayDungeonBusterAttack() : Bool
      {
         if(mDistributedPlayerOwner.dungeonBusterPoints >= mDistributedPlayerOwner.maxBusterPoints)
         {
            return true;
         }
         return false;
      }
      
      public function addToPotentialWeaponInputQueue(param1:UInt, param2:Bool, param3:Bool) 
      {
         if(mDungeonBusterAttackTimeline != null && mDungeonBusterAttackTimeline.isPlaying)
         {
            return;
         }
         if(param1 == 3 && canPlayDungeonBusterAttack())
         {
            mPotentialWeaponInputQueue.length;
            mPotentialWeaponInputQueue[0] = new PotentialWeaponInputQueueStruct(mWeaponControllers[(param1 : Int)],param1,param2,param3);
         }
         else
         {
            mPotentialWeaponInputQueue.push(new PotentialWeaponInputQueueStruct(mWeaponControllers[(param1 : Int)],param1,param2,param3));
         }
      }
      
      public function weaponCommandQueueUpCall() 
      {
         var _loc2_:PotentialWeaponInputQueueStruct = null;
         var _loc1_= false;
         while(mPotentialWeaponInputQueue.length > 0)
         {
            _loc2_ = ASCompat.dynamicAs(mPotentialWeaponInputQueue[0], combat.attack.PotentialWeaponInputQueueStruct);
            _loc1_ = false;
            if(_loc2_.weaponIndex == 3 && canPlayDungeonBusterAttack())
            {
               mNextWeaponCommand = new PotentialWeaponInputQueueStruct(_loc2_.weaponController,_loc2_.weaponIndex,_loc2_.down,_loc2_.autoAim);
               _loc1_ = true;
               break;
            }
            if(_loc2_.down)
            {
               _loc1_ = canQueueWeaponDown(_loc2_);
            }
            else
            {
               _loc1_ = canQueueWeaponUp(_loc2_);
            }
            if(_loc1_)
            {
               mNextWeaponCommand = _loc2_;
            }
            mPotentialWeaponInputQueue.shift();
         }
         tryAttack();
         mPotentialWeaponInputQueue.resize(0);
      }
      
      function canQueueWeaponDown(param1:PotentialWeaponInputQueueStruct) : Bool
      {
         if(mNextWeaponCommand != null || currentWeaponController.weaponDownActive || param1.weaponController != null && param1.weaponController.IsInCooldown)
         {
            return false;
         }
         return true;
      }
      
      function canQueueWeaponUp(param1:PotentialWeaponInputQueueStruct) : Bool
      {
         if(mNextWeaponCommand != null && mNextWeaponCommand.down && mNextWeaponCommand.weaponController == param1.weaponController)
         {
            mNextWeaponCommand = null;
         }
         else if(mNextWeaponCommand != null)
         {
            return false;
         }
         if(param1.weaponController != null && param1.weaponController.IsInCooldown)
         {
            return false;
         }
         if(currentWeaponController.currentTimeline == null)
         {
            return true;
         }
         return currentWeaponController.canQueue(param1,mQueueNextAttackWindow);
      }
      
      @:isVar var currentWeaponController(get,never):WeaponController;
function  get_currentWeaponController() : WeaponController
      {
         return mWeaponControllers[mDistributedPlayerOwner.currentWeaponIndex];
      }
      
      function tryAttack() 
      {
         var _loc1_:ScriptTimeline = null;
         if(mNextWeaponCommand == null)
         {
            return;
         }
         if(mDungeonBusterAttackTimeline != null && mDungeonBusterAttackTimeline.isPlaying)
         {
            mNextWeaponCommand = null;
            return;
         }
         var _loc2_= false;
         var _loc3_= mNextWeaponCommand.weaponController;
         if(mDistributedPlayerOwner.stateMachine.currentStateName == "ActorDefaultState" && mDistributedPlayerOwner.canInitiateAnAttack)
         {
            if(mNextWeaponCommand.weaponIndex == 3)
            {
               if(mDistributedPlayerOwner.dungeonBusterPoints >= mDistributedPlayerOwner.maxBusterPoints)
               {
                  playDungeonBusterAttack();
               }
               mNextWeaponCommand = null;
               return;
            }
            _loc1_ = currentWeaponController.currentTimeline;
            if(mNextWeaponCommand.down)
            {
               if(_loc1_ == null)
               {
                  _loc2_ = true;
               }
            }
            else if(_loc1_ == null)
            {
               _loc2_ = true;
            }
            else if(currentWeaponController.isRepeater() && currentWeaponController.weaponDownActive || currentWeaponController.canCombo())
            {
               _loc2_ = true;
            }
            else
            {
               _loc2_ = false;
            }
         }
         else
         {
            mNextWeaponCommand = null;
         }
         if(_loc1_ == null)
         {
            resetCombosOnAllBut();
         }
         if(_loc2_)
         {
            if(mNextWeaponCommand.down)
            {
               onWeaponDown(mNextWeaponCommand.weaponIndex,mNextWeaponCommand.autoAim);
            }
            else
            {
               onWeaponUp(mNextWeaponCommand.weaponIndex,mNextWeaponCommand.autoAim);
            }
            mNextWeaponCommand = null;
         }
      }
      
      public function isCharging() : Bool
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mWeaponControllers.length)
         {
            if(mWeaponControllers[_loc1_] != null && mWeaponControllers[_loc1_].weaponDownActive)
            {
               return true;
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
         return false;
      }
      
      public function onWeaponDown(param1:UInt, param2:Bool) 
      {
         var _loc3_= mDistributedPlayerOwner.weaponControllers[(param1 : Int)];
         if(_loc3_ != null)
         {
            mDistributedPlayerOwner.currentWeaponIndex = (param1 : Int);
            _loc3_.onWeaponDown(param2);
         }
      }
      
      public function onWeaponUp(param1:UInt, param2:Bool) 
      {
         var _loc3_= mDistributedPlayerOwner.weaponControllers[(param1 : Int)];
         if(_loc3_ != null)
         {
            mDistributedPlayerOwner.heading = mDistributedPlayerOwner.inputHeading;
            _loc3_.onWeaponUp(param2);
            mDistributedPlayerOwner.currentWeaponIndex = (param1 : Int);
         }
      }
      
      public function resetCombosOnAllBut(param1:UInt = null) 
{
         if (param1 == null) param1 = (Std.int(4294967295) : UInt);
         var _loc2_= 0;
         var _loc3_:WeaponController = null;
         _loc2_ = 0;
         while(_loc2_ < mWeaponControllers.length)
         {
            if((_loc2_ : UInt) != param1)
            {
               _loc3_ = mWeaponControllers[_loc2_];
               if(_loc3_ != null)
               {
                  _loc3_.resetCombos();
               }
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function resetWeapons() 
      {
         var _loc1_= 0;
         var _loc2_:WeaponController = null;
         mPotentialWeaponInputQueue.resize(0);
         _loc1_ = 0;
         while(_loc1_ < mWeaponControllers.length)
         {
            _loc2_ = mWeaponControllers[_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.reset();
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function playPotentialPotionAttack(param1:UInt) 
      {
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(param1), gameMasterDictionary.GMStackable);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc2_= _loc3_.UsageAttack;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc4_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc2_), gameMasterDictionary.GMAttack);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc6_= mDBFacade.timelineFactory.createAttackTimeline(_loc4_.AttackTimeline,mDistributedPlayerOwner.currentWeapon,mDistributedPlayerOwner,mDistributedPlayerOwner.distributedDungeonFloor);
         var _loc7_:Float = mDistributedPlayerOwner.currentWeapon.getAttackTimeline(_loc4_.Id).totalFrames;
         var _loc5_= _loc4_.AttackSpdF;
         if(_loc5_ > 0)
         {
            mDistributedPlayerOwner.attack(_loc4_.Id,null,_loc4_.AttackSpdF,_loc6_);
         }
      }
      
      function berserkModeStart(param1:GameObjectEvent) 
      {
         var _loc2_:ChargeWeaponController = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < mWeaponControllers.length)
         {
            _loc2_ = ASCompat.reinterpretAs(mWeaponControllers[_loc3_] , ChargeWeaponController);
            if(_loc2_ != null)
            {
               _loc2_.berserkModeStart();
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      function berserkModeEnd(param1:GameObjectEvent) 
      {
         var _loc2_:ChargeWeaponController = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < mWeaponControllers.length)
         {
            _loc2_ = ASCompat.reinterpretAs(mWeaponControllers[_loc3_] , ChargeWeaponController);
            if(_loc2_ != null)
            {
               _loc2_.berserkModeEnd();
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      public function tryToDoConsumableAttack(param1:UInt) 
      {
         if(mConsumableControllers[(param1 : Int)] != null && !mConsumableControllers[(param1 : Int)].IsInCooldown)
         {
            mConsumableControllers[(param1 : Int)].consume();
         }
      }
      
      public function stopAttacking() 
      {
         mNextWeaponCommand = null;
         mPotentialWeaponInputQueue.resize(0);
      }
      
      public function clearInput() 
      {
         stopAttacking();
         var _loc1_:WeaponController;
         final __ax4_iter_43 = weaponControllers;
         if (checkNullIteratee(__ax4_iter_43)) for (_tmp_ in __ax4_iter_43)
         {
            _loc1_ = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.reset();
            }
         }
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mWeaponControllers.length)
         {
            if(mWeaponControllers[_loc1_] != null)
            {
               mWeaponControllers[_loc1_].destroy();
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mConsumableControllers.length)
         {
            if(mConsumableControllers[_loc1_] != null)
            {
               mConsumableControllers[_loc1_].destroy();
            }
            _loc1_++;
         }
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
      }
   }


