package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class RunIdleMonitorTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "runIdleMonitor";
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : RunIdleMonitorTimelineAction
      {
         return new RunIdleMonitorTimelineAction(param1,param2,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorGameObject.startRunIdleMonitoring();
      }
      
      override public function stop() 
      {
         mActorGameObject.stopRunIdleMonitoring();
      }
   }


