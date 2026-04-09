package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class DungeonModifier
   {
      
      public var id:UInt = 0;
      
      public var new_this_floor:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : DungeonModifier
      {
         var _loc2_= new DungeonModifier();
         _loc2_.id = param1.readUnsignedInt();
         _loc2_.new_this_floor = param1.readUnsignedByte();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(id);
         param1.writeByte((new_this_floor : Int));
      }
   }


