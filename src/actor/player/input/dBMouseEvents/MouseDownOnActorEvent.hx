package actor.player.input.dBMouseEvents
;
   import actor.ActorGameObject;
   
    class MouseDownOnActorEvent extends DBMouseEvent
   {
      
      public static inline final TYPE= "MouseDownOnActorEvent";
      
      public function new(param1:ActorGameObject, param2:Bool = false, param3:Bool = false)
      {
         super("MouseDownOnActorEvent",param1,param2,param3);
      }
   }


