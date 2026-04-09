package projectile
;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   
    class BounceBackCollisionComponent extends CollisionComponent
   {
      
      static inline final DAMPING_FACTOR:Float = 0.5;
      
      public function new(param1:DBFacade, param2:ProjectileGameObject, param3:UInt, param4:DistributedDungeonFloor, param5:UInt, param6:UInt, param7:GMAttack, param8:ASFunction, param9:Int, param10:Float)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,false);
      }
      
      override public function hitWall() 
      {
         var _loc1_= mDungeonFloor.getActor(mParentActorId);
         if(_loc1_ == null || _loc1_.isDestroyed)
         {
            mProjectile.destroy();
            return;
         }
         var _loc2_= _loc1_.worldCenter.subtract(mProjectile.position);
         _loc2_.normalize();
         _loc2_.scaleBy(mProjectile.velocity.length * 0.5);
         mProjectile.velocity = _loc2_;
         mUpdatedVelocity = true;
      }
   }


