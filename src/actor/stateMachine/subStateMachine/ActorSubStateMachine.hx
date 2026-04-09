package actor.stateMachine.subStateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import actor.stateMachine.ActorNavigationState;
   import actor.stateMachine.ActorState;
   import actor.stateMachine.ActorStateMachine;
   import brain.utils.MemoryTracker;
   import combat.attack.ScriptTimeline;
   import facade.DBFacade;
   
    class ActorSubStateMachine extends ActorStateMachine
   {
      
      var mActorNavigationState:ActorNavigationState;
      
      var mActorChoreographyState:ActorChoreographySubState;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView)
      {
         super(param1,param2,param3);
         buildStates();
      }
      
      public function exit() 
      {
         ASCompat.dynamicAs(this.currentState , ActorState).exitState();
         this.currentState = null;
      }
      
      function buildStates() 
      {
         mActorNavigationState = new ActorNavigationState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mActorNavigationState,"ActorNavigationState - created in ActorSubStateMachine.buildStates()");
         mActorChoreographyState = new ActorChoreographySubState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mActorChoreographyState,"ActorChoreographySubState - created in ActorSubStateMachine.buildStates()");
      }
      
      public function enterNavigationState() 
      {
         this.transitionToState(mActorNavigationState);
      }
      
      public function enterChoreographyState(param1:Float, param2:ActorGameObject, param3:ScriptTimeline, param4:ASFunction = null, param5:ASFunction = null, param6:Bool = false) 
      {
         var playSpeed= param1;
         var targetActor= param2;
         var script= param3;
         var finishedCallback= param4;
         var stopCallback= param5;
         var loop= param6;
         var enterNavigationAndCallFinishedCallback:ASFunction = function()
         {
            enterNavigationState();
            if(finishedCallback != null)
            {
               finishedCallback();
            }
         };
         mActorChoreographyState.setChoreography(playSpeed,targetActor,script,enterNavigationAndCallFinishedCallback,stopCallback,loop);
         this.transitionToState(mActorChoreographyState);
      }
      
      override public function destroy() 
      {
         if(this.currentState != null)
         {
            this.currentState.exitState();
         }
         this.currentState = null;
         mActorNavigationState.destroy();
         mActorNavigationState = null;
         mActorChoreographyState.destroy();
         mActorChoreographyState = null;
         super.destroy();
      }
   }


