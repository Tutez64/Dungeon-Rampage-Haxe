package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.utils.MathUtil;
   import brain.utils.MemoryTracker;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import projectile.ChainProjectileGameObject;
   import projectile.ProjectileGameObject;
   import flash.geom.Vector3D;
   
    class ProjectileAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "projectile";
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mEffectObject:ASObject;
      
      var mWeaponGameObject:WeaponGameObject;
      
      var mCombatResultCallback:ASFunction;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:WeaponGameObject, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASObject, param7:ASFunction = null)
      {
         super(param1,param2,param4);
         mDistributedDungeonFloor = param5;
         mEffectObject = param6;
         mWeaponGameObject = param3;
         mCombatResultCallback = param7;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:DistributedDungeonFloor, param5:ASObject, param6:WeaponGameObject, param7:ASFunction = null) : ProjectileAttackTimelineAction
      {
         return new ProjectileAttackTimelineAction(param1,param2,param6,param3,param4,param5,param7);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var _loc18_:ProjectileGameObject = null;
         var _loc19_:AttackTimeline = null;
         var _loc7_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc8_= 0;
         super.execute(param1);
         var _loc17_= ASCompat.toBool(mEffectObject.dontRotate != null ? mEffectObject.dontRotate : false);
         var _loc11_= ASCompat.toNumber(mEffectObject.headingOffset != null ? mEffectObject.headingOffset : 0);
         var _loc12_= ASCompat.toNumber(mEffectObject.headingOffsetAngle != null ? mEffectObject.headingOffsetAngle : 0);
         var _loc6_= ASCompat.toNumber(mEffectObject.headingRandomnessAngle != null ? mEffectObject.headingRandomnessAngle : 0);
         _loc12_ += MathUtil.rand(-_loc6_,_loc6_);
         var _loc20_= ASCompat.toNumber(mEffectObject.startingAngleOffset != null ? mEffectObject.startingAngleOffset : 0);
         var _loc15_= mWeaponGameObject != null ? mWeaponGameObject.collisionScale() : 1;
         var _loc3_= ASCompat.toNumber(mEffectObject.xOffset != null ? mEffectObject.xOffset : 0);
         _loc3_ *= _loc15_;
         var _loc2_= ASCompat.toNumber(mEffectObject.yOffset != null ? mEffectObject.yOffset : 0);
         _loc2_ *= _loc15_;
         var _loc5_= mActorGameObject.heading;
         var _loc9_= mActorGameObject.getHeadingAsVector(_loc12_);
         var _loc14_= mActorGameObject.worldCenter;
         var _loc10_= mActorGameObject.projectileLaunchOffset;
         var _loc4_= calculateHeadingOffset(_loc11_,_loc5_,_loc12_);
         _loc14_.x += _loc4_.x + _loc3_;
         _loc14_.y += _loc4_.y + _loc2_;
         _loc10_.x += _loc4_.x;
         _loc10_.y += _loc4_.y;
         var _loc13_= param1.autoAim;
         if(Std.isOfType(param1 , AttackTimeline))
         {
            _loc19_ = ASCompat.reinterpretAs(param1 , AttackTimeline);
            _loc7_ = 1;
            _loc16_ = _loc12_;
            _loc8_ = 0;
            while((_loc8_ : UInt) < _loc19_.projectileMultiplier)
            {
               _loc7_ = _loc8_ % 2 == 0 ? 1 : -1;
               _loc12_ = ASCompat.toNumber(ASCompat.toNumber(_loc16_ + _loc19_.projectileScalingAngle * Std.int((_loc8_ + 1) / 2)) * _loc7_);
               _loc9_ = mActorGameObject.getHeadingAsVector(_loc12_);
               _loc18_ = new ChainProjectileGameObject(this.mDBFacade,mActorGameObject.id,(mActorGameObject.team : UInt),mAttackType,mWeaponGameObject,mDistributedDungeonFloor,_loc14_,_loc9_,_loc10_,_loc19_.distanceScalingProjectile,(0 : UInt),null,mEffectObject,mCombatResultCallback,_loc13_,_loc17_);
               MemoryTracker.track(_loc18_,"ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
               _loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
               _loc8_++;
            }
         }
         else
         {
            _loc18_ = new ChainProjectileGameObject(this.mDBFacade,mActorGameObject.id,(mActorGameObject.team : UInt),mAttackType,mWeaponGameObject,mDistributedDungeonFloor,_loc14_,_loc9_,_loc10_,0,(0 : UInt),null,mEffectObject,mCombatResultCallback,_loc13_,_loc17_);
            MemoryTracker.track(_loc18_,"ChainProjectileGameObject - created in ProjectileAttackTimelineAction.execute()");
            _loc18_.distributedDungeonFloor = mDistributedDungeonFloor;
         }
      }
      
      public function calculateHeadingOffset(param1:Float, param2:Float, param3:Float = 0) : Vector3D
      {
         param2 += param3;
         if(param2 < 0)
         {
            param2 = 360 + param2;
         }
         param2 = param2 * 3.141592653589793 / 180;
         var _loc4_= new Vector3D(0,0,0);
         _loc4_.x = param1 * Math.cos(param2);
         _loc4_.y = param1 * Math.sin(param2);
         return _loc4_;
      }
      
      override public function destroy() 
      {
         mWeaponGameObject = null;
         mDistributedDungeonFloor = null;
         mEffectObject = null;
         super.destroy();
      }
   }


