package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.stateMachine.StateMachine;
   import facade.DBFacade;
   
    class ActorStateMachine extends StateMachine
   {
      
      var mDBFacade:DBFacade;
      
      var mActorGameObject:ActorGameObject;
      
      var mActorView:ActorView;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView)
      {
         super();
         mDBFacade = param1;
         mActorGameObject = param2;
         mActorView = param3;
      }
      
      override public function destroy() 
      {
         mActorView = null;
         mActorGameObject = null;
         mDBFacade = null;
         super.destroy();
      }
   }


