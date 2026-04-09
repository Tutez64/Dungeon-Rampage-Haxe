package generatedCode
;
   import distributedObjects.DistributedDungeonSummary;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedDungeonSummaryNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedDungeonSummary;
      
      public static inline final FLID_map_node_id= (274 : UInt);
      
      public static inline final FLID_report= (275 : UInt);
      
      public static inline final FLID_dungeon_name= (276 : UInt);
      
      public static inline final FLID_dungeonSuccess= (277 : UInt);
      
      public static inline final FLID_dungeonMod1= (278 : UInt);
      
      public static inline final FLID_dungeonMod2= (279 : UInt);
      
      public static inline final FLID_dungeonMod3= (280 : UInt);
      
      public static inline final FLID_dungeonMod4= (281 : UInt);
      
      public static inline final FLID_OpenChest= (282 : UInt);
      
      public static inline final FLID_TakeChest= (283 : UInt);
      
      public static inline final FLID_DropChest= (284 : UInt);
      
      public static inline final FLID_TransactionResponse= (285 : UInt);
      
      public function new(param1:DistributedDungeonSummary, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedDungeonSummaryNetworkComponent
      {
         var _loc5_= new DistributedDungeonSummary(param2.facade,param3);
         var _loc4_= new DistributedDungeonSummaryNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedDungeonSummary(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 274)
         {
            case 0:
               recv_map_node_id(param1);
               
            case 1:
               recv_report(param1);
               
            case 2:
               recv_dungeon_name(param1);
               
            case 3:
               recv_dungeonSuccess(param1);
               
            case 4:
               recv_dungeonMod1(param1);
               
            case 5:
               recv_dungeonMod2(param1);
               
            case 6:
               recv_dungeonMod3(param1);
               
            case 7:
               recv_dungeonMod4(param1);
               
            case 11:
               recv_TransactionResponse(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_map_node_id(param1);
         recv_report(param1);
         recv_dungeon_name(param1);
         recv_dungeonSuccess(param1);
         recv_dungeonMod1(param1);
         recv_dungeonMod2(param1);
         recv_dungeonMod3(param1);
         recv_dungeonMod4(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_map_node_id(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.map_node_id = _loc2_;
      }
      
      public function recv_report(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_report= (function(param1:DcNetworkPacket):Vector<DungeonReport>
         {
            var _loc5_:DungeonReport = null;
            var _loc3_= new Vector<DungeonReport>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonReport.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.report = v_report;
      }
      
      public function recv_dungeon_name(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.dungeon_name = _loc2_;
      }
      
      public function recv_dungeonSuccess(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.dungeonSuccess = _loc2_;
      }
      
      public function recv_dungeonMod1(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.dungeonMod1 = _loc2_;
      }
      
      public function recv_dungeonMod2(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.dungeonMod2 = _loc2_;
      }
      
      public function recv_dungeonMod3(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.dungeonMod3 = _loc2_;
      }
      
      public function recv_dungeonMod4(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.dungeonMod4 = _loc2_;
      }
      
      public function send_OpenChest(param1:UInt, param2:UInt) 
      {
         var _loc3_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,(282 : UInt));
         _loc3_.writeUnsignedInt(param1);
         _loc3_.writeUnsignedInt(param2);
         Send_packet(_loc3_);
      }
      
      public function send_TakeChest(param1:UInt, param2:UInt) 
      {
         var _loc3_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,(283 : UInt));
         _loc3_.writeUnsignedInt(param1);
         _loc3_.writeUnsignedInt(param2);
         Send_packet(_loc3_);
      }
      
      public function send_DropChest(param1:UInt, param2:UInt) 
      {
         var _loc3_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,(284 : UInt));
         _loc3_.writeUnsignedInt(param1);
         _loc3_.writeUnsignedInt(param2);
         Send_packet(_loc3_);
      }
      
      public function recv_TransactionResponse(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         var _loc4_= param1.readUnsignedByte();
         var _loc3_= param1.readUnsignedInt();
         var _loc5_= param1.readUnsignedInt();
         the_instance.TransactionResponse(_loc2_,_loc4_,_loc3_,_loc5_);
      }
   }


