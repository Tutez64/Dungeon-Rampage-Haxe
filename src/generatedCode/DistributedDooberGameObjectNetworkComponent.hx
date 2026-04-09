package generatedCode
;
   import doobers.DistributedDooberGameObject;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
    class DistributedDooberGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedDooberGameObject;
      
      public static inline final FLID_type= (287 : UInt);
      
      public static inline final FLID_position= (288 : UInt);
      
      public static inline final FLID_layer= (289 : UInt);
      
      public static inline final FLID_spawnFrom= (290 : UInt);
      
      public static inline final FLID_collectedBy= (291 : UInt);
      
      public function new(param1:DistributedDooberGameObject, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedDooberGameObjectNetworkComponent
      {
         var _loc5_= new DistributedDooberGameObject(param2.facade,param3);
         var _loc4_= new DistributedDooberGameObjectNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedDooberGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 287)
         {
            case 0:
               recv_type(param1);
               
            case 1:
               recv_position(param1);
               
            case 2:
               recv_layer(param1);
               
            case 3:
               recv_spawnFrom(param1);
               
            case 4:
               recv_collectedBy(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_type(param1);
         recv_position(param1);
         recv_layer(param1);
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
      
      public function recv_position(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_position= (function(param1:DcNetworkPacket):Vector3D
         {
            var _loc2_= new Vector3D();
            _loc2_.x = param1.readFloat();
            _loc2_.y = param1.readFloat();
            return _loc2_;
         })(packet);
         the_instance.position = v_position;
      }
      
      public function recv_layer(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readByte();
         the_instance.layer = _loc2_;
      }
      
      public function recv_spawnFrom(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var loc= (function(param1:DcNetworkPacket):Vector3D
         {
            var _loc2_= new Vector3D();
            _loc2_.x = param1.readFloat();
            _loc2_.y = param1.readFloat();
            return _loc2_;
         })(packet);
         the_instance.spawnFrom(loc);
      }
      
      public function recv_collectedBy(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.collectedBy(_loc2_);
      }
   }


