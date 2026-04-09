package account
;
   import brain.event.EventComponent;
   import events.GenericNewsFeedEvent;
   import events.XPBonusEvent;
   import facade.DBFacade;
   import flash.events.Event;
   
    class AccountBonus
   {
      
      public static inline final BONUS_XP_CHANGED_EVENT= "BONUS_XP_CHANGED_EVENT";
      
      public static inline final BONUS_COIN_CHANGED_EVENT= "BONUS_COIN_CHANGED_EVENT";
      
      var mDBFacade:DBFacade;
      
      var mXPBonusMultiplier:Float = 1;
      
      var mXPBonusActive:Bool = false;
      
      var mXPBonusText:String = "";
      
      var mCoinBonusActive:Bool = false;
      
      var mCoinBonusText:String = "";
      
      var mCoinBonusMultiplier:Float = 1;
      
      var mUINewsFeedXPBonusText:String = "";
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("XP_BONUS_EVENT",setXPBonusStuff);
      }
      
      public function destroy() 
      {
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mDBFacade = null;
      }
      
      public function setXPBonusStuff(param1:XPBonusEvent) 
      {
         mXPBonusActive = param1.isActive;
         mXPBonusMultiplier = param1.xpMultiplier;
         mXPBonusText = param1.xpMultiplierBonusTextForHUD;
         mUINewsFeedXPBonusText = param1.xpMultiplierBonusTextForNewsFeed;
         mEventComponent.dispatchEvent(new Event("BONUS_XP_CHANGED_EVENT"));
         if(mXPBonusMultiplier > 1)
         {
            mEventComponent.dispatchEvent(new GenericNewsFeedEvent("GENERIC_NEWS_FEED_MESSAGE_EVENT",mUINewsFeedXPBonusText,DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),"UI_alert_doublexp"));
         }
      }
      
      @:isVar public var xpBonusMultiplier(get,never):Float;
public function  get_xpBonusMultiplier() : Float
      {
         return mXPBonusMultiplier;
      }
      
      @:isVar public var isXPBonusActive(get,never):Bool;
public function  get_isXPBonusActive() : Bool
      {
         return mXPBonusActive;
      }
      
      @:isVar public var isCoinBonusActive(get,never):Bool;
public function  get_isCoinBonusActive() : Bool
      {
         return mCoinBonusActive;
      }
      
      @:isVar public var xpBonusText(get,never):String;
public function  get_xpBonusText() : String
      {
         return mXPBonusText;
      }
      
      @:isVar public var coinBonusText(get,never):String;
public function  get_coinBonusText() : String
      {
         return mCoinBonusText;
      }
   }


