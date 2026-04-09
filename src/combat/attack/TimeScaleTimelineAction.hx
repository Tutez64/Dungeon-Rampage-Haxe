package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.workLoop.Task;
   import facade.DBFacade;
   
    class TimeScaleTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "timeScale";
      
      var mTask:Task;
      
      var mDuration:Float = 0;
      
      var mTimeScale:Float = 1;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject)
      {
         super(param1,param2,param3);
         if(param4.duration == null)
         {
            Logger.error("TimeScaleTimelineAction: Must specify duration");
         }
         if(param4.timeScale == null)
         {
            Logger.error("TimeScaleTimelineAction: Must specify timeScale");
         }
         var _loc5_= (24 : UInt);
         mDuration = ASCompat.toNumberField(param4, "duration") / _loc5_;
         mTimeScale = ASCompat.toNumberField(param4, "timeScale");
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : TimeScaleTimelineAction
      {
         if(param1.isOwner)
         {
            return new TimeScaleTimelineAction(param1,param2,param3,param4);
         }
         return null;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         this.mDBFacade.gameClock.timeScale = mTimeScale;
         mTask = mWorkComponent.doLater(mDuration,resetTimeScale);
      }
      
      function resetTimeScale(param1:GameClock) 
      {
         this.mDBFacade.gameClock.timeScale = 1;
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
      
      override public function stop() 
      {
         this.mDBFacade.gameClock.timeScale = 1;
         if(mTask != null)
         {
            mTask.destroy();
            mTask = null;
         }
      }
   }


