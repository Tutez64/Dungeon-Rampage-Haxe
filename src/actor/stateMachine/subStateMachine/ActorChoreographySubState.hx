package actor.stateMachine.subStateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import actor.stateMachine.ActorState;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import combat.attack.ScriptTimeline;
   import events.HeroOwnerEndedAttackStateEvent;
   import facade.DBFacade;
   
    class ActorChoreographySubState extends ActorState
   {
      
      public static inline final NAME= "ActorChoreographySubState";
      
      var mCurrentScript:ScriptTimeline;
      
      var mQueuedScript:ScriptTimeline;
      
      var mQueuedPlaySpeed:Float = 1;
      
      var mQueuedFinishedCallback:ASFunction;
      
      var mQueuedStopCallback:ASFunction;
      
      var mQueuedLoop:Bool = false;
      
      var mQueuedTargetActor:ActorGameObject;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView, param4:ASFunction = null)
      {
         super(param1,param2,param3,"ActorChoreographySubState",param4);
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function setChoreography(param1:Float, param2:ActorGameObject, param3:ScriptTimeline, param4:ASFunction = null, param5:ASFunction = null, param6:Bool = false) 
      {
         mQueuedScript = param3;
         mQueuedPlaySpeed = param1;
         mQueuedFinishedCallback = param4;
         mQueuedStopCallback = param5;
         mQueuedLoop = param6;
         mQueuedTargetActor = param2;
      }
      
      override public function enterState() 
      {
         super.enterState();
         if(mQueuedScript != null)
         {
            if(mCurrentScript != null)
            {
               mCurrentScript.stop();
            }
            mCurrentScript = mQueuedScript;
            mQueuedScript = null;
            mCurrentScript.play(mQueuedPlaySpeed,mQueuedTargetActor,mQueuedFinishedCallback,mQueuedStopCallback,mQueuedLoop);
         }
         else
         {
            Logger.error("No script in choreography!");
            mQueuedFinishedCallback();
         }
      }
      
      override public function exitState() 
      {
         if(mActorGameObject.isOwner)
         {
            mEventComponent.dispatchEvent(new HeroOwnerEndedAttackStateEvent("PLAYER_ENDED_ATTACK_STATE"));
         }
         if(mCurrentScript != null)
         {
            if(mCurrentScript.isPlaying)
            {
               mCurrentScript.stop();
            }
            mCurrentScript = null;
         }
         super.exitState();
      }
      
      override public function destroy() 
      {
         exitState();
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }


