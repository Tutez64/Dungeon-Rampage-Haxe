package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class AttackChoreography
   {
      
      public var attack:Attack;
      
      public var loop:UInt = 0;
      
      public var playSpeed:Float = Math.NaN;
      
      public var scalingMaxProjectiles:Float = Math.NaN;
      
      public var combatResults:Vector<CombatResult>;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : AttackChoreography
      {
         var packet= param1;
         var work= new AttackChoreography();
         work.attack = Attack.readFromPacket(packet);
         work.loop = packet.readUnsignedByte();
         work.playSpeed = packet.readFloat();
         work.scalingMaxProjectiles = packet.readFloat();
         work.combatResults = (function(param1:DcNetworkPacket):Vector<CombatResult>
         {
            var _loc5_:CombatResult = null;
            var _loc3_= new Vector<CombatResult>();
            var _loc2_= param1.readUnsignedShort();
            var _loc4_= _loc2_ + param1.position;
            while(param1.position < _loc4_)
            {
               _loc5_ = CombatResult.readFromPacket(param1);
               _loc3_.push(_loc5_);
            }
            return _loc3_;
         })(packet);
         return work;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         var combatResultsfunc:ASFunction;
         var outpacket= param1;
         attack.writeToPacket(outpacket);
         outpacket.writeByte((loop : Int));
         outpacket.writeFloat(playSpeed);
         outpacket.writeFloat(scalingMaxProjectiles);
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
      }
   }


