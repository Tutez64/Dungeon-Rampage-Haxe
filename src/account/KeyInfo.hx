package account
;
   import gameMasterDictionary.GMKey;
   import gameMasterDictionary.GMOffer;
   
    class KeyInfo
   {
      
      var mGMKey:GMKey;
      
      var mGMKeyOffer:GMOffer;
      
      var mCount:UInt = 0;
      
      public function new(param1:GMKey, param2:GMOffer, param3:UInt)
      {
         
         mGMKey = param1;
         mGMKeyOffer = param2;
         mCount = param3;
      }
      
      @:isVar public var gmKey(get,never):GMKey;
public function  get_gmKey() : GMKey
      {
         return mGMKey;
      }
      
      @:isVar public var gmKeyOffer(get,never):GMOffer;
public function  get_gmKeyOffer() : GMOffer
      {
         return mGMKeyOffer;
      }
      
            
      @:isVar public var count(get,set):UInt;
public function  get_count() : UInt
      {
         return mCount;
      }
function  set_count(param1:UInt) :UInt      {
         return mCount = param1;
      }
   }


