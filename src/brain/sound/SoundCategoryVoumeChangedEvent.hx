package brain.sound
;
   import flash.events.Event;
   
    class SoundCategoryVoumeChangedEvent extends Event
   {
      
      public static inline final TYPE= "SoundCategoryVoumeChangedEvent";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("SoundCategoryVoumeChangedEvent",param1,param2);
      }
   }


