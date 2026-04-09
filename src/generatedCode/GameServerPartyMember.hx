package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class GameServerPartyMember
   {
      
      public var id:UInt = 0;
      
      public var status:Int = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : GameServerPartyMember
      {
         var _loc2_= new GameServerPartyMember();
         _loc2_.id = param1.readUnsignedInt();
         _loc2_.status = param1.readByte();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(id);
         param1.writeByte(status);
      }
   }


