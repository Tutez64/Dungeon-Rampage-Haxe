package actor.player.input
;
   import flash.events.Event;
   
    class DungeonBusterControlActivatedEvent extends Event
   {
      
      public static inline final TYPE= "DungeonBusterControlActivatedEvent";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("DungeonBusterControlActivatedEvent",param1,param2);
      }
   }


