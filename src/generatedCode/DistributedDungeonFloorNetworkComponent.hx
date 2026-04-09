package generatedCode
;
   import distributedObjects.DistributedDungeonFloor;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedDungeonFloorNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedDungeonFloor;
      
      public static inline final FLID_mapNodeId= (192 : UInt);
      
      public static inline final FLID_coliseumTierConstant= (193 : UInt);
      
      public static inline final FLID_tileLibrary= (194 : UInt);
      
      public static inline final FLID_tiles= (195 : UInt);
      
      public static inline final FLID_baseLining= (196 : UInt);
      
      public static inline final FLID_introMovieSwfFilePath= (197 : UInt);
      
      public static inline final FLID_introMovieAssetClassName= (198 : UInt);
      
      public static inline final FLID_currentFloorNum= (199 : UInt);
      
      public static inline final FLID_activeDungeonModifiers= (200 : UInt);
      
      public static inline final FLID_show_text= (201 : UInt);
      
      public static inline final FLID_play_sound= (202 : UInt);
      
      public static inline final FLID_trigger_camera_zoom= (203 : UInt);
      
      public static inline final FLID_trigger_camera_shake= (204 : UInt);
      
      public function new(param1:DistributedDungeonFloor, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedDungeonFloorNetworkComponent
      {
         var _loc5_= new DistributedDungeonFloor(param2.facade,param3);
         var _loc4_= new DistributedDungeonFloorNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedDungeonFloor(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 192)
         {
            case 0:
               recv_mapNodeId(param1);
               
            case 1:
               recv_coliseumTierConstant(param1);
               
            case 2:
               recv_tileLibrary(param1);
               
            case 3:
               recv_tiles(param1);
               
            case 4:
               recv_baseLining(param1);
               
            case 5:
               recv_introMovieSwfFilePath(param1);
               
            case 6:
               recv_introMovieAssetClassName(param1);
               
            case 7:
               recv_currentFloorNum(param1);
               
            case 8:
               recv_activeDungeonModifiers(param1);
               
            case 9:
               recv_show_text(param1);
               
            case 10:
               recv_play_sound(param1);
               
            case 11:
               recv_trigger_camera_zoom(param1);
               
            case 12:
               recv_trigger_camera_shake(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_mapNodeId(param1);
         recv_coliseumTierConstant(param1);
         recv_tileLibrary(param1);
         recv_tiles(param1);
         recv_baseLining(param1);
         recv_introMovieSwfFilePath(param1);
         recv_introMovieAssetClassName(param1);
         recv_currentFloorNum(param1);
         recv_activeDungeonModifiers(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_mapNodeId(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.mapNodeId = _loc2_;
      }
      
      public function recv_coliseumTierConstant(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.coliseumTierConstant = _loc2_;
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
      
      public function recv_baseLining(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.baseLining = _loc2_;
      }
      
      public function recv_introMovieSwfFilePath(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.introMovieSwfFilePath = _loc2_;
      }
      
      public function recv_introMovieAssetClassName(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.introMovieAssetClassName = _loc2_;
      }
      
      public function recv_currentFloorNum(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance.currentFloorNum = _loc2_;
      }
      
      public function recv_activeDungeonModifiers(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_activeDungeonModifiers= (function(param1:DcNetworkPacket):Vector<DungeonModifier>
         {
            var _loc5_:DungeonModifier = null;
            var _loc3_= new Vector<DungeonModifier>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = DungeonModifier.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.activeDungeonModifiers = v_activeDungeonModifiers;
      }
      
      public function recv_show_text(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.show_text(_loc2_);
      }
      
      public function recv_play_sound(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.play_sound(_loc2_);
      }
      
      public function recv_trigger_camera_zoom(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         the_instance.trigger_camera_zoom(_loc2_);
      }
      
      public function recv_trigger_camera_shake(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         var _loc3_= param1.readFloat();
         var _loc4_= param1.readUnsignedByte();
         the_instance.trigger_camera_shake(_loc2_,_loc3_,_loc4_);
      }
   }


