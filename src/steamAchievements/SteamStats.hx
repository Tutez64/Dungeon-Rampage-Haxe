package steamAchievements
;
    class SteamStats
   {
      
      public static inline final INT_STAT= 0;
      
      var mAPIName:String;
      
      var mStatType:Int = 0;
      
      var mClientIntValue:Int = 0;
      
      var mStoreStatsThreshold:Int = 0;
      
      public function new(param1:String, param2:Int, param3:Int = 1)
      {
         
         mAPIName = param1;
         mStatType = param2;
         mStoreStatsThreshold = param3;
      }
      
      public static function steamStatFactory(param1:String, param2:Int, param3:Int) : SteamStats
      {
         return new SteamStats(param1,param2,param3);
      }
      
      @:isVar public var APIName(get,never):String;
public function  get_APIName() : String
      {
         return mAPIName;
      }
      
      @:isVar public var StatType(get,never):Int;
public function  get_StatType() : Int
      {
         return mStatType;
      }
      
      @:isVar public var ClientIntValue(get,never):Int;
public function  get_ClientIntValue() : Int
      {
         return mClientIntValue;
      }
      
      @:isVar public var StoreStatsThreshold(get,never):Int;
public function  get_StoreStatsThreshold() : Int
      {
         return mStoreStatsThreshold;
      }
      
      public function setClientIntValue(param1:Int) 
      {
         mClientIntValue = param1;
      }
      
      public function increaseClientIntValue(param1:Int) 
      {
         mClientIntValue += param1;
      }
   }


