package projectile
;
   import actor.ActorGameObject;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Fixture;
   import brain.utils.GeometryUtil;
   import combat.CombatGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class AutoAimFlightComponent extends FlightComponent
   {
      
      var mAutoAimConeStartHalfWidth:Float = Math.NaN;
      
      var mAutoAimConeEndHalfWidth:Float = Math.NaN;
      
      var mAutoAimConeLength:Float = Math.NaN;
      
      var mCurrentTarget:ActorGameObject;
      
      var mBestDotProduct:Float = Math.NaN;
      
      public function new(param1:Vector3D, param2:Vector3D, param3:ProjectileGameObject, param4:UInt, param5:DBFacade, param6:DistributedDungeonFloor, param7:Bool, param8:ASFunction = null)
      {
         var perpendicularToDirection:Vector3D;
         var lowConePos1:Vector3D;
         var lowConePos2:Vector3D;
         var lowConePos3:Vector3D;
         var lowConePos4:Vector3D;
         var boundingBoxPoints:Vector<B2Vec2>;
         var boundingBoxForAutoAimShape:B2PolygonShape;
         var transform:B2Transform;
         var autoAimCallback:ASFunction;
         var targetActor:ActorGameObject;
         var parentActor:ActorGameObject;
         var position= param1;
         var directionVector= param2;
         var projectile= param3;
         var parentActorId= param4;
         var dbFacade= param5;
         var dungeonFloor= param6;
         var friendly= param7;
         var applySteeringVector= param8;
         super(position,directionVector,projectile,parentActorId,dbFacade,dungeonFloor,friendly,applySteeringVector);
         mAutoAimConeStartHalfWidth = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_start_width",80) * 0.5;
         mAutoAimConeEndHalfWidth = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_end_width",450) * 0.5;
         mAutoAimConeLength = mDBFacade.dbConfigManager.getConfigNumber("auto_aim_cone_length",485);
         mBestDotProduct = -1;
         perpendicularToDirection = new Vector3D(-directionVector.y,directionVector.x);
         lowConePos1 = new Vector3D(directionVector.x + perpendicularToDirection.x * mAutoAimConeStartHalfWidth,directionVector.y + perpendicularToDirection.y * mAutoAimConeStartHalfWidth);
         lowConePos2 = new Vector3D(directionVector.x + perpendicularToDirection.x * -mAutoAimConeStartHalfWidth,directionVector.y + perpendicularToDirection.y * -mAutoAimConeStartHalfWidth);
         lowConePos3 = new Vector3D(directionVector.x * mAutoAimConeLength + perpendicularToDirection.x * mAutoAimConeEndHalfWidth,directionVector.y * mAutoAimConeLength + perpendicularToDirection.y * mAutoAimConeEndHalfWidth);
         lowConePos4 = new Vector3D(directionVector.x * mAutoAimConeLength + perpendicularToDirection.x * -mAutoAimConeEndHalfWidth,directionVector.y * mAutoAimConeLength + perpendicularToDirection.y * -mAutoAimConeEndHalfWidth);
         boundingBoxPoints = new Vector<B2Vec2>();
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos4));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos3));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos1));
         boundingBoxPoints.push(NavCollider.convertToB2Vec2(lowConePos2));
         boundingBoxForAutoAimShape = new B2PolygonShape();
         boundingBoxForAutoAimShape.SetAsVector(boundingBoxPoints,boundingBoxPoints.length);
         transform = new B2Transform();
         transform.position = NavCollider.convertToB2Vec2(position);
         autoAimCallback = function(param1:B2Fixture):Bool
         {
            return targetSelectCallback(param1);
         };
         mProjectile.distributedDungeonFloor.box2DWorld.QueryShape(autoAimCallback,boundingBoxForAutoAimShape,transform);
         targetActor = mCurrentTarget;
         parentActor = mDungeonFloor.getActor(mParentActorId);
         if(targetActor != null && parentActor != null)
         {
            mProjectile.velocity = targetActor.worldCenter.subtract(parentActor.worldCenter);
         }
         else
         {
            mProjectile.velocity = directionVector;
         }
         mProjectile.velocity.normalize();
         if(mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_colliders",false))
         {
            if(mProjectile.distributedDungeonFloor.debugVisualizer != null)
            {
               mProjectile.distributedDungeonFloor.debugVisualizer.reportShape(boundingBoxForAutoAimShape,transform,(48 : UInt));
            }
         }
      }
      
      function targetSelectCallback(param1:B2Fixture) : Bool
      {
         var _loc2_= mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc4_= ASCompat.asUint(param1.GetBody().GetUserData() );
         var _loc3_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(_loc4_) , ActorGameObject);
         if(_loc3_ != null && _loc3_.isAttackable && !CombatGameObject.didAttackGoThroughWall(mDBFacade,_loc2_.worldCenterAsb2Vec2,_loc3_,_loc3_.worldCenterAsb2Vec2,mDungeonFloor,mDBFacade.dbConfigManager.getConfigBoolean("show_colliders",false)))
         {
            if(isTargetableTeam((_loc3_.team : UInt)) && isBetterTargetThanCurrent(_loc3_))
            {
               mCurrentTarget = _loc3_;
               mBestDotProduct = calculateTargetScore(_loc3_);
            }
         }
         return true;
      }
      
      function isBetterTargetThanCurrent(param1:ActorGameObject) : Bool
      {
         var _loc2_= Math.NaN;
         if(mCurrentTarget == null)
         {
            return true;
         }
         if(mCurrentTarget.team == 1 && param1.team != 1)
         {
            return true;
         }
         if(mCurrentTarget.team != 1 && param1.team != 1 || mCurrentTarget.team == 1 && param1.team == 1)
         {
            _loc2_ = calculateTargetScore(param1);
            if(_loc2_ > mBestDotProduct)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      function calculateTargetScore(param1:ActorGameObject) : Float
      {
         var _loc2_= mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return -1;
         }
         var _loc3_= param1.worldCenter.clone();
         _loc3_ = _loc3_.subtract(_loc2_.worldCenter);
         _loc3_.normalize();
         return GeometryUtil.dotProduct2D(_loc3_,mHeadingVector);
      }
   }


