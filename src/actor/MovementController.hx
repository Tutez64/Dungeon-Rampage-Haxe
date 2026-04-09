package actor
;
   import brain.clock.GameClock;
   import brain.workLoop.PreRenderWorkComponent;
   import brain.workLoop.Task;
   import brain.workLoop.WorkComponent;
   import facade.DBFacade;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
    class MovementController
   {
      
      public static inline final IDLE_VELOCITY_THRESHOLD:Float = 1;
      
      static inline final DEFAULT_SMOOTH_FACTOR:Float = 0.8;
      
      public static inline final LOCKED_HERO_MOVEMENT_TYPE= "locked_hero";
      
      public static inline final LOCKED_XY_MOVEMENT_TYPE= "locked_xy";
      
      public static inline final LOCKED_R_MOVEMENT_TYPE= "locked_r";
      
      public static inline final LOCKED_MOVEMENT_TYPE= "locked";
      
      public static inline final NORMAL_MOVEMENT_TYPE= "normal";
      
      public static final ZERO_VECTOR:Vector3D = new Vector3D();
      
      var mTargetPosition:Point = new Point(0,0);
      
      var mActorGameObject:ActorGameObject;
      
      var mView:ActorView;
      
      var mPositionLerpTask:Task;
      
      var mMovementType:String = "normal";
      
      var mPreRenderWorkComponent:WorkComponent;
      
      var mWantSmoothTelemetry:Bool = false;
      
      var mSmoothFactor:Float = 0.8;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         
         mDBFacade = param3;
         mView = param2;
         mActorGameObject = param1;
         mPreRenderWorkComponent = new PreRenderWorkComponent(param3);
         mWantSmoothTelemetry = mDBFacade.dbConfigManager.getConfigBoolean("smooth_telemetry",true);
         mSmoothFactor = mDBFacade.dbConfigManager.getConfigNumber("smooth_telemetry_factor",0.8);
      }
      
            
      @:isVar public var movementType(get,set):String;
public function  set_movementType(param1:String) :String      {
         mView.position = mActorGameObject.position;
         mView.heading = mActorGameObject.heading;
         return mMovementType = param1;
      }
function  get_movementType() : String
      {
         return mMovementType;
      }
      
      @:isVar public var canMoveHero(get,never):Bool;
public function  get_canMoveHero() : Bool
      {
         return mMovementType != "locked_hero";
      }
      
      @:isVar public var canMoveXY(get,never):Bool;
public function  get_canMoveXY() : Bool
      {
         return mMovementType != "locked" && mMovementType != "locked_xy";
      }
      
      @:isVar public var canMoveR(get,never):Bool;
public function  get_canMoveR() : Bool
      {
         return mMovementType != "locked" && mMovementType != "locked_r";
      }
      
      public function stopLerp() 
      {
         if(mPositionLerpTask != null)
         {
            mPositionLerpTask.destroy();
            mPositionLerpTask = null;
         }
      }
      
      public function move(param1:Vector3D, param2:Float) 
      {
         if(!canMoveXY)
         {
            if(mPositionLerpTask != null)
            {
               mPositionLerpTask.destroy();
               mPositionLerpTask = null;
            }
         }
         if(mActorGameObject.actorData != null && mActorGameObject.actorData.isMover)
         {
            if(mPositionLerpTask == null)
            {
               mPositionLerpTask = mPreRenderWorkComponent.doEveryFrame(positionLerp);
            }
         }
         else
         {
            mView.position = param1;
            mView.heading = param2;
         }
      }
      
      public function moveBody(param1:Vector3D, param2:Float) 
      {
         mView.body.x = param1.x;
         mView.body.y = param1.y;
      }
      
      function positionLerp(param1:GameClock) 
      {
         var _loc5_:Vector3D = null;
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc4_= (1 - mSmoothFactor) * param1.timeScale;
         if(mWantSmoothTelemetry)
         {
            _loc2_ = mView.position.x * (1 - _loc4_) + mActorGameObject.position.x * _loc4_;
            _loc3_ = mView.position.y * (1 - _loc4_) + mActorGameObject.position.y * _loc4_;
            _loc5_ = new Vector3D(_loc2_,_loc3_);
         }
         else
         {
            _loc5_ = mActorGameObject.position;
         }
         mView.velocity = _loc5_.subtract(mView.position);
         if(mView.velocity.nearEquals(ZERO_VECTOR,1))
         {
            if(mPositionLerpTask != null)
            {
               mPositionLerpTask.destroy();
               mPositionLerpTask = null;
            }
            mView.heading = mActorGameObject.heading;
            mView.position = mActorGameObject.position;
            mView.velocity.scaleBy(0);
         }
         else
         {
            mView.position = _loc5_;
            if(canMoveR)
            {
               mView.heading = Math.atan2(mView.velocity.y,mView.velocity.x) * 180 / 3.141592653589793;
            }
         }
      }
      
      public function destroy() 
      {
         if(mPositionLerpTask != null)
         {
            mPositionLerpTask.destroy();
            mPositionLerpTask = null;
         }
         mPreRenderWorkComponent.destroy();
         mDBFacade = null;
      }
   }


