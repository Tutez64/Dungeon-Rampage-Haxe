package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class WeaponDetails
   {
      
      public var type:UInt = 0;
      
      public var power:UInt = 0;
      
      public var requiredlevel:UInt = 0;
      
      public var rarity:UInt = 0;
      
      public var modifier1:UInt = 0;
      
      public var modifier2:UInt = 0;
      
      public var legendarymodifier:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : WeaponDetails
      {
         var _loc2_= new WeaponDetails();
         _loc2_.type = param1.readUnsignedInt();
         _loc2_.power = param1.readUnsignedShort();
         _loc2_.requiredlevel = param1.readUnsignedByte();
         _loc2_.rarity = param1.readUnsignedByte();
         _loc2_.modifier1 = param1.readUnsignedInt();
         _loc2_.modifier2 = param1.readUnsignedInt();
         _loc2_.legendarymodifier = param1.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(type);
         param1.writeShort((power : Int));
         param1.writeByte((requiredlevel : Int));
         param1.writeByte((rarity : Int));
         param1.writeUnsignedInt(modifier1);
         param1.writeUnsignedInt(modifier2);
         param1.writeUnsignedInt(legendarymodifier);
      }
   }


