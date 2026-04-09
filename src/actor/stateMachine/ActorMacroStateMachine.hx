package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import combat.attack.AttackTimeline;
   import combat.attack.ScriptTimeline;
   import facade.DBFacade;
   import generatedCode.AttackChoreography;
   import generatedCode.CombatResult;
   
    class ActorMacroStateMachine extends ActorStateMachine
   {
      
      var mDefaultState:ActorDefaultState;
      
      var mDeadState:ActorDeadState;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView)
      {
         super(param1,param2,param3);
         mDefaultState = new ActorDefaultState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mDefaultState,"ActorDefaultState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
         mDeadState = new ActorDeadState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mDeadState,"ActorDeadState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
      }
      
      public function enterAttackChoreographyState(param1:Float, param2:ActorGameObject, param3:AttackTimeline, param4:AttackChoreography, param5:ASFunction = null, param6:ASFunction = null, param7:Bool = false) 
      {
         param3.appendChoreography(param4);
         var _loc8_= param4.loop == 1 ? true : false;
         param3.currentAttackType = param4.attack.attackType;
         param3.projectileMultiplier = (Std.int(param4.scalingMaxProjectiles) : UInt);
         enterChoreographyState(param1,param2,param3,param5,param6,param7);
      }
      
      public function enterCombatResultChoreographyState(param1:Float, param2:ActorGameObject, param3:ScriptTimeline, param4:CombatResult, param5:ActorGameObject, param6:ASFunction = null, param7:ASFunction = null, param8:Bool = false) 
      {
         param3.currentAttackType = param4.attack.attackType;
         param3.currentCombatResult = param4;
         param3.currentAttacker = param5;
         enterChoreographyState(param1,param2,param3,param6,param7,param8);
      }
      
      public function enterChoreographyState(param1:Float, param2:ActorGameObject, param3:ScriptTimeline, param4:ASFunction = null, param5:ASFunction = null, param6:Bool = false, param7:Bool = false) 
      {
         var _loc8_:ActorDefaultState = null;
         if(this.currentState == mDefaultState)
         {
            _loc8_ = ASCompat.dynamicAs(this.currentState , ActorDefaultState);
            param3.autoAim = param7;
            _loc8_.enterChoreographyState(param1,param2,param3,param4,param5,param6);
         }
         else
         {
            Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
         }
      }
      
      public function enterNavigationState() 
      {
         var _loc1_:ActorDefaultState = null;
         if(this.currentState == mDefaultState)
         {
            _loc1_ = ASCompat.dynamicAs(this.currentState , ActorDefaultState);
            _loc1_.enterNavigationState();
         }
         else
         {
            Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
         }
      }
      
      @:isVar public var currentSubState(get,never):ActorState;
public function  get_currentSubState() : ActorState
      {
         if(ASCompat.dynamicAs(this.currentState , ActorState) == mDefaultState)
         {
            return mDefaultState.currentSubState;
         }
         return null;
      }
      
      public function enterDeadState(param1:ASFunction) 
      {
         mDeadState.finishedCallback = param1;
         this.transitionToState(mDeadState);
      }
      
      public function enterDefaultState() 
      {
         this.transitionToState(mDefaultState);
      }
      
      override public function destroy() 
      {
         mDefaultState.destroy();
         mDefaultState = null;
         mDeadState.destroy();
         mDeadState = null;
         super.destroy();
      }
   }


