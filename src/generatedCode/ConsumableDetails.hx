package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class ConsumableDetails
   {
      
      public var type:UInt = 0;
      
      public var count:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : ConsumableDetails
      {
         var _loc2_= new ConsumableDetails();
         _loc2_.type = param1.readUnsignedInt();
         _loc2_.count = param1.readUnsignedShort();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(type);
         param1.writeShort((count : Int));
      }
   }


