package actor.stateMachine
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.stateMachine.State;
   import facade.DBFacade;
   
    class ActorState extends State
   {
      
      var mDBFacade:DBFacade;
      
      var mActorGameObject:ActorGameObject;
      
      var mActorView:ActorView;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:ActorView, param4:String, param5:ASFunction = null)
      {
         super(param4,param5);
         mDBFacade = param1;
         mActorGameObject = param2;
         mActorView = param3;
      }
      
      override public function destroy() 
      {
         mDBFacade = null;
         mActorGameObject = null;
         mActorView = null;
         super.destroy();
      }
   }


