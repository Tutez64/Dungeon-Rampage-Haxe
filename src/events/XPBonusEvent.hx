package events
;
   import facade.Locale;
   import flash.events.Event;
   
    class XPBonusEvent extends Event
   {
      
      public static inline final NAME= "XP_BONUS_EVENT";
      
      var mXPMultiplier:Float = Math.NaN;
      
      var mIsActive:Bool = false;
      
      public function new(param1:String, param2:Bool, param3:Float = 1, param4:Bool = false, param5:Bool = false)
      {
         super(param1,param4,param5);
         mIsActive = param2;
         mXPMultiplier = param3;
      }
      
      @:isVar public var isActive(get,never):Bool;
public function  get_isActive() : Bool
      {
         return mIsActive;
      }
      
      @:isVar public var xpMultiplier(get,never):Float;
public function  get_xpMultiplier() : Float
      {
         return mXPMultiplier;
      }
      
      @:isVar public var xpMultiplierBonusTextForHUD(get,never):String;
public function  get_xpMultiplierBonusTextForHUD() : String
      {
         return Locale.getString("BONUS_XP_" + Std.string(mXPMultiplier));
      }
      
      @:isVar public var xpMultiplierBonusTextForNewsFeed(get,never):String;
public function  get_xpMultiplierBonusTextForNewsFeed() : String
      {
         return Locale.getString("NEWS_FEED_BONUS_XP_" + Std.string(mXPMultiplier));
      }
   }


