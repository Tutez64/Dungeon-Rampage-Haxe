package generatedCode
;
   import distributedObjects.MatchMaker;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   
    class MatchMakerNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance:MatchMaker;
      
      public static inline final FLID_InfiniteDetails= (294 : UInt);
      
      public static inline final FLID_ClientRequestEntry= (295 : UInt);
      
      public static inline final FLID_ClientRequestEntryResponce= (296 : UInt);
      
      public static inline final FLID_RequestExit= (297 : UInt);
      
      public static inline final FLID_ClientExitComplete= (298 : UInt);
      
      public static inline final FLID_ClientDataFlushExit= (299 : UInt);
      
      public static inline final FLID_ClientRequestPartyMemberInvite= (300 : UInt);
      
      public static inline final FLID_RequestPartyMemberInvite= (301 : UInt);
      
      public static inline final FLID_ClientRequestLeaveParty= (302 : UInt);
      
      public static inline final FLID_ClientInformPartyComposition= (303 : UInt);
      
      public static inline final FLID_Proxy_ClientRequestEntryResponce= (304 : UInt);
      
      public static inline final FLID_RequestEntry= (305 : UInt);
      
      public static inline final FLID_AreaManagerStatus= (306 : UInt);
      
      public static inline final FLID_AreaStatus= (307 : UInt);
      
      public static inline final FLID_MatchMaker_Newgame= (308 : UInt);
      
      public static inline final FLID_RequestExitProxy= (309 : UInt);
      
      public static inline final FLID_AreaExit= (310 : UInt);
      
      public static inline final FLID_ForceAreaExit= (311 : UInt);
      
      public static inline final FLID_PlayerExit= (312 : UInt);
      
      public static inline final FLID_ReportAreaOutcome= (313 : UInt);
      
      public static inline final FLID_TimingProbResp= (314 : UInt);
      
      public function new(param1:MatchMaker, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : MatchMakerNetworkComponent
      {
         var _loc5_= new MatchMaker(param2.facade,param3);
         var _loc4_= new MatchMakerNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentMatchMaker(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 294)
         {
            case 0:
               recv_InfiniteDetails(param1);
               
            case 2:
               recv_ClientRequestEntryResponce(param1);
               
            case 4:
               recv_ClientExitComplete(param1);
               
            case 9:
               recv_ClientInformPartyComposition(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_InfiniteDetails(param1);
         recvByIdLoop(param1);
      }
      
      override public function destroy() 
      {
         the_instance.destroy();
      }
      
      public function recv_InfiniteDetails(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var value_0= (function(param1:DcNetworkPacket):Vector<InfiniteMapNodeDetail>
         {
            var _loc5_:InfiniteMapNodeDetail = null;
            var _loc3_= new Vector<InfiniteMapNodeDetail>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = InfiniteMapNodeDetail.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         the_instance.InfiniteDetails(value_0);
      }
      
      public function send_ClientRequestEntry(param1:String, param2:UInt, param3:UInt, param4:UInt, param5:UInt, param6:UInt, param7:String) 
      {
         var _loc8_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc8_,(295 : UInt));
         _loc8_.writeUTF(param1);
         _loc8_.writeUnsignedInt(param2);
         _loc8_.writeUnsignedInt(param3);
         _loc8_.writeUnsignedInt(param4);
         _loc8_.writeUnsignedInt(param5);
         _loc8_.writeByte((param6 : Int));
         _loc8_.writeUTF(param7);
         Send_packet(_loc8_);
      }
      
      public function recv_ClientRequestEntryResponce(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         var _loc3_= param1.readUnsignedInt();
         the_instance.ClientRequestEntryResponce(_loc2_,_loc3_);
      }
      
      public function send_RequestExit(param1:UInt) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(297 : UInt));
         _loc2_.writeUnsignedInt(param1);
         Send_packet(_loc2_);
      }
      
      public function recv_ClientExitComplete(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance.ClientExitComplete(_loc2_);
      }
      
      public function send_ClientRequestPartyMemberInvite(param1:String, param2:UInt) 
      {
         var _loc3_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc3_,(300 : UInt));
         _loc3_.writeUTF(param1);
         _loc3_.writeUnsignedInt(param2);
         Send_packet(_loc3_);
      }
      
      public function recv_ClientInformPartyComposition(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var partyMembers= (function(param1:DcNetworkPacket):Vector<GameServerPartyMember>
         {
            var _loc3_= 0;
            var _loc5_:GameServerPartyMember = null;
            var _loc4_= new Vector<GameServerPartyMember>();
            var _loc2_= (4 : UInt);
            _loc3_ = 0;
            while((_loc3_ : UInt) < _loc2_)
            {
               _loc5_ = GameServerPartyMember.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            return _loc4_;
         })(packet);
         the_instance.ClientInformPartyComposition(partyMembers);
      }
   }


