package generatedCode
;
   import distributedObjects.HeroGameObject;
   import networkCode.DcNetworkClass;
   import networkCode.DcNetworkInterface;
   import networkCode.DcNetworkPacket;
   import flash.geom.Vector3D;
   
    class HeroGameObjectNetworkComponent extends DcNetworkClass implements DcNetworkInterface
   {
      
      var the_instance__GeneratedCode_HeroGameObjectNetworkComponent/*redefined private*/:HeroGameObject;
      
      public static inline final FLID_type= (146 : UInt);
      
      public static inline final FLID_position= (147 : UInt);
      
      public static inline final FLID_heading= (148 : UInt);
      
      public static inline final FLID_scale= (149 : UInt);
      
      public static inline final FLID_flip= (150 : UInt);
      
      public static inline final FLID_hitPoints= (151 : UInt);
      
      public static inline final FLID_weaponDetails= (152 : UInt);
      
      public static inline final FLID_consumableDetails= (153 : UInt);
      
      public static inline final FLID_healthBombsUsed= (154 : UInt);
      
      public static inline final FLID_partyBombsUsed= (155 : UInt);
      
      public static inline final FLID_playerID= (156 : UInt);
      
      public static inline final FLID_state= (157 : UInt);
      
      public static inline final FLID_team= (158 : UInt);
      
      public static inline final FLID_ReceiveAttackChoreography= (159 : UInt);
      
      public static inline final FLID_ReceiveCombatResult= (160 : UInt);
      
      public static inline final FLID_skinType= (161 : UInt);
      
      public static inline final FLID_screenName= (162 : UInt);
      
      public static inline final FLID_manaPoints= (163 : UInt);
      
      public static inline final FLID_experiencePoints= (164 : UInt);
      
      public static inline final FLID_slotPoints= (165 : UInt);
      
      public static inline final FLID_dungeonBusterPoints= (166 : UInt);
      
      public static inline final FLID_setAFK= (167 : UInt);
      
      public static inline final FLID_ReportBuffEffect= (168 : UInt);
      
      public static inline final FLID_ReceivedBuffEffect= (169 : UInt);
      
      public static inline final FLID_TooFullForDoober= (170 : UInt);
      
      public static inline final FLID_ProposeCombatResults= (171 : UInt);
      
      public static inline final FLID_ProposeAttackChoreography= (172 : UInt);
      
      public static inline final FLID_ProposeRevive= (173 : UInt);
      
      public static inline final FLID_ProposeSelfRevive= (174 : UInt);
      
      public static inline final FLID_ProposeSelfRevive_Resp= (175 : UInt);
      
      public static inline final FLID_PartyBomb= (176 : UInt);
      
      public static inline final FLID_ProposeCreateNPC= (177 : UInt);
      
      public static inline final FLID_setStateAndAttackChoreography= (178 : UInt);
      
      public static inline final FLID_StopChoreography= (179 : UInt);
      
      public function new(param1:HeroGameObject, param2:GeneratedDcSocket, param3:UInt)
      {
         super(param1,param2,param3);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent = param1;
      }
      
      public static function netFactory(param1:DcNetworkPacket, param2:GeneratedDcSocket, param3:UInt) : HeroGameObjectNetworkComponent
      {
         var _loc5_= new HeroGameObject(param2.facade,param3);
         var _loc4_= new HeroGameObjectNetworkComponent(_loc5_,param2,param3);
         _loc4_.generate(param1);
         _loc5_.setNetworkComponentHeroGameObject(_loc4_);
         _loc5_.postGenerate();
         return _loc4_;
      }
      
      override public function recvById(param1:DcNetworkPacket, param2:UInt) 
      {
         switch(param2)
         {
            case 146:
               recv_type(param1);
               
            case 147:
               recv_position(param1);
               
            case 148:
               recv_heading(param1);
               
            case 149:
               recv_scale(param1);
               
            case 150:
               recv_flip(param1);
               
            case 151:
               recv_hitPoints(param1);
               
            case 152:
               recv_weaponDetails(param1);
               
            case 153:
               recv_consumableDetails(param1);
               
            case 154:
               recv_healthBombsUsed(param1);
               
            case 155:
               recv_partyBombsUsed(param1);
               
            case 156:
               recv_playerID(param1);
               
            case 157:
               recv_state(param1);
               
            case 158:
               recv_team(param1);
               
            case 159:
               recv_ReceiveAttackChoreography(param1);
               
            case 160:
               recv_ReceiveCombatResult(param1);
               
            case 161:
               recv_skinType(param1);
               
            case 162:
               recv_screenName(param1);
               
            case 163:
               recv_manaPoints(param1);
               
            case 164:
               recv_experiencePoints(param1);
               
            case 165:
               recv_slotPoints(param1);
               
            case 166:
               recv_dungeonBusterPoints(param1);
               
            case 167:
               recv_setAFK(param1);
               
            case 176:
               recv_PartyBomb(param1);
               
            case 178:
               recv_setStateAndAttackChoreography(param1);
               
            case 179:
               recv_StopChoreography(param1);
               
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
      
      override public function destroy() 
      {
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.destroy();
      }
      
      public function recv_type(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.type = _loc2_;
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
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.position = v_position;
      }
      
      public function recv_heading(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.heading = _loc2_;
      }
      
      public function recv_scale(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readFloat();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.scale = _loc2_;
      }
      
      public function recv_flip(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.flip = _loc2_;
      }
      
      public function recv_hitPoints(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.hitPoints = _loc2_;
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
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.weaponDetails = v_weaponDetails;
      }
      
      public function recv_consumableDetails(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_consumableDetails= (function(param1:DcNetworkPacket):Vector<ConsumableDetails>
         {
            var _loc3_= 0;
            var _loc5_:ConsumableDetails = null;
            var _loc4_= new Vector<ConsumableDetails>();
            var _loc2_= (2 : UInt);
            _loc3_ = 0;
            while((_loc3_ : UInt) < _loc2_)
            {
               _loc5_ = ConsumableDetails.readFromPacket(param1);
               _loc4_.push(_loc5_);
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            return _loc4_;
         })(packet);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.consumableDetails = v_consumableDetails;
      }
      
      public function recv_healthBombsUsed(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.healthBombsUsed = _loc2_;
      }
      
      public function recv_partyBombsUsed(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.partyBombsUsed = _loc2_;
      }
      
      public function recv_playerID(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.playerID = _loc2_;
      }
      
      public function recv_state(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.state = _loc2_;
      }
      
      public function recv_team(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readByte();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.team = _loc2_;
      }
      
      public function recv_ReceiveAttackChoreography(param1:DcNetworkPacket) 
      {
         var _loc2_= AttackChoreography.readFromPacket(param1);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.ReceiveAttackChoreography(_loc2_);
      }
      
      public function recv_ReceiveCombatResult(param1:DcNetworkPacket) 
      {
         var _loc2_= CombatResult.readFromPacket(param1);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.ReceiveCombatResult(_loc2_);
      }
      
      public function recv_skinType(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.skinType = _loc2_;
      }
      
      public function recv_screenName(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.screenName = _loc2_;
      }
      
      public function recv_manaPoints(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedShort();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.manaPoints = _loc2_;
      }
      
      public function recv_experiencePoints(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.experiencePoints = _loc2_;
      }
      
      public function recv_slotPoints(param1:DcNetworkPacket) 
      {
         var packet= param1;
         var v_slotPoints= (function(param1:DcNetworkPacket):Vector<UInt>
         {
            var _loc3_= 0;
            var _loc5_= 0;
            var _loc4_= new Vector<UInt>();
            var _loc2_= (4 : UInt);
            _loc3_ = 0;
            while((_loc3_ : UInt) < _loc2_)
            {
               _loc5_ = (param1.readUnsignedShort() : Int);
               _loc4_.push((_loc5_ : UInt));
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            return _loc4_;
         })(packet);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.slotPoints = v_slotPoints;
      }
      
      public function recv_dungeonBusterPoints(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.dungeonBusterPoints = _loc2_;
      }
      
      public function recv_setAFK(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedByte();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.setAFK = _loc2_;
      }
      
      public function recv_PartyBomb(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUnsignedInt();
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.PartyBomb(_loc2_);
      }
      
      public function recv_setStateAndAttackChoreography(param1:DcNetworkPacket) 
      {
         var _loc2_= param1.readUTF();
         var _loc3_= AttackChoreography.readFromPacket(param1);
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.setStateAndAttackChoreography(_loc2_,_loc3_);
      }
      
      public function recv_StopChoreography(param1:DcNetworkPacket) 
      {
         the_instance__GeneratedCode_HeroGameObjectNetworkComponent.StopChoreography();
      }
   }


