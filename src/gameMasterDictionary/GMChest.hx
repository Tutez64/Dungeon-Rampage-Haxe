package gameMasterDictionary
;
    class GMChest
   {
      
      public var Id:UInt = 0;
      
      public var Name:String;
      
      public var Rarity:String;
      
      public var IconName:String;
      
      public var IconSwf:String;
      
      public var InventoryRevealName:String;
      
      public var InventoryRevealSwf:String;
      
      public var Description:String;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Name = param1.Name;
         Rarity = param1.Rarity;
         IconName = param1.IconName;
         IconSwf = param1.IconSwf;
         InventoryRevealName = param1.InventoryRevealName;
         InventoryRevealSwf = param1.InventoryRevealSwf;
         Description = param1.Description;
      }
   }


