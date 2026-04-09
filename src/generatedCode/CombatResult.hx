package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class CombatResult
   {
      
      public var attacker:UInt = 0;
      
      public var attackee:UInt = 0;
      
      public var damage:Int = 0;
      
      public var attack:Attack;
      
      public var when:UInt = 0;
      
      public var suffer:UInt = 0;
      
      public var knockback:UInt = 0;
      
      public var blocked:UInt = 0;
      
      public var criticalHit:UInt = 0;
      
      public var effectiveness:Int = 0;
      
      public var selfDamage:Int = 0;
      
      public var scalingMaxPowerMultiplier:Float = Math.NaN;
      
      public var generation:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : CombatResult
      {
         var _loc2_= new CombatResult();
         _loc2_.attacker = param1.readUnsignedInt();
         _loc2_.attackee = param1.readUnsignedInt();
         _loc2_.damage = param1.readInt();
         _loc2_.attack = Attack.readFromPacket(param1);
         _loc2_.when = param1.readUnsignedByte();
         _loc2_.suffer = param1.readUnsignedByte();
         _loc2_.knockback = param1.readUnsignedByte();
         _loc2_.blocked = param1.readUnsignedByte();
         _loc2_.criticalHit = param1.readUnsignedByte();
         _loc2_.effectiveness = param1.readByte();
         _loc2_.selfDamage = param1.readInt();
         _loc2_.scalingMaxPowerMultiplier = param1.readFloat();
         _loc2_.generation = param1.readUnsignedByte();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUnsignedInt(attacker);
         param1.writeUnsignedInt(attackee);
         param1.writeInt(damage);
         attack.writeToPacket(param1);
         param1.writeByte((when : Int));
         param1.writeByte((suffer : Int));
         param1.writeByte((knockback : Int));
         param1.writeByte((blocked : Int));
         param1.writeByte((criticalHit : Int));
         param1.writeByte(effectiveness);
         param1.writeInt(selfDamage);
         param1.writeFloat(scalingMaxPowerMultiplier);
         param1.writeByte((generation : Int));
      }
   }


