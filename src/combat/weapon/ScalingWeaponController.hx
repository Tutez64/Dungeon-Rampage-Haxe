package combat.weapon
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import combat.attack.AttackTimeline;
   import distributedObjects.HeroGameObjectOwner;
   import events.FirstScalingEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMModifier;

    class ScalingWeaponController extends WeaponController
   {

      public static inline final SCALING_EFFECT_SWF= "Resources/Art2D/FX/db_fx_library.swf";

      var mPowerMultiplier:Float = 1;

      var mProjectileMinMultiplier:UInt = (1 : UInt);

      var mProjectileMaxMultiplier:UInt = (1 : UInt);

      var mProjectileStartScalingAngle:Float = 0;

      var mProjectileEndScalingAngle:Float = 20;

      var mProjectileScaleTapAttack:Bool = false;

      var mDistanceScalingTime:Float = 0;

      var mDistanceScalingForHeroMin:Float = 0;

      var mDistanceScalingForHeroMax:Float = 0;

      var mDistanceScalingForProjectilesMin:Float = 0;

      var mDistanceScalingForProjectilesMax:Float = 0;

      var mTotalTime:Float = 0;

      var mFramesFinished:Float = 0;

      var mPlayerExittedState:Bool = false;

      var mChargeReleaseGMAttack:GMAttack;

      var NOT_ENOUGH_MANA_ON_CHARGE_DELAY:Float = 0.2;

      var mNotEnoughManaTask:Task;

      var mScalingLogicalWorkComponent:LogicalWorkComponent;

      var mHoldingAttack:GMAttack;

      var mHoldingAttackTimeline:AttackTimeline;

      var mTutorialMessageSent:Bool = false;

      public function new(param1:DBFacade, param2:WeaponGameObject, param3:HeroGameObjectOwner)
      {
         super(param1,param2,param3);
         buildControllerAttacks();
      }

      public function buildControllerAttacks()
      {
         mScalingLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ScalingWeaponController");
         mHoldingAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(mWeapon.weaponData.HoldingAttack), gameMasterDictionary.GMAttack);
         if(mHoldingAttack != null)
         {
            mHoldingAttackTimeline = mWeapon.getAttackTimeline(mHoldingAttack.Id);
         }
         setAttributes();
      }

      public function setAttributes()
      {
         mPowerMultiplier = mWeapon.weaponData.ScalingMaxPowerMultiplier;
         mProjectileScaleTapAttack = mWeapon.weaponData.ScaleTapAttack;
         mProjectileMinMultiplier = mWeapon.weaponData.ScalingMinProjectiles;
         mProjectileMaxMultiplier = mWeapon.weaponData.ScalingMaxProjectiles;
         mProjectileStartScalingAngle = mWeapon.weaponData.ScalingProjectileStartAngle;
         mProjectileEndScalingAngle = mWeapon.weaponData.ScalingProjectileEndAngle;
         mDistanceScalingTime = mWeapon.weaponData.ScalingDistanceTime;
         mDistanceScalingForHeroMin = mWeapon.weaponData.ScalingHeroMinDistance;
         mDistanceScalingForHeroMax = mWeapon.weaponData.ScalingHeroMaxDistance;
         mDistanceScalingForProjectilesMin = mWeapon.weaponData.ScalingProjectileMinDistance;
         mDistanceScalingForProjectilesMax = mWeapon.weaponData.ScalingProjectileMaxDistance;
         var _loc1_= mWeapon.weaponData.ChargeAttack;
         mChargeReleaseGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(_loc1_), gameMasterDictionary.GMAttack);
         setTotalTime();
      }

      public function setTotalTime()
      {
         mTotalTime = mWeapon.weaponData.ControllerTimeTillEnd;
         if(mTotalTime == 0)
         {
            Logger.error("Weapon has no ControllerTimeTillEnd data set !");
         }
      }

      public function setStartEffectTotalTime() : Float
      {
         return 1.2;
      }

      public function startHoldingAttack()
      {
         var _loc1_= 1 / mTotalTime * setStartEffectTotalTime();
         attack(mHoldingAttack.Id,mAutoAim,_loc1_);
      }

      override public function onWeaponDown(param1:Bool = true)
      {
         var autoAim= param1;
         if(!mWeaponDownActive)
         {
            super.onWeaponDown(autoAim);
            mFramesFinished = 0;
            mWeaponDownActive = true;
            mScalingLogicalWorkComponent.clear();
            if(mTotalTime > 0)
            {
               if(mChargeReleaseGMAttack != null && mChargeReleaseGMAttack.ManaCost > mHero.manaPoints)
               {
                  if(mNotEnoughManaTask == null)
                  {
                     mNotEnoughManaTask = mScalingLogicalWorkComponent.doLater(NOT_ENOUGH_MANA_ON_CHARGE_DELAY,function(param1:GameClock)
                     {
                        notEnoughMana();
                     });
                  }
               }
               else
               {
                  mScalingLogicalWorkComponent.doLater(0.2,function(param1:GameClock)
                  {
                     mScalingLogicalWorkComponent.doEveryFrame(update);
                     startHoldingAttack();
                  });
               }
            }
            mPlayerExittedState = false;
         }
      }

      override public function onWeaponUp(param1:Bool = true)
      {
         var _loc12_:GMModifier;
         var __ax4_iter_0:Vector<GMModifier>;
         var _loc6_= Math.NaN;
         var _loc3_= 0;
         var _loc10_:AttackTimeline = null;
         var _loc11_= Math.NaN;
         var _loc7_:Float = 0;
         var _loc4_= Math.NaN;
         var _loc2_:Float = 0;
         var _loc9_= false;
         var _loc5_= 0;
         var _loc8_:AttackTimeline = null;
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasScalingTutorialParam() && !mTutorialMessageSent)
         {
            mDBFacade.eventManager.dispatchEvent(new FirstScalingEvent());
            mTutorialMessageSent = true;
         }
         if(mHoldingAttackTimeline != null && mHoldingAttackTimeline.isPlaying)
         {
            mHoldingAttackTimeline.stopAndFinish();
         }
         if(!mPlayerExittedState)
         {
            if(mTotalTime > 0 && mNotEnoughManaTask == null)
            {
               _loc6_ = mFramesFinished / 24 * 1 / mTotalTime;
               if(_loc6_ > 1)
               {
                  _loc6_ = 1;
               }
               _loc3_ = 0;
               if(mChargeReleaseGMAttack != null && _loc6_ > 0)
               {
                  _loc3_ = (mChargeReleaseGMAttack.Id : Int);
               }
               else
               {
                  _loc3_ = (getNextAttackId() : Int);
               }
               _loc10_ = mWeapon.getAttackTimeline((_loc3_ : UInt));
               if(_loc10_ == null)
               {
                  Logger.error("AttackTimeline for attack: <" + _loc3_ + "> was null. Ignoring onWeaponDown");
                  return;
               }
               _loc11_ = mPowerMultiplier > 1 ? 1 + _loc6_ * mPowerMultiplier : 1;
               _loc7_ = 1;
               if(_loc6_ > 0 && (mProjectileMinMultiplier > 1 || mProjectileMaxMultiplier > 1))
               {
                  _loc7_ = Math.fceil(mProjectileMinMultiplier + _loc6_ * (mProjectileMaxMultiplier - mProjectileMinMultiplier));
               }
               _loc4_ = 0;
               if(_loc7_ > 1)
               {
                  if(mProjectileStartScalingAngle < mProjectileEndScalingAngle)
                  {
                     _loc4_ = mProjectileStartScalingAngle + (mProjectileEndScalingAngle - mProjectileStartScalingAngle) * _loc6_;
                  }
                  else
                  {
                     _loc4_ = mProjectileStartScalingAngle - (mProjectileStartScalingAngle - mProjectileEndScalingAngle) * _loc6_;
                  }
               }
               _loc2_ = 0;
               _loc9_ = false;
               __ax4_iter_0 = mWeapon.modifierList;
               if (checkNullIteratee(__ax4_iter_0)) for (_tmp_ in __ax4_iter_0)
               {
                  _loc12_ = _tmp_;
                  if(ASCompat.toNumberField(_loc12_, "MAX_PROJECTILES") > 0)
                  {
                     _loc7_ += _loc6_ * ASCompat.toNumberField(_loc12_, "MAX_PROJECTILES");
                     _loc9_ = true;
                  }
                  if(ASCompat.toNumberField(_loc12_, "INCREASED_PROJECTILE_ANGLE_PERCENT") >= 0)
                  {
                     _loc2_ += ASCompat.toNumber(ASCompat.toNumberField(_loc12_, "INCREASED_PROJECTILE_ANGLE_PERCENT") * _loc4_) * ASCompat.toNumberField(_loc12_, "MAX_PROJECTILES");
                  }
               }
               if(_loc6_ == 0)
               {
                  if(mProjectileScaleTapAttack)
                  {
                     _loc4_ = mProjectileStartScalingAngle;
                     _loc7_ = mProjectileMinMultiplier;
                  }
                  else
                  {
                     _loc4_ = 0;
                     _loc7_ = 1;
                  }
               }
               if(_loc10_.projectileMultiplier > 1)
               {
                  mAutoAim = false;
               }
               _loc10_.powerMultiplier = _loc11_;
               if(_loc7_ < 1)
               {
                  _loc7_ = 1;
               }
               _loc10_.projectileMultiplier = (Std.int(_loc7_) : UInt);
               _loc10_.projectileScalingAngle = (Std.int(ASCompat.toNumber(_loc4_ + _loc2_) / _loc7_) : UInt);
               _loc10_.distanceScalingTime = mDistanceScalingTime;
               _loc10_.distanceScalingHero = mDistanceScalingForHeroMin + _loc6_ * (mDistanceScalingForHeroMax - mDistanceScalingForHeroMin);
               _loc10_.distanceScalingProjectile = mDistanceScalingForProjectilesMin + _loc6_ * (mDistanceScalingForProjectilesMax - mDistanceScalingForProjectilesMin);
            }
            else
            {
               _loc5_ = _loc3_;
               _loc3_ = (getNextAttackId() : Int);
               _loc8_ = mWeapon.getAttackTimeline((_loc3_ : UInt));
               _loc8_.projectileMultiplier = (1 : UInt);
               _loc8_.projectileScalingAngle = (0 : UInt);
            }
            attack((_loc3_ : UInt),mAutoAim);
         }
         clear();
      }

      public function update(param1:GameClock)
      {
         mFramesFinished += param1.tickLength / GameClock.ANIMATION_FRAME_DURATION;
      }

      override public function clear()
      {
         mFramesFinished = 0;
         mScalingLogicalWorkComponent.clear();
         mWeaponDownActive = false;
         if(mNotEnoughManaTask != null)
         {
            mNotEnoughManaTask.destroy();
            mNotEnoughManaTask = null;
         }
      }

      override public function canCombo() : Bool
      {
         if(mCurrentAttackTimeline != null)
         {
            if(mCurrentAttackTimeline == mHoldingAttackTimeline)
            {
               return true;
            }
            if(mCurrentAttackTimeline.isAttackWithinComboWindow())
            {
               return true;
            }
            return false;
         }
         return true;
      }

      override public function destroy()
      {
         super.destroy();
         mScalingLogicalWorkComponent.destroy();
         mScalingLogicalWorkComponent = null;
         if(mIsInCooldown)
         {
            mDBFacade.hud.stopCooldown(weapon.slot);
         }
      }
   }


