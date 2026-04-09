package actor.player.input.dBMouseEvents
;
   import actor.ActorGameObject;
   
    class MouseOverOnActorEvent extends DBMouseEvent
   {
      
      public static inline final TYPE= "MouseOverOnActorEvent";
      
      public function new(param1:ActorGameObject, param2:Bool = false, param3:Bool = false)
      {
         super("MouseOverOnActorEvent",param1,param2,param3);
      }
   }


