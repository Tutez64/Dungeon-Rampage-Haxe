package generatedCode
;
   import distributedObjects.DistributedNPCGameObject;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
    class DistributedNPCGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:DistributedNPCGameObject;
      
      public static inline final FLID_type= (130 : UInt);
      
      public static inline final FLID_level= (131 : UInt);
      
      public static inline final FLID_position= (132 : UInt);
      
      public static inline final FLID_heading= (133 : UInt);
      
      public static inline final FLID_scale= (134 : UInt);
      
      public static inline final FLID_flip= (135 : UInt);
      
      public static inline final FLID_hitPoints= (136 : UInt);
      
      public static inline final FLID_weaponDetails= (137 : UInt);
      
      public static inline final FLID_state= (138 : UInt);
      
      public static inline final FLID_team= (139 : UInt);
      
      public static inline final FLID_layer= (140 : UInt);
      
      public static inline final FLID_remoteTriggerState= (141 : UInt);
      
      public static inline final FLID_masterId= (142 : UInt);
      
      public static inline final FLID_ReceiveAttackChoreography= (143 : UInt);
      
      public static inline final FLID_ReceiveCombatResult= (144 : UInt);
      
      public static inline final FLID_ReceiveTimelineAction= (145 : UInt);
      
      public function new(param1:DistributedNPCGameObject, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : DistributedNPCGameObjectNetworkComponent
      {
         var _loc5_= new DistributedNPCGameObject(param2.facade,param3);
         var _loc4_= new DistributedNPCGameObjectNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentDistributedNPCGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 130)
         {
            case 0:
               recv_type(param1);
               
            case 1:
               recv_level(param1);
               
            case 2:
               recv_position(param1);
               
            case 3:
               recv_heading(param1);
               
            case 4:
               recv_scale(param1);
               
            case 5:
               recv_flip(param1);
               
            case 6:
               recv_hitPoints(param1);
               
            case 7:
               recv_weaponDetails(param1);
               
            case 8:
               recv_state(param1);
               
            case 9:
               recv_team(param1);
               
            case 10:
               recv_layer(param1);
               
            case 11:
               recv_remoteTriggerState(param1);
               
            case 12:
               recv_masterId(param1);
               
            case 13:
               recv_ReceiveAttackChoreography(param1);
               
            case 14:
               recv_ReceiveCombatResult(param1);
               
            case 15:
               recv_ReceiveTimelineAction(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_type(param1);
         recv_level(param1);
         recv_position(param1);
         recv_heading(param1);
         recv_scale(param1);
         recv_flip(param1);
         recv_hitPoints(param1);
         recv_weaponDetails(param1);
         recv_state(param1);
         recv_team(param1);
         recv_layer(param1);
         recv_remoteTriggerState(param1);
         recv_masterId(param1);
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
      
      public function recv_level(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.level = _loc2_;
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
      
      public function recv_heading(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         the_instance.heading = _loc2_;
      }
      
      public function recv_scale(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         the_instance.scale = _loc2_;
      }
      
      public function recv_flip(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.flip = _loc2_;
      }
      
      public function recv_hitPoints(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.hitPoints = _loc2_;
      }
      
      public function recv_weaponDetails(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_weaponDetails= (function(param1:DcNetworkPacket):Vector<WeaponDetails>
         {
            var _loc3_= 0;
            var _loc5_:WeaponDetails = null;
            var _loc4_= new Vector<WeaponDetails>();
            var _loc2_= (4 : UInt);
            _loc3_ = 0;
            while((_loc3_ : UInt) < _loc2_)
            {
               _loc5_ = WeaponDetails.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            return _loc4_;
         })(packet);
         the_instance.weaponDetails = v_weaponDetails;
      }
      
      public function recv_state(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.state = _loc2_;
      }
      
      public function recv_team(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readByte();
         the_instance.team = _loc2_;
      }
      
      public function recv_layer(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readByte();
         the_instance.layer = _loc2_;
      }
      
      public function recv_remoteTriggerState(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.remoteTriggerState = _loc2_;
      }
      
      public function recv_masterId(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance.masterId = _loc2_;
      }
      
      public function recv_ReceiveAttackChoreography(param1:DcNetworkPacket) 
      {
         var _loc2_= AttackChoreography.readFromPacket(param1);
         the_instance.ReceiveAttackChoreography(_loc2_);
      }
      
      public function recv_ReceiveCombatResult(param1:DcNetworkPacket) 
      {
         var _loc2_= CombatResult.readFromPacket(param1);
         the_instance.ReceiveCombatResult(_loc2_);
      }
      
      public function recv_ReceiveTimelineAction(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance.ReceiveTimelineAction(_loc2_);
      }
   }


