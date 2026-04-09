package brain.utils
;
    class TimeSpan
   {
      
      public static inline final MILLISECONDS_IN_DAY:Float = 86400000;
      
      public static inline final MILLISECONDS_IN_HOUR:Float = 3600000;
      
      public static inline final MILLISECONDS_IN_MINUTE:Float = 60000;
      
      public static inline final MILLISECONDS_IN_SECOND:Float = 1000;
      
      var _totalMilliseconds:Float = Math.NaN;
      
      public function new(param1:Float)
      {
         
         _totalMilliseconds = Math.ffloor(param1);
      }
      
      public static function fromDates(param1:Date, param2:Date) : TimeSpan
      {
         return new TimeSpan(param2.getTime() - param1.getTime());
      }
      
      public static function fromMilliseconds(param1:Float) : TimeSpan
      {
         return new TimeSpan(param1);
      }
      
      public static function fromSeconds(param1:Float) : TimeSpan
      {
         return new TimeSpan(param1 * 1000);
      }
      
      public static function fromMinutes(param1:Float) : TimeSpan
      {
         return new TimeSpan(param1 * 60000);
      }
      
      public static function fromHours(param1:Float) : TimeSpan
      {
         return new TimeSpan(param1 * 3600000);
      }
      
      public static function fromDays(param1:Float) : TimeSpan
      {
         return new TimeSpan(param1 * 86400000);
      }
      
      @:isVar public var days(get,never):Int;
public function  get_days() : Int
      {
         return Std.int(_totalMilliseconds / 86400000);
      }
      
      @:isVar public var hours(get,never):Int;
public function  get_hours() : Int
      {
         return Std.int(_totalMilliseconds / 3600000) % 24;
      }
      
      @:isVar public var minutes(get,never):Int;
public function  get_minutes() : Int
      {
         return Std.int(_totalMilliseconds / 60000) % 60;
      }
      
      @:isVar public var seconds(get,never):Int;
public function  get_seconds() : Int
      {
         return Std.int(_totalMilliseconds / 1000) % 60;
      }
      
      @:isVar public var milliseconds(get,never):Int;
public function  get_milliseconds() : Int
      {
         return Std.int(_totalMilliseconds) % 1000;
      }
      
      @:isVar public var totalDays(get,never):Float;
public function  get_totalDays() : Float
      {
         return _totalMilliseconds / 86400000;
      }
      
      @:isVar public var totalHours(get,never):Float;
public function  get_totalHours() : Float
      {
         return _totalMilliseconds / 3600000;
      }
      
      @:isVar public var totalMinutes(get,never):Float;
public function  get_totalMinutes() : Float
      {
         return _totalMilliseconds / 60000;
      }
      
      @:isVar public var totalSeconds(get,never):Float;
public function  get_totalSeconds() : Float
      {
         return _totalMilliseconds / 1000;
      }
      
      @:isVar public var totalMilliseconds(get,never):Float;
public function  get_totalMilliseconds() : Float
      {
         return _totalMilliseconds;
      }
      
      public function getTimeBetweenTimeSpanAndNow(param1:Bool = false) : String
      {
         var _loc5_= Date.now();
         var _loc6_= new TimeSpan(this.totalMilliseconds - _loc5_.getTime());
         var _loc2_= Std.string(Math.abs(_loc6_.hours));
         if(_loc2_.length == 1)
         {
            _loc2_ = "0" + _loc2_;
         }
         var _loc4_= Std.string(Math.abs(_loc6_.minutes));
         if(_loc4_.length == 1)
         {
            _loc4_ = "0" + _loc4_;
         }
         var _loc3_= Std.string(Math.abs(_loc6_.seconds));
         if(_loc3_.length == 1)
         {
            _loc3_ = "0" + _loc3_;
         }
         if(param1 && _loc6_.totalMilliseconds < 0)
         {
            return "00:00:00";
         }
         return _loc2_ + ":" + _loc4_ + ":" + _loc3_;
      }
      
      public function add(param1:Date) : Date
      {
         var _loc2_= Date.fromTime(param1.getTime());
         ASCompat.ASDate.setMilliseconds(_loc2_, ASCompat.ASDate.getMilliseconds(_loc2_)+ totalMilliseconds);
         return _loc2_;
      }
   }


