package steamAchievements
;
    class SteamAchievement
   {
      
      var mAPIName:String;
      
      var mIsAchieved:Bool = false;
      
      public function new(param1:String)
      {
         
         mAPIName = param1;
         mIsAchieved = false;
      }
      
      public static function steamAchievementFactory(param1:String) : SteamAchievement
      {
         return new SteamAchievement(param1);
      }
      
      @:isVar public var APIName(get,never):String;
public function  get_APIName() : String
      {
         return mAPIName;
      }
      
      @:isVar public var IsAchieved(get,never):Bool;
public function  get_IsAchieved() : Bool
      {
         return mIsAchieved;
      }
      
      public function setIsAchieved(param1:Bool) 
      {
         mIsAchieved = param1;
      }
   }


