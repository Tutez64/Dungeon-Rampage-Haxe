package events
;
   import flash.events.Event;
   
    class FacebookLevelUpPostEvent extends Event
   {
      
      public static inline final NAME= "FacebookLevelUpPostEvent";
      
      var mLevel:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:Bool = false, param4:Bool = false)
      {
         super(param1,param3,param4);
         mLevel = param2;
      }
      
      @:isVar public var level(get,never):UInt;
public function  get_level() : UInt
      {
         return mLevel;
      }
   }


