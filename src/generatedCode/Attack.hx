package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class Attack
   {
      
      public var weaponSlot:Int = 0;
      
      public var isConsumableWeapon:UInt = 0;
      
      public var attackType:UInt = 0;
      
      public var targetActorDoid:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : Attack
      {
         var _loc2_= new Attack();
         _loc2_.weaponSlot = param1.readByte();
         _loc2_.isConsumableWeapon = param1.readUnsignedByte();
         _loc2_.attackType = param1.readUnsignedInt();
         _loc2_.targetActorDoid = param1.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeByte(weaponSlot);
         param1.writeByte((isConsumableWeapon : Int));
         param1.writeUnsignedInt(attackType);
         param1.writeUnsignedInt(targetActorDoid);
      }
   }


