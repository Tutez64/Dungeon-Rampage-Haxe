package generatedCode
;
   import distributedObjects.DistributedDungionArea;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedDungionAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedDungionArea;
      
      public static inline final FLID_tileLibrary= (211 : UInt);
      
      public static inline final FLID_cacheNpc= (212 : UInt);
      
      public static inline final FLID_cacheSWC= (213 : UInt);
      
      public static inline final FLID_floorReward= (214 : UInt);
      
      public static inline final FLID_floorEnding= (215 : UInt);
      
      public static inline final FLID_dungeonEnding= (216 : UInt);
      
      public static inline final FLID_floorfailing= (217 : UInt);
      
      public static inline final FLID_tellClientInfiniteRewardData= (218 : UInt);
      
      public function new(param1:DistributedDungionArea, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedDungionAreaNetworkComponent
      {
         var _loc5_= new DistributedDungionArea(param2.facade,param3);
         var _loc4_= new DistributedDungionAreaNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedDungionArea(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 211)
         {
            case 0:
               recv_tileLibrary(param1);
               
            case 1:
               recv_cacheNpc(param1);
               
            case 2:
               recv_cacheSWC(param1);
               
            case 3:
               recv_floorReward(param1);
               
            case 4:
               recv_floorEnding(param1);
               
            case 5:
               recv_dungeonEnding(param1);
               
            case 6:
               recv_floorfailing(param1);
               
            case 7:
               recv_tellClientInfiniteRewardData(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_tileLibrary(param1);
         recv_cacheNpc(param1);
         recv_cacheSWC(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_tileLibrary(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var tileLibrary= (function(param1:DcNetworkPacket):Vector<Swrapper>
         {
            var _loc5_:Swrapper = null;
            var _loc3_= new Vector<Swrapper>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = Swrapper.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tileLibrary(tileLibrary);
      }
      
      public function recv_cacheNpc(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_cacheNpc= (function(param1:DcNetworkPacket):Vector<UInt>
         {
            var _loc5_= 0;
            var _loc3_= new Vector<UInt>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = (param1.readUnsignedInt() : Int);
               _loc3_.push((_loc5_ : UInt));
            }
            return _loc3_;
         })(packet);
         the_instance.cacheNpc = v_cacheNpc;
      }
      
      public function recv_cacheSWC(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_cacheSWC= (function(param1:DcNetworkPacket):Vector<Swrapper>
         {
            var _loc5_:Swrapper = null;
            var _loc3_= new Vector<Swrapper>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = Swrapper.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.cacheSWC = v_cacheSWC;
      }
      
      public function recv_floorReward(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.floorReward(_loc2_);
      }
      
      public function recv_floorEnding(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance.floorEnding(_loc2_);
      }
      
      public function recv_dungeonEnding(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         var _loc3_= param1.readUnsignedByte();
         the_instance.dungeonEnding(_loc2_,_loc3_);
      }
      
      public function recv_floorfailing(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance.floorfailing(_loc2_);
      }
      
      public function recv_tellClientInfiniteRewardData(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var avId= packet.readUnsignedInt();
         var avScore= packet.readUnsignedShort();
         var goldReward= packet.readUnsignedInt();
         var infiniteRewards= (function(param1:DcNetworkPacket):Vector<InfiniteRewardData>
         {
            var _loc5_:InfiniteRewardData = null;
            var _loc3_= new Vector<InfiniteRewardData>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = InfiniteRewardData.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.tellClientInfiniteRewardData(avId,avScore,goldReward,infiniteRewards);
      }
   }


