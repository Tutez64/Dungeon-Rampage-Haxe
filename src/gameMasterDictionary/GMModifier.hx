package gameMasterDictionary
;
    class GMModifier extends GMItem
   {
      
      public var Type:String;
      
      public var Level:UInt = 0;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var MELEE_SPD:Float = Math.NaN;
      
      public var SHOOT_SPD:Float = Math.NaN;
      
      public var MAGIC_SPD:Float = Math.NaN;
      
      public var MP_COST:Float = Math.NaN;
      
      public var CHAIN:Float = Math.NaN;
      
      public var PIERCE:Float = Math.NaN;
      
      public var MODIFIER_LEVEL:Float = Math.NaN;
      
      public var MODIFIER_TYPE:String;
      
      public var COOLDOWN_REDUC:Float = Math.NaN;
      
      public var CHARGE_REDUC:Float = Math.NaN;
      
      public var INCREASE_COLLISION:Float = Math.NaN;
      
      public var MAX_PROJECTILES:UInt = 0;
      
      public var INCREASED_PROJECTILE_ANGLE_PERCENT:Float = Math.NaN;
      
      public function new(param1:ASObject)
      {
         super(param1);
         Type = param1.MODIFIER_TYPE;
         Level = (ASCompat.toInt(param1.MODIFIER_LEVEL) : UInt);
         IconName = param1.IconName;
         Description = param1.Description;
         MODIFIER_LEVEL = ASCompat.toNumberField(param1, "MODIFIER_LEVEL");
         MODIFIER_TYPE = param1.MODIFIER_TYPE;
         MELEE_SPD = 1;
         SHOOT_SPD = 1;
         MAGIC_SPD = 1;
         MP_COST = 1;
         CHAIN = 0;
         PIERCE = 0;
         COOLDOWN_REDUC = 1;
         CHARGE_REDUC = 1;
         INCREASE_COLLISION = 1;
         MAX_PROJECTILES = (0 : UInt);
         INCREASED_PROJECTILE_ANGLE_PERCENT = 0;
         if(param1.hasOwnProperty("MELEE_SPD"))
         {
            MELEE_SPD = ASCompat.toNumberField(param1, "MELEE_SPD");
         }
         if(param1.hasOwnProperty("SHOOT_SPD"))
         {
            SHOOT_SPD = ASCompat.toNumberField(param1, "SHOOT_SPD");
         }
         if(param1.hasOwnProperty("MAGIC_SPD"))
         {
            MAGIC_SPD = ASCompat.toNumberField(param1, "MAGIC_SPD");
         }
         if(param1.hasOwnProperty("MP_COST"))
         {
            MP_COST = ASCompat.toNumberField(param1, "MP_COST");
         }
         if(param1.hasOwnProperty("PIERCE"))
         {
            PIERCE = ASCompat.toNumberField(param1, "PIERCE");
         }
         if(param1.hasOwnProperty("CHAIN"))
         {
            CHAIN = ASCompat.toNumberField(param1, "CHAIN");
         }
         if(param1.hasOwnProperty("MAX_PROJECTILES"))
         {
            MAX_PROJECTILES = (ASCompat.toInt(param1.MAX_PROJECTILES) : UInt);
         }
         if(param1.hasOwnProperty("INCREASED_PROJECTILE_ANGLE_PERCENT"))
         {
            INCREASED_PROJECTILE_ANGLE_PERCENT = ASCompat.toNumberField(param1, "INCREASED_PROJECTILE_ANGLE_PERCENT");
         }
         if(param1.hasOwnProperty("COOLDOWN_REDUC"))
         {
            COOLDOWN_REDUC = ASCompat.toNumberField(param1, "COOLDOWN_REDUC");
         }
         if(param1.hasOwnProperty("CHARGE_UP_REDUC"))
         {
            CHARGE_REDUC = ASCompat.toNumberField(param1, "CHARGE_UP_REDUC");
         }
         if(param1.hasOwnProperty("ATTACK_COLLISION_SCALE"))
         {
            INCREASE_COLLISION = ASCompat.asNumber(param1.ATTACK_COLLISION_SCALE );
         }
      }
   }


