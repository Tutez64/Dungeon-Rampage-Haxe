package generatedCode
;
   import distributedObjects.DistributedTownArea;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedTownAreaNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedTownArea;
      
      public static inline final FLID_tileLibrary= (286 : UInt);
      
      public function new(param1:DistributedTownArea, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedTownAreaNetworkComponent
      {
         var _loc5_= new DistributedTownArea(param2.facade,param3);
         var _loc4_= new DistributedTownAreaNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedTownArea(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 286)
         {
            case 0:
               recv_tileLibrary(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_tileLibrary(param1);
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
   }


