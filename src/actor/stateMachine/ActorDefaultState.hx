package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import actor.stateMachine.subStateMachine.ActorSubStateMachine;
   import combat.attack.ScriptTimeline;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class ActorDefaultState extends ActorState
   {
      
      public static inline final NAME= "ActorDefaultState";
      
      var mSubStateMachine:ActorSubStateMachine;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView, param4:ASFunction = null)
      {
         super(param1,param2,param3,"ActorDefaultState",param4);
         mSubStateMachine = new ActorSubStateMachine(param1,param2,param3);
      }
      
      override public function enterState() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         super.enterState();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
            _loc1_.startUserInput();
         }
         mSubStateMachine.enterNavigationState();
      }
      
      override public function exitState() 
      {
         var _loc1_:HeroGameObjectOwner = null;
         mSubStateMachine.exit();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
            _loc1_.stopUserInput();
         }
         super.exitState();
      }
      
      public function enterChoreographyState(param1:Float, param2:ActorGameObject, param3:ScriptTimeline, param4:ASFunction = null, param5:ASFunction = null, param6:Bool = false) 
      {
         mSubStateMachine.enterChoreographyState(param1,param2,param3,param4,param5,param6);
      }
      
      public function enterNavigationState() 
      {
         mSubStateMachine.enterNavigationState();
      }
      
      @:isVar public var currentSubState(get,never):ActorState;
public function  get_currentSubState() : ActorState
      {
         return ASCompat.dynamicAs(mSubStateMachine.currentState , ActorState);
      }
      
      override public function destroy() 
      {
         mSubStateMachine.destroy();
         mSubStateMachine = null;
         super.destroy();
      }
   }


