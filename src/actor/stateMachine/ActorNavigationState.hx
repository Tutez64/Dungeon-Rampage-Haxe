package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class ActorNavigationState extends ActorState
   {
      
      public static inline final NAME= "ActorNavigationState";
      
      var mUpdateTask:Task;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView, param4:ASFunction = null)
      {
         super(param1,param2,param3,"ActorNavigationState",param4);
      }
      
      override public function enterState() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         super.enterState();
         mActorGameObject.startRunIdleMonitoring();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
            _loc1_.inputController.inputType = "free";
         }
         mActorGameObject.movementControllerType = "normal";
      }
      
      override public function exitState() 
      {
         mActorGameObject.stopRunIdleMonitoring();
         super.exitState();
      }
   }


