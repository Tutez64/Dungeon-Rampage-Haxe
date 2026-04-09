package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class InfiniteRewardData
   {
      
      public var dooberId:UInt = 0;
      
      public var floorNumber:UInt = 0;
      
      public var status:Int = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : InfiniteRewardData
      {
         var _loc2_= new InfiniteRewardData();
         _loc2_.dooberId = param1.readUnsignedInt();
         _loc2_.floorNumber = param1.readUnsignedShort();
         _loc2_.status = param1.readByte();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(dooberId);
         param1.writeShort((floorNumber : Int));
         param1.writeByte(status);
      }
   }


