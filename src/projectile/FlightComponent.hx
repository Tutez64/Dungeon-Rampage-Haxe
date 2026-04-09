package projectile
;
   import actor.ActorGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class FlightComponent
   {
      
      var mProjectile:ProjectileGameObject;
      
      var mParentActorId:UInt = 0;
      
      var mDBFacade:DBFacade;
      
      var mDungeonFloor:DistributedDungeonFloor;
      
      var mHeadingVector:Vector3D;
      
      var mSteeringUpdated:Bool = false;
      
      var mSteeringVector:Vector3D;
      
      var mFriendly:Bool = false;
      
      var mApplySteeringVector:ASFunction;
      
      var mStartTime:UInt = 0;
      
      public function new(param1:Vector3D, param2:Vector3D, param3:ProjectileGameObject, param4:UInt, param5:DBFacade, param6:DistributedDungeonFloor, param7:Bool, param8:ASFunction = null)
      {
         
         mProjectile = param3;
         mHeadingVector = param2;
         mParentActorId = param4;
         mDBFacade = param5;
         mDungeonFloor = param6;
         mApplySteeringVector = param8;
         mFriendly = param7;
         mSteeringUpdated = false;
         mStartTime = (mDBFacade.gameClock.gameTime : UInt);
      }
      
      public function update() 
      {
         if(mProjectile.gmProjectile.Lifetime > 0 && mDBFacade.gameClock.gameTime - mStartTime > mProjectile.gmProjectile.Lifetime)
         {
            mProjectile.destroy();
            return;
         }
      }
      
      public function informOfHit(param1:ActorGameObject) 
      {
      }
      
      @:isVar public var steeringVector(get,never):Vector3D;
public function  get_steeringVector() : Vector3D
      {
         return mSteeringVector;
      }
      
      @:isVar public var steeringUpdated(get,never):Bool;
public function  get_steeringUpdated() : Bool
      {
         return mSteeringUpdated;
      }
      
      public function destroy() 
      {
         mProjectile = null;
         mDBFacade = null;
         mDungeonFloor = null;
         mApplySteeringVector = null;
      }
      
      function getSteeringVector(param1:Vector3D, param2:Float) : Vector3D
      {
         var _loc3_= param1.subtract(mProjectile.position);
         var _loc5_= _loc3_.normalize();
         _loc3_.scaleBy(mProjectile.gmProjectile.ProjSpeedF);
         var _loc4_= _loc3_.subtract(mProjectile.velocity);
         _loc4_.scaleBy(param2);
         return _loc4_;
      }
      
      public function isTargetableTeam(param1:UInt) : Bool
      {
         return mFriendly ? param1 == mProjectile.team : param1 != mProjectile.team;
      }
   }


