package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.workLoop.Task;
   import facade.DBFacade;
   
    class AttemptReviveTimeLineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "attemptRevive";
      
      var mKeyboardCheckTask:Task;
      
      var mDeltaPerFrame:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : AttemptReviveTimeLineAction
      {
         return new AttemptReviveTimeLineAction(param1,param2,param3);
      }
      
      function keyboardCheck(param1:GameClock) 
      {
         if(!mDBFacade.inputManager.check(32) || !this.mTimeline.targetActor.isInReviveState())
         {
            mTimeline.stop();
         }
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mKeyboardCheckTask = mWorkComponent.doEveryFrame(keyboardCheck);
      }
      
      override public function stop() 
      {
         if(mKeyboardCheckTask != null)
         {
            mKeyboardCheckTask.destroy();
            mKeyboardCheckTask = null;
         }
      }
   }


