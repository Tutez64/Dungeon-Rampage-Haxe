package combat.weapon
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import combat.attack.AttackTimeline;
   import distributedObjects.HeroGameObjectOwner;
   import events.FirstRepeaterEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   
    class RepeaterWeaponController extends ScalingWeaponController
   {
      
      var mCount:UInt = (0 : UInt);
      
      var mTotalFramesForAttackTimeline:UInt = (0 : UInt);
      
      var mAttackSpeed:Float = 0;
      
      var mMaxSpeedReached:Bool = false;
      
      var mChargeAttack:GMAttack;
      
      var mRepeatChargeAttackOnly:Bool = false;
      
      var mInRepeaterMode:Bool = false;
      
      var mLastComboReached:Bool = false;
      
      public function new(param1:DBFacade, param2:WeaponGameObject, param3:HeroGameObjectOwner)
      {
         super(param1,param2,param3);
      }
      
      override public function setTotalTime() 
      {
         mTotalTime = 0;
      }
      
      override public function isRepeater() : Bool
      {
         return true;
      }
      
      override public function onWeaponDown(param1:Bool = true) 
      {
         var attackType:UInt;
         var attackTimeLine:AttackTimeline;
         var autoAim= param1;
         super.onWeaponDown(autoAim);
         mInRepeaterMode = false;
         attackType = getNextAttackId();
         attackTimeLine = mWeapon.getAttackTimeline(attackType);
         mTotalFramesForAttackTimeline = attackTimeLine.totalFrames;
         mRepeatChargeAttackOnly = mWeapon.weaponData.RepeaterOnlyChargeRepeated;
         resetData();
         mScalingLogicalWorkComponent.doLater(0.1,function(param1:GameClock)
         {
            if(mChargeReleaseGMAttack != null)
            {
               mChargeAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mChargeReleaseGMAttack.Id), gameMasterDictionary.GMAttack);
               if(mChargeAttack == null)
               {
                  Logger.error("Invalid Charge for Repeater : " + mChargeReleaseGMAttack.Constant);
               }
            }
            mInRepeaterMode = true;
            mNextAttackComboIndex = 0;
            mLastComboReached = false;
            mScalingLogicalWorkComponent.doEveryFrame(update);
         });
      }
      
      function resetData() 
      {
         mCount = (0 : UInt);
         mAttackSpeed = 1;
         mMaxSpeedReached = false;
      }
      
      override public function update(param1:GameClock) 
      {
         var attackId:UInt;
         var gmAttack:GMAttack;
         var gameClock= param1;
         if(canCombo() && (mChargeAttack == null || mChargeAttack.ManaCost <= mHero.manaPoints))
         {
            if(mChargeReleaseGMAttack != null && (mLastComboReached || mRepeatChargeAttackOnly))
            {
               attackId = mChargeReleaseGMAttack.Id;
               mNextAttackComboIndex = 0;
               mLastComboReached = false;
            }
            else
            {
               if(mNextAttackComboIndex == mAttackArray.length - 1)
               {
                  mLastComboReached = true;
               }
               attackId = getNextAttackId();
            }
            gmAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(attackId), gameMasterDictionary.GMAttack);
            if(!mMaxSpeedReached)
            {
               mAttackSpeed = 1 + ++mCount * mWeapon.weaponData.RepeaterIncrementSpeedPercent;
               if(mAttackSpeed >= mWeapon.weaponData.RepeaterMaxSpeedPercent)
               {
                  mAttackSpeed = mWeapon.weaponData.RepeaterMaxSpeedPercent;
                  mMaxSpeedReached = true;
               }
            }
            if(gmAttack.ManaCost > mHero.manaPoints)
            {
               if(mNotEnoughManaTask == null)
               {
                  mNotEnoughManaTask = mScalingLogicalWorkComponent.doLater(NOT_ENOUGH_MANA_ON_CHARGE_DELAY,function(param1:GameClock)
                  {
                     notEnoughMana();
                  });
               }
               resetData();
            }
            else
            {
               attack(attackId,mAutoAim,mAttackSpeed);
            }
         }
      }
      
      override public function onWeaponUp(param1:Bool = true) 
      {
         var _loc2_= 0;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasRepeaterTutorialParam() && !mTutorialMessageSent)
         {
            mDBFacade.eventManager.dispatchEvent(new FirstRepeaterEvent());
            mTutorialMessageSent = true;
         }
         if(!mInRepeaterMode)
         {
            _loc2_ = (getNextAttackId() : Int);
            attack((_loc2_ : UInt),mAutoAim);
         }
         clear();
      }
   }


