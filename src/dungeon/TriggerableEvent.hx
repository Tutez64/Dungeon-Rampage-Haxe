package dungeon
;
    class TriggerableEvent
   {
      
      public var triggerableId:UInt = 0;
      
      public var eventName:String;
      
      public function new(param1:UInt, param2:String)
      {
         
         triggerableId = param1;
         eventName = param2;
      }
   }


