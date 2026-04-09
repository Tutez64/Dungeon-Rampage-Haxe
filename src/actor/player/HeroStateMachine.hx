package actor.player
;
   import actor.ActorView;
   import actor.stateMachine.ActorMacroStateMachine;
   import actor.stateMachine.ActorReviveState;
   import brain.utils.MemoryTracker;
   import distributedObjects.HeroGameObject;
   import facade.DBFacade;
   
    class HeroStateMachine extends ActorMacroStateMachine
   {
      
      var mReviveState:ActorReviveState;
      
      public function new(param1:DBFacade, param2:HeroGameObject, param3:ActorView)
      {
         super(param1,param2,param3);
         mReviveState = new ActorReviveState(mDBFacade,param2,mActorView);
         MemoryTracker.track(mReviveState,"ActorReviveState - created in HeroStateMachine.HeroStateMachine()");
      }
      
      override public function destroy() 
      {
         mReviveState.destroy();
         super.destroy();
      }
      
      public function enterReviveState() 
      {
         this.transitionToState(mReviveState);
      }
   }


