package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.logger.Logger;
   import combat.CombatGameObject;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class ColliderTimelineAction extends AttackTimelineAction
   {
      
      var mHeadingOffset:Vector3D;
      
      var mGlobalOffset:Vector3D;
      
      var mWeapon:WeaponGameObject;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mCombatGameObject:CombatGameObject;
      
      var mCombatResultCallback:ASFunction;
      
      var mLifeTime:UInt = 0;
      
      var mHitDelayPerObject:UInt = 0;
      
      public function new(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:ASFunction, param7:Vector3D, param8:Vector3D, param9:UInt = (0 : UInt), param10:UInt = (0 : UInt))
      {
         mLifeTime = param9;
         mWeapon = param1;
         mCombatResultCallback = param6;
         mHeadingOffset = param7;
         mGlobalOffset = param8;
         mDistributedDungeonFloor = param5;
         mHitDelayPerObject = param10;
         super(param2,param3,param4);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mCombatGameObject = buildCombatGameObject(mLifeTime,mHitDelayPerObject);
         perFrameUpCall(param1);
         if(mLifeTime > 0)
         {
            param1.addContinuousCollision(this);
         }
      }
      
      function buildCombatGameObject(param1:UInt, param2:UInt) : CombatGameObject
      {
         Logger.error("Build Combat Game Object should be overriden.  Implement it in the sub class.");
         return null;
      }
      
      function returnPositionForCollision() : Vector3D
      {
         var _loc4_= mActorGameObject.getHeadingAsVector();
         var _loc3_= mActorGameObject.heading;
         var _loc1_= new Vector3D(0,0);
         _loc1_.x += mHeadingOffset.x * _loc4_.x * mActorGameObject.actorData.scale;
         _loc1_.y += mHeadingOffset.x * _loc4_.y * mActorGameObject.actorData.scale;
         var _loc2_= mActorView.worldCenter.add(_loc1_);
         return _loc2_.add(mGlobalOffset);
      }
      
      public function perFrameUpCall(param1:ScriptTimeline) : Bool
      {
         if(mCombatGameObject != null)
         {
            mCombatGameObject.position = returnPositionForCollision();
            mCombatGameObject.perFrameUpCall(param1.currentFrame);
            if(!mCombatGameObject.isAlive())
            {
               mCombatGameObject.destroy();
               mCombatGameObject = null;
               return false;
            }
            return true;
         }
         return false;
      }
   }


