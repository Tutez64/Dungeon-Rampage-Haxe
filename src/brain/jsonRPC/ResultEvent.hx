package brain.jsonRPC
;
   import flash.events.Event;
   
    class ResultEvent extends Event
   {
      
      public static inline final Result= "result";
      
      public var result:ASAny;
      
      public function new(param1:ASAny)
      {
         this.result = param1;
         super("result");
      }
   }


