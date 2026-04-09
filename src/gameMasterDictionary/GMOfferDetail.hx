package gameMasterDictionary
;
    class GMOfferDetail
   {
      
      public var OfferId:UInt = 0;
      
      public var WeaponId:UInt = 0;
      
      public var WeaponPower:UInt = 0;
      
      public var Level:UInt = 0;
      
      public var Rarity:String;
      
      public var Modifier1:String;
      
      public var Modifier2:String;
      
      public var Modifier3:String;
      
      public var ChestId:UInt = 0;
      
      public var HeroId:UInt = 0;
      
      public var PetId:UInt = 0;
      
      public var SkinId:UInt = 0;
      
      public var StackableId:UInt = 0;
      
      public var StackableCount:UInt = 0;
      
      public var Coins:UInt = 0;
      
      public var BasicKeys:UInt = 0;
      
      public var UncommonKeys:UInt = 0;
      
      public var RareKeys:UInt = 0;
      
      public var LegendaryKeys:UInt = 0;
      
      public var WeaponSlots:UInt = 0;
      
      public var Gems:UInt = 0;
      
      public function new(param1:ASObject)
      {
         
         OfferId = (ASCompat.toInt(param1.OfferId) : UInt);
         WeaponId = (ASCompat.toInt(param1.WeaponId) : UInt);
         WeaponPower = (ASCompat.toInt(param1.WeaponPower) : UInt);
         Level = (ASCompat.toInt(param1.Level != null ? (ASCompat.toInt(param1.Level) : UInt) : (0 : UInt)) : UInt);
         Rarity = param1.Rarity;
         Modifier1 = param1.Modifier1;
         Modifier2 = param1.Modifier2;
         Modifier3 = param1.Modifier3;
         ChestId = (ASCompat.toInt(param1.ChestId) : UInt);
         HeroId = (ASCompat.toInt(param1.HeroId) : UInt);
         PetId = (ASCompat.toInt(param1.PetId) : UInt);
         SkinId = (ASCompat.toInt(param1.SkinId) : UInt);
         StackableId = (ASCompat.toInt(param1.StackableId) : UInt);
         StackableCount = (ASCompat.toInt(param1.StackableCount) : UInt);
         Coins = (ASCompat.toInt(param1.Coins) : UInt);
         BasicKeys = (ASCompat.toInt(param1.BasicKeys) : UInt);
         UncommonKeys = (ASCompat.toInt(param1.UncommonKeys) : UInt);
         RareKeys = (ASCompat.toInt(param1.RareKeys) : UInt);
         LegendaryKeys = (ASCompat.toInt(param1.LegendaryKeys) : UInt);
         WeaponSlots = (ASCompat.toInt(param1.WeaponSlots) : UInt);
         Gems = (ASCompat.toInt(param1.Gems) : UInt);
      }
   }


