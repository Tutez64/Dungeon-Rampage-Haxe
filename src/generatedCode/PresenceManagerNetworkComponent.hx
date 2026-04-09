package generatedCode
;
   import distributedObjects.PresenceManager;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class PresenceManagerNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:PresenceManager;
      
      public static inline final FLID_friendState= (188 : UInt);
      
      public static inline final FLID_addFriends= (189 : UInt);
      
      public function new(param1:PresenceManager, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : PresenceManagerNetworkComponent
      {
         var _loc5_= new PresenceManager(param2.facade,param3);
         var _loc4_= new PresenceManagerNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentPresenceManager(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 188)
         {
            case 0:
               recv_friendState(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_friendState(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         var _loc4_= param1.readUnsignedInt();
         var _loc3_= param1.readUnsignedInt();
         the_instance.friendState(_loc2_,_loc4_,_loc3_);
      }
      
      public function send_addFriends(param1:Vector<UInt>) 
      {
         var whofunc:ASFunction;
         var who= param1;
         var outpacket= new DcNetworkPacket();
         Prepare_FieldUpdate(outpacket,(189 : UInt));
         whofunc = function()
         {
            var _loc2_= 0;
            var _loc3_= (who.length : UInt);
            var _loc1_= outpacket;
            outpacket = new DcNetworkPacket();
            _loc2_ = 0;
            while((_loc2_ : UInt) < _loc3_)
            {
               outpacket.writeUnsignedInt(who[_loc2_]);
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
            _loc1_.writeShort((outpacket.length : Int));
            _loc1_.writeBytes(outpacket);
            outpacket = _loc1_;
         };
         whofunc();
         Send_packet(outpacket);
      }
   }


