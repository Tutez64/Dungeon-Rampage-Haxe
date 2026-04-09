package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class DungeonTileUsage
   {
      
      public var x:Int = 0;
      
      public var y:Int = 0;
      
      public var tileId:String;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : DungeonTileUsage
      {
         var _loc2_= new DungeonTileUsage();
         _loc2_.x = param1.readInt();
         _loc2_.y = param1.readInt();
         _loc2_.tileId = param1.readUTF();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeInt(x);
         param1.writeInt(y);
         param1.writeUTF(tileId);
      }
   }


