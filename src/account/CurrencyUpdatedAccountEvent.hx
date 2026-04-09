package account
;
   import flash.events.Event;
   
    class CurrencyUpdatedAccountEvent extends Event
   {
      
      public static inline final EVENT_NAME= "CurrencyUpdatedAccountEvent";
      
      var mBasicCurrency:UInt = 0;
      
      var mPremiumCurrency:UInt = 0;
      
      public function new(param1:UInt, param2:UInt, param3:Bool = false, param4:Bool = false)
      {
         super("CurrencyUpdatedAccountEvent",param3,param4);
         mPremiumCurrency = param2;
         mBasicCurrency = param1;
      }
      
      @:isVar public var basicCurrency(get,never):UInt;
public function  get_basicCurrency() : UInt
      {
         return mBasicCurrency;
      }
      
      @:isVar public var premiumCurrency(get,never):UInt;
public function  get_premiumCurrency() : UInt
      {
         return mPremiumCurrency;
      }
   }


