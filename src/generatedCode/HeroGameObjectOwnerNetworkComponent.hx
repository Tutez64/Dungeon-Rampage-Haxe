package generatedCode
;
   import distributedObjects.HeroGameObjectOwner;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
    class HeroGameObjectOwnerNetworkComponent extends HeroGameObjectNetworkComponent implements DcNetworkInterface
   {
      
      var the_instance:IHeroGameObjectOwner;
      
      public function new(param1:HeroGameObjectOwner, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance = param1;
      }
      
      public static function ownerFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : HeroGameObjectOwnerNetworkComponent
      {
         var _loc5_= new HeroGameObjectOwner(param2.facade,param3);
         var _loc4_= new HeroGameObjectOwnerNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentHeroGameObject(_loc4_);
         _loc5_.setOwnerNetworkComponentHeroGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2 - 168)
         {
            case 0:
               recv_ReportBuffEffect(param1);
               
            case 1:
               recv_ReceivedBuffEffect(param1);
               
            case 2:
               recv_TooFullForDoober(param1);
               
            case 7:
               recv_ProposeSelfRevive_Resp(param1);
               
            default:
               super.recvById(param1,param2);
         }
      }
      
      override public function generate(param1:DcNetworkPacket) 
      {
         recv_type(param1);
         recv_position(param1);
         recv_heading(param1);
         recv_scale(param1);
         recv_flip(param1);
         recv_hitPoints(param1);
         recv_weaponDetails(param1);
         recv_consumableDetails(param1);
         recv_healthBombsUsed(param1);
         recv_partyBombsUsed(param1);
         recv_playerID(param1);
         recv_state(param1);
         recv_team(param1);
         recv_skinType(param1);
         recv_screenName(param1);
         recv_manaPoints(param1);
         recv_experiencePoints(param1);
         recv_slotPoints(param1);
         recv_dungeonBusterPoints(param1);
         recv_setAFK(param1);
         recvByIdLoop(param1);
      }
      
      public function send_position(param1:Vector3D) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(147 : UInt));
         _loc2_.writeFloat(param1.x);
         _loc2_.writeFloat(param1.y);
         Send_packet(_loc2_);
      }
      
      public function send_heading(param1:Float) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(148 : UInt));
         _loc2_.writeFloat(param1);
         Send_packet(_loc2_);
      }
      
      public function send_ReceiveAttackChoreography(param1:AttackChoreography) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(159 : UInt));
         param1.writeToPacket(_loc2_);
         Send_packet(_loc2_);
      }
      
      public function recv_ReportBuffEffect(param1:DcNetworkPacket) 
      {
         var _loc5_= param1.readUnsignedInt();
         var _loc3_= param1.readInt();
         var _loc4_= param1.readUnsignedInt();
         var _loc2_= param1.readByte();
         the_instance.ReportBuffEffect(_loc5_,_loc3_,_loc4_,_loc2_);
      }
      
      public function recv_ReceivedBuffEffect(param1:DcNetworkPacket) 
      {
         var _loc3_= param1.readInt();
         var _loc4_= param1.readUnsignedInt();
         var _loc2_= param1.readByte();
         the_instance.ReceivedBuffEffect(_loc3_,_loc4_,_loc2_);
      }
      
      public function recv_TooFullForDoober(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance.TooFullForDoober(_loc2_);
      }
      
      public function send_ProposeCombatResults(param1:Vector<CombatResult>) 
      {
         var combatResultsfunc:ASFunction;
         var combatResults= param1;
         var outpacket= new DcNetworkPacket();
         Prepare_FieldUpdate(outpacket,(171 : UInt));
         combatResultsfunc = function()
         {
            var _loc2_= 0;
            var _loc1_= (combatResults.length : UInt);
            var _loc3_= outpacket;
            outpacket = new DcNetworkPacket();
            _loc2_ = 0;
            while((_loc2_ : UInt) < _loc1_)
            {
               combatResults[_loc2_].writeToPacket(outpacket);
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
            _loc3_.writeShort((outpacket.length : Int));
            _loc3_.writeBytes(outpacket);
            outpacket = _loc3_;
         };
         combatResultsfunc();
         Send_packet(outpacket);
      }
      
      public function send_ProposeAttackChoreography(param1:AttackChoreography) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(172 : UInt));
         param1.writeToPacket(_loc2_);
         Send_packet(_loc2_);
      }
      
      public function send_ProposeRevive(param1:UInt) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(173 : UInt));
         _loc2_.writeUnsignedInt(param1);
         Send_packet(_loc2_);
      }
      
      public function send_ProposeSelfRevive(param1:UInt) 
      {
         var _loc2_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc2_,(174 : UInt));
         _loc2_.writeByte((param1 : Int));
         Send_packet(_loc2_);
      }
      
      public function recv_ProposeSelfRevive_Resp(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         var _loc3_= param1.readUnsignedByte();
         the_instance.ProposeSelfRevive_Resp(_loc2_,_loc3_);
      }
      
      public function send_ProposeCreateNPC(param1:UInt, param2:UInt, param3:Float, param4:Float) 
      {
         var _loc5_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc5_,(177 : UInt));
         _loc5_.writeUnsignedInt(param1);
         _loc5_.writeUnsignedInt(param2);
         _loc5_.writeFloat(param3);
         _loc5_.writeFloat(param4);
         Send_packet(_loc5_);
      }
      
      public function send_StopChoreography() 
      {
         var _loc1_= new DcNetworkPacket();
         Prepare_FieldUpdate(_loc1_,(179 : UInt));
         Send_packet(_loc1_);
      }
   }


