package events
;
   import flash.events.Event;
   
    class FriendshipEvent extends Event
   {
      
      public var id:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:Bool = false, param4:Bool = false)
      {
         super(param1,param3,param4);
         this.id = param2;
      }
   }


