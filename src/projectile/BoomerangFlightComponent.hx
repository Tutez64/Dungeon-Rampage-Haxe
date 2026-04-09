package projectile
;
   import actor.ActorGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class BoomerangFlightComponent extends FlightComponent
   {
      
      public function new(param1:Vector3D, param2:Vector3D, param3:ProjectileGameObject, param4:UInt, param5:DBFacade, param6:DistributedDungeonFloor, param7:Bool, param8:ASFunction = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function update() 
      {
         var _loc2_= mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc7_= _loc2_.worldCenter;
         var _loc3_= _loc7_.subtract(mProjectile.position);
         var _loc6_= _loc3_.normalize();
         var _loc5_= mProjectile.gmProjectile.ProjSpeedF;
         if(_loc6_ > mProjectile.gmProjectile.Range / 4 || mProjectile.velocity.lengthSquared < _loc5_ * _loc5_ * 0.9)
         {
            mApplySteeringVector(getSteeringVector(_loc7_,0.1 * mProjectile.gmProjectile.SteeringRate));
         }
         var _loc1_= mProjectile.velocity.length / mProjectile.gmProjectile.ProjSpeedF;
         _loc1_ *= _loc1_;
         var _loc4_= -mProjectile.gmProjectile.RotationSpeedF * _loc1_;
         mProjectile.rotationSpeed += _loc4_ - mProjectile.rotationSpeed;
         mProjectile.rotationSpeed = Math.min(mProjectile.rotationSpeed,-mProjectile.gmProjectile.RotationSpeedF / 6);
         if(approachingTarget(_loc6_,_loc3_,_loc2_))
         {
            mProjectile.destroy();
         }
      }
      
      function approachingTarget(param1:Float, param2:Vector3D, param3:ActorGameObject) : Bool
      {
         var _loc5_= mProjectile.gmProjectile.CollisionSize + param3.actorData.gMActor.CollisionSize;
         var _loc4_= mProjectile.velocity.length >= mProjectile.gmProjectile.ProjSpeedF - 0.1 && param1 < 40;
         if(!_loc4_ && param1 < _loc5_ && param2.dotProduct(mProjectile.velocity) > 0)
         {
            return true;
         }
         return false;
      }
   }


