package account
;
   import facade.DBFacade;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMInventoryBase;
   import org.as3commons.collections.Map;
   
    class InventoryBaseInfo
   {
      
      var mDBFacade:DBFacade;
      
      var mDatabaseId:UInt = 0;
      
      var mGMId:UInt = 0;
      
      var mAccountId:UInt = 0;
      
      var mIsNew:Bool = false;
      
      var mGMInventoryBase:GMInventoryBase;
      
      var mGMChestInfo:GMChest;
      
      var mKeys:Map;
      
      public function new(param1:DBFacade, param2:ASObject)
      {
         
         mDBFacade = param1;
         parseJson(param2);
      }
      
      @:isVar public var Description(get,never):String;
public function  get_Description() : String
      {
         return mGMInventoryBase.Description;
      }
      
      @:isVar public var uiSwfFilepath(get,never):String;
public function  get_uiSwfFilepath() : String
      {
         return mGMInventoryBase != null ? mGMInventoryBase.UISwfFilepath : null;
      }
      
      @:isVar public var iconScale(get,never):Float;
public function  get_iconScale() : Float
      {
         return 100;
      }
      
      @:isVar public var iconName(get,never):String;
public function  get_iconName() : String
      {
         return mGMInventoryBase != null ? mGMInventoryBase.IconName : null;
      }
      
      @:isVar public var hasColoredBackground(get,never):Bool;
public function  get_hasColoredBackground() : Bool
      {
         return false;
      }
      
      @:isVar public var backgroundIconName(get,never):String;
public function  get_backgroundIconName() : String
      {
         return "";
      }
      
      @:isVar public var backgroundSwfPath(get,never):String;
public function  get_backgroundSwfPath() : String
      {
         return "";
      }
      
      @:isVar public var backgroundIconBorderName(get,never):String;
public function  get_backgroundIconBorderName() : String
      {
         return "";
      }
      
      @:isVar public var Name(get,never):String;
public function  get_Name() : String
      {
         return mGMInventoryBase.Name;
      }
      
      @:isVar public var sellCoins(get,never):Int;
public function  get_sellCoins() : Int
      {
         return mGMInventoryBase.SellCoins;
      }
      
      @:isVar public var gmInventoryBase(get,never):GMInventoryBase;
public function  get_gmInventoryBase() : GMInventoryBase
      {
         return mGMInventoryBase;
      }
      
      @:isVar public var gmChestInfo(get,never):GMChest;
public function  get_gmChestInfo() : GMChest
      {
         return mGMChestInfo;
      }
      
            
      @:isVar public var keys(get,set):Map;
public function  set_keys(param1:Map) :Map      {
         return mKeys = param1;
      }
function  get_keys() : Map
      {
         return mKeys;
      }
      
      @:isVar public var isEquipped(get,never):Bool;
public function  get_isEquipped() : Bool
      {
         return false;
      }
      
            
      @:isVar public var isNew(get,set):Bool;
public function  get_isNew() : Bool
      {
         return mIsNew;
      }
function  set_isNew(param1:Bool) :Bool      {
         return mIsNew = param1;
      }
      
      @:isVar public var databaseId(get,never):UInt;
public function  get_databaseId() : UInt
      {
         return mDatabaseId;
      }
      
      @:isVar public var gmId(get,never):UInt;
public function  get_gmId() : UInt
      {
         return mGMId;
      }
      
      @:isVar public var needsRenderer(get,never):Bool;
public function  get_needsRenderer() : Bool
      {
         return false;
      }
      
      function parseJson(param1:ASObject) 
      {
      }
      
      public function getTextColor() : UInt
      {
         return (16763904 : UInt);
      }
      
      public function hasGMPropertySetup() : Bool
      {
         return mGMInventoryBase != null || mGMChestInfo != null;
      }
   }


