package generatedCode
;
   import actor.buffs.DistributedBuffGameObject;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class DistributedBuffGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedBuffGameObject;
      
      public static inline final FLID_type= (292 : UInt);
      
      public static inline final FLID_effectedActor= (293 : UInt);
      
      public static inline final FLID_attackerActor= (294 : UInt);
      
      public function new(param1:DistributedBuffGameObject, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedBuffGameObjectNetworkComponent
      {
         var _loc5_= new DistributedBuffGameObject(param2.facade,param3);
         var _loc4_= new DistributedBuffGameObjectNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedBuffGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 292)
         {
            case 0:
               recv_type(param1);
               
            case 1:
               recv_effectedActor(param1);
               
            case 2:
               recv_attackerActor(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_type(param1);
         recv_effectedActor(param1);
         recv_attackerActor(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_type(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.type = _loc2_;
      }
      
      public function recv_effectedActor(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.effectedActor = _loc2_;
      }
      
      public function recv_attackerActor(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.attackerActor = _loc2_;
      }
   }


