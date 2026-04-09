package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class MovementAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "move";
      
      var mMovementType:String;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:String)
      {
         super(param1,param2,param3);
         mMovementType = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : MovementAttackTimelineAction
      {
         var _loc5_:String = param4.movementType;
         return new MovementAttackTimelineAction(param1,param2,param3,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorGameObject.movementControllerType = mMovementType;
      }
   }


