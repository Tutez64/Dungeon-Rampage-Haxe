package actor.player.input.dBMouseEvents
;
   import actor.ActorGameObject;
   
    class MouseOutOnActorEvent extends DBMouseEvent
   {
      
      public static inline final TYPE= "MouseOutOnActorEvent";
      
      public function new(param1:ActorGameObject, param2:Bool = false, param3:Bool = false)
      {
         super("MouseOutOnActorEvent",param1,param2,param3);
      }
   }


