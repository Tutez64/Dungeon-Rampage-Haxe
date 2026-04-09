package combat.weapon
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import combat.attack.AttackTimeline;
   import combat.attack.PotentialWeaponInputQueueStruct;
   import combat.attack.ScriptTimeline;
   import distributedObjects.HeroGameObjectOwner;
   import events.FirstCooldownEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   
    class WeaponController
   {
      
      static inline final RAMPAGE_ATTACK_CONSTANT= "RAMPAGE";
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mWeapon:WeaponGameObject;
      
      var mHero:HeroGameObjectOwner;
      
      var mCurrentAttackTimeline:AttackTimeline;
      
      var mNextAttackComboIndex:Int = 0;
      
      var mAttackArray:Array<ASAny>;
      
      var mAutoAim:Bool = false;
      
      var mWeaponDownActive:Bool = false;
      
      var mCoolDownTime:Float = Math.NaN;
      
      var mIsInCooldown:Bool = false;
      
      var mTimeStartedAttack:Float = Math.NaN;
      
      var mQueueAttack:GMAttack;
      
      public function new(param1:DBFacade, param2:WeaponGameObject, param3:HeroGameObjectOwner)
      {
         
         mDBFacade = param1;
         mWeapon = param2;
         mHero = param3;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mQueueAttack = null;
         buildAttackArray();
      }
      
      public function reset() 
      {
         resetCombos();
         stopCurrentTimeline();
         clear();
      }
      
      public function clear() 
      {
      }
      
      function buildAttacks() 
      {
         buildAttackArray();
      }
      
      function stopCurrentTimeline() 
      {
         if(mCurrentAttackTimeline != null && mCurrentAttackTimeline.isPlaying)
         {
            mCurrentAttackTimeline.stopAndFinish();
         }
         mCurrentAttackTimeline = null;
      }
      
      @:isVar public var IsInCooldown(get,never):Bool;
public function  get_IsInCooldown() : Bool
      {
         if(mIsInCooldown)
         {
            mDBFacade.hud.isInCooldown();
         }
         return mIsInCooldown;
      }
      
      function attack(param1:UInt, param2:Bool, param3:Float = 1, param4:Bool = true) 
      {
         var speedIndex:UInt;
         var actorAttackSpeed:Float;
         var buffMult:Float;
         var baseAttackSpeed:Float;
         var stopCallback:ASFunction;
         var attackType= param1;
         var autoAim= param2;
         var attackSpeedModifier= param3;
         var autoStartCooldown= param4;
         var gmAttack= ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(attackType), gameMasterDictionary.GMAttack);
         var attackSpeedMultiplier:Float = 1;
         var trueManaCosts= gmAttack.ManaCost;
         if(gmAttack.StatOffsets != null)
         {
            trueManaCosts = gmAttack.ManaCost * mWeapon.manaCostModifier;
         }
         if(mHero.manaPoints < trueManaCosts)
         {
            notEnoughMana();
            return;
         }
         if(gmAttack.StatOffsets != null)
         {
            speedIndex = (Std.int(gmAttack.StatOffsets.speed) : UInt);
            actorAttackSpeed = mHero.stats.values[(speedIndex : Int)];
            buffMult = mHero.buffHandler.multiplier.values[(speedIndex : Int)];
            baseAttackSpeed = gmAttack.AttackSpdF;
            attackSpeedMultiplier = baseAttackSpeed * actorAttackSpeed * buffMult * mWeapon.finalWeaponSpeedWithModifiers(Std.int(gmAttack.StatOffsets.type));
            attackSpeedMultiplier *= attackSpeedModifier;
         }
         stopCurrentTimeline();
         mCurrentAttackTimeline = mWeapon.getAttackTimeline(attackType);
         if(mCurrentAttackTimeline == null)
         {
            Logger.error("AttackTimeline for attack: <" + attackType + "> was null. Ignoring onWeaponDown");
            return;
         }
         stopCallback = function()
         {
            mCurrentAttackTimeline = null;
         };
         mHero.attack(attackType,null,attackSpeedMultiplier,mCurrentAttackTimeline,function()
         {
            finishedAttack(autoAim,(Std.int(attackSpeedModifier) : UInt));
         },stopCallback,false,autoAim);
         if(autoStartCooldown && gmAttack.CooldownLength > 0)
         {
            startCooldown();
         }
      }
      
      function finishedAttack(param1:Bool, param2:UInt) 
      {
         if(mQueueAttack != null)
         {
            attack(mQueueAttack.Id,param1,param2);
            mQueueAttack = null;
         }
      }
      
      public function doQueue() 
      {
         if(mQueueAttack != null)
         {
            attack(mQueueAttack.Id,false,1);
            mQueueAttack = null;
         }
      }
      
      public function startCooldown() 
      {
         mIsInCooldown = true;
         var _loc1_= ASCompat.floatAsBool(currentTimeline.currentGMAttack.CooldownLength) ? currentTimeline.currentGMAttack.CooldownLength : currentTimeline.currentGMAttack.AIRechargeT;
         mCoolDownTime = _loc1_ * 1000 * weapon.cooldownReduction() - _loc1_ * 1000 * mHero.attackCooldownMultiplier;
         mTimeStartedAttack = mLogicalWorkComponent.gameClock.gameTime;
         updateHudCooldown(true);
         mLogicalWorkComponent.doEveryFrame(updateCooldown);
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
         {
            mDBFacade.eventManager.dispatchEvent(new FirstCooldownEvent());
         }
      }
      
      public function updateCooldown(param1:GameClock) 
      {
         if(param1.gameTime - mTimeStartedAttack >= mCoolDownTime)
         {
            mIsInCooldown = false;
            mLogicalWorkComponent.clear();
            updateHudCooldown(false);
         }
      }
      
      function updateHudCooldown(param1:Bool) 
      {
         if(param1)
         {
            mDBFacade.hud.startCooldown(weapon.slot,mCoolDownTime / 1000);
         }
         else
         {
            mDBFacade.hud.stopCooldown(weapon.slot);
         }
      }
      
      function getNextAttackId() : UInt
      {
         var _loc2_= 0;
         var _loc1_= getAttackFromComboArray();
         if(_loc1_ == null)
         {
            _loc2_ = 0;
         }
         else
         {
            _loc2_ = (_loc1_.Id : Int);
         }
         return (_loc2_ : UInt);
      }
      
      function buildAttackArray() 
      {
         var _loc3_:GMAttack = null;
         mAttackArray = [];
         var _loc1_:Array<ASAny> = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemByConstant.itemFor(mWeapon.weaponData.Constant).AttackArray, Array);
         var _loc2_:ASAny;
         if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
         {
            _loc2_ = _tmp_;
            if(_loc2_ == null)
            {
               break;
            }
            _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc2_) , GMAttack);
            if(_loc3_ == null)
            {
               Logger.error("Could not find gmAttack for string name: " + Std.string(_loc2_) + ".  For weaponId: " + mWeapon.weaponData.Id);
            }
            else
            {
               mAttackArray.push(_loc3_);
            }
         }
         if(mAttackArray.length == 0)
         {
            Logger.warn("Did not find any attacks for weaponId: " + mWeapon.weaponData.Id);
         }
      }
      
      public function resetCombos() 
      {
         mNextAttackComboIndex = 0;
      }
      
      function getAttackFromComboArray() : GMAttack
      {
         var _loc1_= (Std.int(!mWeapon.weaponData.ChooseRandomAttack ? mNextAttackComboIndex : mAttackArray.length * Math.random() - 1) : UInt);
         var _loc2_= ASCompat.dynamicAs(mAttackArray[(_loc1_ : Int)], gameMasterDictionary.GMAttack);
         if(_loc2_ == null)
         {
            Logger.error("Attack in attack array is null for attack index: " + mNextAttackComboIndex + " on weapon id: " + mWeapon.weaponData.Id + " Array Size: " + mAttackArray.length);
         }
         incrementCombo();
         return _loc2_;
      }
      
      function incrementCombo() 
      {
         mNextAttackComboIndex = mNextAttackComboIndex + 1;
         if(mNextAttackComboIndex >= mAttackArray.length)
         {
            mNextAttackComboIndex = 0;
         }
      }
      
      public function canQueue(param1:PotentialWeaponInputQueueStruct, param2:Float) : Bool
      {
         if(mIsInCooldown)
         {
            return false;
         }
         if(this.currentTimeline == null)
         {
            return true;
         }
         if(mWeaponDownActive)
         {
            if(param1.weaponController == this && !param1.down)
            {
               return true;
            }
         }
         else if(this.currentTimeline.getPercentageOfTimelinePlayed() >= param2)
         {
            return true;
         }
         return false;
      }
      
      public function canCombo() : Bool
      {
         if(mCurrentAttackTimeline != null)
         {
            if(mCurrentAttackTimeline.isAttackWithinComboWindow())
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function berserkModeStart() 
      {
         if(mWeapon.weaponData.ClassType == "MELEE")
         {
            overrideAttacksWithRampage();
         }
      }
      
      public function berserkModeEnd() 
      {
         buildAttacks();
      }
      
      function overrideAttacksWithRampage() 
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor("RAMPAGE"), gameMasterDictionary.GMAttack);
         if(_loc1_ == null)
         {
            Logger.error("Could not find rampage attack by constant for constant: RAMPAGE. Will not override attacks.");
            return;
         }
         mAttackArray = [];
         mAttackArray.push(_loc1_);
         mNextAttackComboIndex = 0;
      }
      
      function notEnoughMana() 
      {
         mHero.distributedDungeonFloor.effectManager.playNotEnoughManaEffects();
      }
      
      public function onWeaponDown(param1:Bool = true) 
      {
         mAutoAim = param1;
      }
      
      @:isVar public var weaponDownActive(get,never):Bool;
public function  get_weaponDownActive() : Bool
      {
         return mWeaponDownActive;
      }
      
      public function onWeaponUp(param1:Bool = true) 
      {
         mAutoAim = param1;
      }
      
      @:isVar public var weapon(get,never):WeaponGameObject;
public function  get_weapon() : WeaponGameObject
      {
         return mWeapon;
      }
      
      @:isVar public var currentTimeline(get,never):ScriptTimeline;
public function  get_currentTimeline() : ScriptTimeline
      {
         return mCurrentAttackTimeline;
      }
      
      @:isVar public var weaponRange(get,never):UInt;
public function  get_weaponRange() : UInt
      {
         return (0 : UInt);
      }
      
      public function queueAttack(param1:String) 
      {
         mQueueAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(param1), gameMasterDictionary.GMAttack);
         if(mQueueAttack == null)
         {
            Logger.error("Queue Attack doesn\'t exist!");
         }
      }
      
      public function isRepeater() : Bool
      {
         return false;
      }
      
      public function destroy() 
      {
         mIsInCooldown = false;
      }
   }


