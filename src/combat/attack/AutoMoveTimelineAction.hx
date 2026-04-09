package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import flash.geom.Vector3D;
   
    class AutoMoveTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "automove";
      
      var mTask:Task;
      
      var mAttack:GMAttack;
      
      var mDistance:Float = Math.NaN;
      
      var mDuration:Float = Math.NaN;
      
      var mAngle:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade) : AutoMoveTimelineAction
      {
         if(param1.isOwner)
         {
            return new AutoMoveTimelineAction(param1,param2,param3);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         var _loc4_= cast(mActorGameObject, HeroGameObjectOwner);
         if(mDuration <= 0 || Math.isNaN(mAngle))
         {
            Logger.warn("Invalid data for AutoMoveTimelineAction. mDistance: " + mDistance + " mDuration: " + mDuration + " mAngle: " + mAngle + " attack: " + mAttackType);
            return;
         }
         var _loc5_= mDistance / mDuration;
         var _loc3_= mAngle * 3.141592653589793 / 180;
         var _loc2_= new Vector3D(Math.cos(_loc3_) * _loc5_,Math.sin(_loc3_) * _loc5_);
         _loc4_.autoMoveVelocity = _loc2_;
         mTask = mWorkComponent.doLater(mDuration,resetVelocity);
      }
      
      function resetVelocity(param1:GameClock) 
      {
         var _loc2_= cast(mActorGameObject, HeroGameObjectOwner);
         _loc2_.autoMoveVelocity.scaleBy(0);
      }
      
      override public function destroy() 
      {
         if(mTask != null)
         {
            resetVelocity(null);
            mTask.destroy();
            mTask = null;
         }
         super.destroy();
      }
   }


