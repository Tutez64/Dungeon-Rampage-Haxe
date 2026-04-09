package account
;
   import facade.DBFacade;
   import gameMasterDictionary.GMNpc;
   
    class PetInfo extends InventoryBaseInfo
   {
      
      public var PetType:UInt = 0;
      
      public var EquippedHero:UInt = 0;
      
      var mGMNpc:GMNpc;
      
      public function new(param1:DBFacade, param2:ASObject)
      {
         super(param1,param2);
         mDBFacade = param1;
         PetType = mGMId = ASCompat.asUint(param2.npc_id );
         EquippedHero = ASCompat.asUint(param2.equipped_hero );
         mDatabaseId = ASCompat.asUint(param2.id );
         mGMNpc = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(PetType), gameMasterDictionary.GMNpc);
         mIsNew = false;
      }
      
      override public function  get_iconScale() : Float
      {
         return 68;
      }
      
      @:isVar public var attackRating(get,never):UInt;
public function  get_attackRating() : UInt
      {
         return mGMNpc.AttackRating;
      }
      
      @:isVar public var defenseRating(get,never):UInt;
public function  get_defenseRating() : UInt
      {
         return mGMNpc.DefenseRating;
      }
      
      @:isVar public var speedRating(get,never):UInt;
public function  get_speedRating() : UInt
      {
         return mGMNpc.SpeedRating;
      }
      
      override public function  get_isEquipped() : Bool
      {
         return EquippedHero != 0;
      }
      
      override public function  get_uiSwfFilepath() : String
      {
         return mGMNpc.IconSwfFilepath;
      }
      
      override public function  get_iconName() : String
      {
         return mGMNpc.IconName;
      }
      
      override public function  get_Name() : String
      {
         return mGMNpc.Name;
      }
      
      override public function  get_sellCoins() : Int
      {
         return mGMNpc.SellCoins;
      }
      
      @:isVar public var gmNpc(get,never):GMNpc;
public function  get_gmNpc() : GMNpc
      {
         return mGMNpc;
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
         return mGMNpc != null;
      }
   }


