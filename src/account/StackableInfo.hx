package account
;
   import facade.DBFacade;
   import gameMasterDictionary.GMStackable;
   
    class StackableInfo extends InventoryBaseInfo
   {
      
      var mCount:UInt = 0;
      
      var mGMStackable:GMStackable;
      
      var mConsumableSlot:Int = -1;
      
      public function new(param1:DBFacade, param2:ASObject, param3:GMStackable = null)
      {
         if(param2 == null)
         {
            mDBFacade = param1;
            mGMStackable = param3;
         }
         else
         {
            super(param1,param2);
            mGMStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(mGMId), gameMasterDictionary.GMStackable);
         }
         mGMInventoryBase = mGMStackable;
      }
      
      @:isVar public var gmStackable(get,never):GMStackable;
public function  get_gmStackable() : GMStackable
      {
         return mGMStackable;
      }
      
      override public function  get_isEquipped() : Bool
      {
         return this.gmStackable != null && mConsumableSlot != -1 && this.gmStackable.AccountBooster == false;
      }
      
      @:isVar public var equipSlot(get,never):Int;
public function  get_equipSlot() : Int
      {
         return mConsumableSlot;
      }
      
            
      @:isVar public var count(get,set):UInt;
public function  get_count() : UInt
      {
         return mCount;
      }
function  set_count(param1:UInt) :UInt      {
         return mCount = param1;
      }
      
      override function parseJson(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mGMId = ASCompat.asUint(param1.stack_id );
         mAccountId = ASCompat.asUint(param1.account_id );
         mDatabaseId = ASCompat.asUint(param1.id );
         mCount = ASCompat.asUint(param1.count );
         mIsNew = false;
         mConsumableSlot = -1;
      }
      
      public function setPropertiesAsConsumable(param1:UInt, param2:UInt, param3:UInt) 
      {
         mGMId = param1;
         mAccountId = (0 : UInt);
         mDatabaseId = (0 : UInt);
         mCount = param3;
         mConsumableSlot = (param2 : Int);
         mIsNew = false;
      }
      
      public function setConsumableSlot(param1:UInt) 
      {
         mConsumableSlot = (param1 : Int);
      }
      
      override public function  get_hasColoredBackground() : Bool
      {
         return false;
      }
      
      override public function  get_backgroundIconName() : String
      {
         return "";
      }
      
      override public function  get_backgroundSwfPath() : String
      {
         return "";
      }
      
      override public function hasGMPropertySetup() : Bool
      {
         return mGMStackable != null;
      }
      
      @:isVar public var consumableSlot(get,never):Int;
public function  get_consumableSlot() : Int
      {
         return mConsumableSlot;
      }
   }


