package events
;
   import flash.events.Event;
   
    class GameObjectEvent extends Event
   {
      
      public var id:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:Bool = false, param4:Bool = false)
      {
         this.id = param2;
         super(uniqueEvent(param1,param2),param3,param4);
      }
      
      public static function uniqueEvent(param1:String, param2:UInt) : String
      {
         return param1 + "_" + Std.string(param2);
      }
   }


