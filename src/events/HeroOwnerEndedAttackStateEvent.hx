package events
;
   import flash.events.Event;
   
    class HeroOwnerEndedAttackStateEvent extends Event
   {
      
      public static inline final EVENT_NAME= "PLAYER_ENDED_ATTACK_STATE";
      
      public function new(param1:String, param2:Bool = false, param3:Bool = false)
      {
         super(param1,param2,param3);
      }
   }


