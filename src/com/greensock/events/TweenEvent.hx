package com.greensock.events
;
   import flash.events.Event;
   
    class TweenEvent extends Event
   {
      
      public static inline final VERSION:Float = 1.1;
      
      public static inline final START= "start";
      
      public static inline final UPDATE= "change";
      
      public static inline final COMPLETE= "complete";
      
      public static inline final REVERSE_COMPLETE= "reverseComplete";
      
      public static inline final REPEAT= "repeat";
      
      public static inline final INIT= "init";
      
      public function new(param1:String, param2:Bool = false, param3:Bool = false)
      {
         super(param1,param2,param3);
      }
      
      override public function clone() : Event
      {
         return new TweenEvent(this.type,this.bubbles,this.cancelable);
      }
   }


