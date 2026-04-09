package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import gameMasterDictionary.GMWeaponAesthetic;
   import flash.geom.Vector3D;
   
    class PlayEffectAttackTimelineAction extends PlayEffectTimelineAction
   {
      
      public static inline final TYPE= "attackEffect";
      
      public static inline final SWING_RIGHT= "attack_swingRight";
      
      public static inline final SWING_LEFT= "attack_swingLeft";
      
      public static inline final SWORD_TRAIL_DEFAULT_PREFIX= "db_fx_attack";
      
      var mActorPos:Vector3D;
      
      var mChargeTime:Float = Math.NaN;
      
      var mWeapon:WeaponGameObject;
      
      var mRegisterChargeEffectCallback:ASFunction;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:DistributedDungeonFloor, param5:WeaponGameObject, param6:ASFunction, param7:String, param8:String, param9:Float = 0, param10:Float = 0, param11:Float = 0, param12:Float = 0, param13:Bool = false, param14:Bool = false, param15:Bool = false, param16:Float = 1, param17:Bool = false, param18:Bool = false, param19:String = "sorted", param20:Bool = false, param21:Bool = false, param22:Bool = false, param23:String = null, param24:String = null, param25:String = null)
      {
         super(param1,param2,param3,param7,param8,param9,param10,param11,param12,param13,param14,param15,param16,param17,param18,param19,param20,param21,param22,param23,param24,param25);
         mDistributedDungeonFloor = param4;
         mWeapon = param5;
         var _loc26_= mWeapon != null ? mWeapon.collisionScale() : 1;
         mScale *= _loc26_;
         mXOffset *= _loc26_;
         mYOffset *= _loc26_;
         mRegisterChargeEffectCallback = param6;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:DistributedDungeonFloor, param5:ASObject, param6:WeaponGameObject, param7:ASFunction) : PlayEffectAttackTimelineAction
      {
         return new PlayEffectAttackTimelineAction(param1,param2,param3,param4,param6,param7,param5.name,param5.path,ASCompat.toNumberField(param5, "xOffset"),ASCompat.toNumberField(param5, "yOffset"),ASCompat.toNumberField(param5, "headingOffset"),ASCompat.toNumberField(param5, "headingOffsetAngle"),ASCompat.toBool(param5.playAtTarget),ASCompat.toBool(param5.parentToActor),ASCompat.toBool(param5.behindAvatar),ASCompat.toNumberField(param5, "scale"),ASCompat.toBool(param5.autoAdjustHeading),ASCompat.toBool(param5.loop),param5.layer,ASCompat.toBool(param5.managed),ASCompat.toBool(param5.useTimelineSpeed),ASCompat.toBool(param5.invertAngles),param5.insertParentName,param5.insertIconPath,param5.insertIconName);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var _loc5_:GMWeaponAesthetic = null;
         if(mPlayAtTarget && param1.targetActor == null)
         {
            return;
         }
         if(useTimelineSpeed)
         {
            mPlayRate = param1.playSpeed;
         }
         var _loc3_:ActorGameObject = null;
         if(mParentToActor)
         {
            _loc3_ = mActorGameObject;
         }
         var _loc4_= calculatePositionBasedOnOffsets(param1.targetActor);
         var _loc10_= mEffectName.substring(0);
         var _loc7_= mActorGameObject.heading;
         var _loc2_:Float = 0;
         var _loc9_:Float = 0;
         if(mAutoAdjustHeading)
         {
            _loc2_ = _loc7_;
         }
         var _loc6_:ASObject = {};
         if(mInvertAngles)
         {
            _loc7_ += 180;
         }
         if(mEffectName.indexOf("_angle") >= 0)
         {
            if(mActorGameObject.currentWeapon != null)
            {
               _loc5_ = mActorGameObject.currentWeapon.weaponAesthetic;
            }
            if(_loc5_ != null && ASCompat.stringAsBool(_loc5_.SwordTrailOverride))
            {
               _loc10_ = StringTools.replace(_loc10_, "db_fx_attack",_loc5_.SwordTrailOverride);
            }
            _loc6_ = convertAngleForEffectName(Std.int(_loc7_));
            _loc10_ += _loc6_.string;
            if(_loc10_.indexOf("swing_angle") >= 0)
            {
               if(mActorGameObject.actorView.currentAnim == "attack_swingRight")
               {
                  _loc10_ += "_right";
               }
               else
               {
                  _loc10_ += "_left";
               }
            }
         }
         if(ASCompat.toBool(_loc6_.flip))
         {
            _loc9_ = 180;
         }
         var _loc8_= (0 : UInt);
         _loc8_ = mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath),_loc10_,_loc4_,_loc3_,mBehindAvatar,mScale,0,0,_loc9_,_loc2_,mLoop,mLayer,mManaged,mPlayRate,ASCompat.asFunction(mDoIconInsert ? assetLoadedCallback(this) : null));
         if(mManaged)
         {
            param1.mManagedEffects.add(_loc8_);
         }
      }
      
      public function convertAngleForEffectName(param1:Int) : ASObject
      {
         var _loc3_:ASObject = {
            "string":"",
            "flip":true
         };
         if(param1 < 0)
         {
            param1 = 360 + param1;
         }
         var _loc2_= param1 % 45;
         if(_loc2_ > 22)
         {
            param1 += 45 - _loc2_;
         }
         else
         {
            param1 -= _loc2_;
         }
         if(param1 == 0 || param1 == 360)
         {
            ASCompat.setProperty(_loc3_, "string", "180");
         }
         else if(param1 == 45)
         {
            ASCompat.setProperty(_loc3_, "string", "135");
         }
         else if(param1 == 315)
         {
            ASCompat.setProperty(_loc3_, "string", "225");
         }
         else
         {
            ASCompat.setProperty(_loc3_, "flip", false);
            ASCompat.setProperty(_loc3_, "string", Std.string(param1));
         }
         return _loc3_;
      }
      
      override public function destroy() 
      {
         mRegisterChargeEffectCallback = null;
         mWeapon = null;
         super.destroy();
      }
   }


