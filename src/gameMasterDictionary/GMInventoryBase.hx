package gameMasterDictionary
;
    class GMInventoryBase extends GMItem
   {
      
      public static inline final WEAPON_CATEGORY= "WEAPON";
      
      public static inline final POWERUP_CATEGORY= "POWERUP";
      
      public static inline final PET_CATEGORY= "PET";
      
      public static inline final STUFF_CATEGORY= "STUFF";
      
      public var Coins:Int = 0;
      
      public var Cash:Int = 0;
      
      public var CashB:Int = 0;
      
      public var CashC:Int = 0;
      
      public var CashD:Int = 0;
      
      public var CashE:Int = 0;
      
      public var CashF:Int = 0;
      
      public var CashG:Int = 0;
      
      public var CashH:Int = 0;
      
      public var CashI:Int = 0;
      
      public var SellCoins:Int = 0;
      
      public var IconName:String;
      
      public var UISwfFilepath:String;
      
      public var Description:String;
      
      public var ItemCategory:String;
      
      public var ItemSubclass:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         Coins = ASCompat.toInt(param1.Coins);
         Cash = ASCompat.toInt(param1.Cash);
         CashB = ASCompat.toInt(param1.CashB);
         CashC = ASCompat.toInt(param1.CashC);
         CashD = ASCompat.toInt(param1.CashD);
         CashE = ASCompat.toInt(param1.CashE);
         CashF = ASCompat.toInt(param1.CashF);
         CashG = ASCompat.toInt(param1.CashG);
         CashH = ASCompat.toInt(param1.CashH);
         CashI = ASCompat.toInt(param1.CashI);
         SellCoins = ASCompat.toInt(param1.SellCoins);
         ItemCategory = param1.ItemCategory;
         ItemSubclass = param1.ItemSubclass;
         IconName = param1.IconName;
         UISwfFilepath = param1.UISwfFilepath;
         Description = param1.Description;
      }
   }


