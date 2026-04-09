package projectile
;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class OrbiterFlightComponent extends FlightComponent
   {
      
      var mDistance:Float = Math.NaN;
      
      var mTargetDistance:Float = Math.NaN;
      
      public function new(param1:Vector3D, param2:Vector3D, param3:ProjectileGameObject, param4:UInt, param5:DBFacade, param6:DistributedDungeonFloor, param7:Bool, param8:ASFunction = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         mDistance = 100;
         mTargetDistance = 100;
      }
      
      override public function update() 
      {
         var _loc2_= mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_= _loc2_.worldCenter.subtract(mProjectile.position);
         var _loc7_= _loc3_.normalize();
         var _loc5_= new Vector3D(-_loc3_.y,_loc3_.x);
         _loc5_.scaleBy(60);
         var _loc8_= mProjectile.position.add(_loc5_);
         var _loc4_= _loc8_.subtract(_loc2_.worldCenter);
         _loc4_.normalize();
         if(Math.abs(mTargetDistance - mDistance) < 2)
         {
            mTargetDistance = mProjectile.gmProjectile.Range + Math.random() * 80;
         }
         mDistance += (mTargetDistance - mDistance) * 0.125;
         _loc4_.scaleBy(mDistance);
         _loc8_ = _loc2_.worldCenter.add(_loc4_);
         mApplySteeringVector(getSteeringVector(_loc8_,0.5 * mProjectile.gmProjectile.SteeringRate));
         var _loc1_= mProjectile.velocity.length / mProjectile.gmProjectile.ProjSpeedF;
         _loc1_ *= _loc1_;
         var _loc6_= mProjectile.gmProjectile.RotationSpeedF * _loc1_;
         mProjectile.rotationSpeed += _loc6_ - mProjectile.rotationSpeed;
         mProjectile.rotationSpeed = Math.max(mProjectile.rotationSpeed,mProjectile.gmProjectile.RotationSpeedF / 6);
         super.update();
      }
   }


