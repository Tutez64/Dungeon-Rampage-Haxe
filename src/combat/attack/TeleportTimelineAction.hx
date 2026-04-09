package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class TeleportTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "teleport";
      
      var mFramesElapsed:UInt = 0;
      
      var mDuration:UInt = 0;
      
      var mMovementTask:Task;
      
      var mStartPos:Vector3D;
      
      var mEndPos:Vector3D;
      
      var mOffset:Vector3D;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:UInt)
      {
         mDuration = param4;
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : TeleportTimelineAction
      {
         var _loc5_= ASCompat.toNumber(param4.duration);
         return new TeleportTimelineAction(param1,param2,param3,(Std.int(_loc5_) : UInt));
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         if(mFramesElapsed != 0)
         {
            ResetMovement();
         }
         mFramesElapsed = (0 : UInt);
         if(mMovementTask != null)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         if(mWorkComponent != null)
         {
            mMovementTask = mWorkComponent.doEveryFrame(UpdateMovement);
         }
      }
      
      public function initMovementData() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner))
         {
            _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner);
            mStartPos = _loc1_.position;
            mEndPos = _loc1_.mTeleportDestination;
            mOffset = new Vector3D(mEndPos.x - mStartPos.x,mEndPos.y - mStartPos.y);
         }
      }
      
      public function moveHero() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner))
         {
            _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner);
            mStartPos = _loc1_.position;
            _loc1_.moveToTeleDest();
            mEndPos = _loc1_.mTeleportDestination;
            mOffset = new Vector3D(mEndPos.x - mStartPos.x,mEndPos.y - mStartPos.y);
         }
      }
      
      public function stopHeroMovement() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner))
         {
            _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner);
            _loc1_.stopMovement();
         }
      }
      
      public function easeInOutQuad(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         param1 /= param4 / 2;
         if(param1 < 1)
         {
            return param3 / 2 * param1 * param1 + param2;
         }
         param1--;
         return -param3 / 2 * (param1 * (param1 - 2) - 1) + param2;
      }
      
      public function updateView() 
      {
         var _loc5_:HeroGameObjectOwner = null;
         var _loc4_= Math.NaN;
         var _loc1_= Math.NaN;
         var _loc2_:Vector3D = null;
         var _loc3_:Vector3D = null;
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner))
         {
            _loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner);
            _loc4_ = mFramesElapsed / mDuration;
            _loc4_ = easeInOutQuad(mFramesElapsed,0,1,mDuration);
            _loc1_ = 1 - _loc4_;
            _loc2_ = new Vector3D(mStartPos.x * _loc1_ + mEndPos.x * _loc4_,mStartPos.y * _loc1_ + mEndPos.y * _loc4_);
            _loc5_.placeAt(_loc2_);
            _loc3_ = new Vector3D(mOffset.x * _loc1_,mOffset.y * _loc1_);
            _loc5_.moveBodyTo(_loc3_);
         }
      }
      
      public function UpdateMovement(param1:GameClock) 
      {
         if(mActorView != null && mActorView.body != null)
         {
            mFramesElapsed = mFramesElapsed + 1;
            if(mFramesElapsed == 1)
            {
               stopHeroMovement();
               initMovementData();
            }
            else if(mFramesElapsed <= mDuration)
            {
               updateView();
            }
            else if(mFramesElapsed > mDuration)
            {
               ResetMovement();
               return;
            }
            return;
         }
         ResetMovement();
      }
      
      function ResetMovement() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         mFramesElapsed = (0 : UInt);
         if(mActorView != null && mActorView.body != null)
         {
         }
         if(mMovementTask != null)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         if(Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner))
         {
            _loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id) , HeroGameObjectOwner);
         }
      }
      
      override public function destroy() 
      {
         if(mMovementTask != null)
         {
            mMovementTask.destroy();
            mMovementTask = null;
         }
         super.destroy();
      }
   }


