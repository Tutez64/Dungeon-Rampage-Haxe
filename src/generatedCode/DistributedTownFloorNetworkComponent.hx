package generatedCode
;
   import distributedObjects.DistributedTownFloor;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedTownFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedTownFloor;
      
      public static inline final FLID_tileLibrary= (205 : UInt);
      
      public static inline final FLID_tiles= (206 : UInt);
      
      public function new(param1:DistributedTownFloor, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedTownFloorNetworkComponent
      {
         var _loc5_= new DistributedTownFloor(param2.facade,param3);
         var _loc4_= new DistributedTownFloorNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedTownFloor(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 205)
         {
            case 0:
               recv_tileLibrary(param1);
               
            case 1:
               recv_tiles(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_tileLibrary(param1);
         recv_tiles(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_tileLibrary(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.tileLibrary(_loc2_);
      }
      
      public function recv_tiles(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var tiles= (function(param1:DcNetworkPacket):Vector<DungeonTileUsage>
         {
            var _loc5_:DungeonTileUsage = null;
            var _loc3_= new Vector<DungeonTileUsage>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonTileUsage.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tiles(tiles);
      }
   }


