package projectile
;
   import actor.ActorGameObject;
   import box2D.collision.B2AABB;
   import box2D.dynamics.B2Fixture;
   import distributedObjects.DistributedDungeonFloor;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class HomingFlightComponent extends FlightComponent
   {
      
      var mCurrentTargetId:UInt = 0;
      
      var mBestScore:Float = Math.NaN;
      
      var mLastHitActor:ActorGameObject;
      
      public function new(param1:Vector3D, param2:Vector3D, param3:ProjectileGameObject, param4:UInt, param5:DBFacade, param6:DistributedDungeonFloor, param7:Bool, param8:ASFunction = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8);
         findTarget();
      }
      
      function findTarget() 
      {
         mBestScore = -99999;
         var _loc2_= new Vector3D(mDBFacade.camera.visibleRectangle.left,mDBFacade.camera.visibleRectangle.top);
         var _loc1_= new Vector3D(mDBFacade.camera.visibleRectangle.right,mDBFacade.camera.visibleRectangle.bottom);
         var _loc3_= new B2AABB();
         _loc3_.lowerBound = NavCollider.convertToB2Vec2(_loc2_);
         _loc3_.upperBound = NavCollider.convertToB2Vec2(_loc1_);
         mProjectile.distributedDungeonFloor.box2DWorld.QueryAABB(targetSelectCallback,_loc3_);
      }
      
      override public function informOfHit(param1:ActorGameObject) 
      {
         mLastHitActor = param1;
         findTarget();
      }
      
      public function targetSelectCallback(param1:B2Fixture) : Bool
      {
         var _loc2_= mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc3_= ASCompat.asUint(param1.GetBody().GetUserData() );
         var _loc4_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(_loc3_) , ActorGameObject);
         if(_loc4_ != null && (_loc4_.isProp && !mProjectile.gmAttack.AffectsProps))
         {
            return false;
         }
         if(_loc4_ == null || !_loc4_.isAttackable || _loc4_ == mLastHitActor)
         {
            return true;
         }
         if(isTargetableTeam((_loc4_.team : UInt)) && isBetterTargetThanCurrent(_loc4_))
         {
            mCurrentTargetId = _loc4_.id;
            mBestScore = calculateTargetScore(_loc4_,_loc2_);
         }
         return true;
      }
      
      function isBetterTargetThanCurrent(param1:ActorGameObject) : Bool
      {
         var _loc3_= Math.NaN;
         var _loc4_= mDungeonFloor.getActor(mParentActorId);
         var _loc2_= mDungeonFloor.getActor(mCurrentTargetId);
         if(_loc2_ == null || _loc2_.hitPoints == 0)
         {
            return true;
         }
         if(param1.hitPoints == 0)
         {
            return false;
         }
         if(_loc2_.team == 1 && param1.team != 1)
         {
            return true;
         }
         if(_loc2_.team != 1 && param1.team != 1 || _loc2_.team == 1 && param1.team == 1)
         {
            _loc3_ = calculateTargetScore(param1,_loc4_);
            if(_loc3_ > mBestScore)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      function calculateTargetScore(param1:ActorGameObject, param2:ActorGameObject) : Float
      {
         if(param2 == null)
         {
            return 0;
         }
         var _loc5_= 20 / Vector3D.distance(param1.worldCenter,param2.worldCenter);
         var _loc6_= param1.worldCenter.subtract(param2.worldCenter);
         _loc6_.normalize();
         var _loc3_= _loc6_.dotProduct(param2.getHeadingAsVector());
         return _loc5_ * mProjectile.gmProjectile.HomingDistWeight + _loc3_ * mProjectile.gmProjectile.HomingAngleWeight;
      }
      
      override public function update() 
      {
         var _loc1_= mDungeonFloor.getActor(mCurrentTargetId);
         if(_loc1_ == null || _loc1_.hitPoints == 0)
         {
            findTarget();
            return;
         }
         var _loc5_= _loc1_.worldCenter;
         var _loc2_= _loc5_.subtract(mProjectile.position);
         var _loc3_= _loc2_.normalize();
         var _loc4_= 1 - 20 / _loc3_;
         _loc4_ = 1 - _loc4_ * _loc4_;
         mSteeringVector = getSteeringVector(_loc5_,Math.min(1,_loc4_ * mProjectile.gmProjectile.SteeringRate));
         mApplySteeringVector(mSteeringVector);
         if(mProjectile.gmProjectile.RotationSpeedF == 0)
         {
            mProjectile.rotation = Math.atan2(mProjectile.velocity.y,mProjectile.velocity.x) * 180 / 3.141592653589793;
         }
      }
   }


