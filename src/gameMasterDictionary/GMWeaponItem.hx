package gameMasterDictionary
;
   import brain.logger.Logger;
   
    class GMWeaponItem extends GMInventoryBase
   {
      
      public static final MELEE_WEAPON_SORT:Vector<String> = Vector.ofArray(["AXE_TYPE","HAMMER_TYPE","SWORD_TYPE","MEATCLEAVER_TYPE","COOKING_TYPE","FRYING_PAN_TYPE","KATANA_TYPE","SPEAR_TYPE","SHIELD_TYPE","FARMTOOL_TYPE","GREATSWORD_TYPE","FLAIL_TYPE","MACE_TYPE","LIGHT_SPEAR_TYPE","HEAVY_SPEAR_TYPE"]);
      
      public static final SHOOTING_WEAPON_SORT:Vector<String> = Vector.ofArray(["BOW_TYPE","CROSSBOW_TYPE","PISTOL_TYPE","THROWING_TYPE","HEAVY_THROWING_TYPE","LIGHT_THROWING_TYPE","TRAP_TYPE","SEED_TYPE","THROWING_SPEAR_TYPE"]);
      
      public static final MAGIC_WEAPON_SORT:Vector<String> = Vector.ofArray(["LIGHTNING_STAFF_TYPE","FIRE_STAFF_TYPE","STAFF_TYPE","LIGHTNING_MAGIC_TYPE","FIRE_MAGIC_TYPE","DARK_MAGIC_TYPE","SCROLL_TYPE","FIRE_RUNE_TYPE","FLAME_STAFF_TYPE","FIRE_GLOVE_TYPE","FIRE_ORB_TYPE","DRAGON_CHARM_TYPE"]);
      
      public static final ALL_WEAPON_SORT:Vector<String> = MELEE_WEAPON_SORT.concat(SHOOTING_WEAPON_SORT).concat(MAGIC_WEAPON_SORT);
      
      public var Release:String;
      
      public var ClassType:String;
      
      public var MasterType:String;
      
      public var DoNotDrop:Bool = false;
      
      public var Power:UInt = 0;
      
      public var Speed:Float = Math.NaN;
      
      public var ScalingFactor:Float = Math.NaN;
      
      public var WeaponController:String;
      
      public var ControllerTimeTillEnd:Float = Math.NaN;
      
      public var HoldingAttack:String;
      
      public var ChargeAttack:String;
      
      public var ScalingMaxPowerMultiplier:Float = Math.NaN;
      
      public var ScaleTapAttack:Bool = false;
      
      public var ScalingMinProjectiles:UInt = 0;
      
      public var ScalingMaxProjectiles:UInt = 0;
      
      public var ScalingProjectileStartAngle:Float = Math.NaN;
      
      public var ScalingProjectileEndAngle:Float = Math.NaN;
      
      public var ScalingDistanceTime:Float = Math.NaN;
      
      public var ScalingHeroMinDistance:Float = Math.NaN;
      
      public var ScalingHeroMaxDistance:Float = Math.NaN;
      
      public var ScalingProjectileMinDistance:Float = Math.NaN;
      
      public var ScalingProjectileMaxDistance:Float = Math.NaN;
      
      public var RepeaterOnlyChargeRepeated:Bool = false;
      
      public var RepeaterIncrementSpeedPercent:Float = Math.NaN;
      
      public var RepeaterMaxSpeedPercent:Float = Math.NaN;
      
      public var AbilityArray:Array<ASAny>;
      
      public var AttackArray:Array<ASAny>;
      
      public var PotentialModifiers:Vector<GMModifier>;
      
      public var PotentialLegendaryModifiers:Vector<GMLegendaryModifier>;
      
      public var WeaponAestheticList:Vector<GMWeaponAesthetic>;
      
      public var TapIcon:String;
      
      public var TapTitle:String;
      
      public var TapDescription:String;
      
      public var HoldIcon:String;
      
      public var HoldTitle:String;
      
      public var HoldDescription:String;
      
      public var ChooseRandomAttack:Bool = false;
      
      public function new(param1:ASObject)
      {
         super(param1);
         Release = param1.Release;
         ClassType = param1.ClassType;
         MasterType = param1.Mastertype;
         DoNotDrop = ASCompat.toBool(param1.DoNotDrop);
         Power = (ASCompat.toInt(param1.Power) : UInt);
         Speed = ASCompat.toNumberField(param1, "Speed");
         ScalingFactor = ASCompat.toNumberField(param1, "ScalingFactor");
         WeaponController = param1.WeaponController;
         ControllerTimeTillEnd = ASCompat.toNumberField(param1, "ControllerTimeTillEnd");
         HoldingAttack = param1.HoldingAttack;
         ChargeAttack = param1.ChargeAttack != null ? param1.ChargeAttack : "";
         ScalingMaxPowerMultiplier = ASCompat.toNumber(param1.ScalingMaxPowerMultiplier != null ? ASCompat.toNumberField(param1, "ScalingMaxPowerMultiplier") : 1);
         ScaleTapAttack = ASCompat.toBool(param1.ScaleTapAttack);
         ScalingMinProjectiles = (ASCompat.toInt(param1.ScalingMinProjectileMultiplier != null ? (ASCompat.toInt(param1.ScalingMinProjectileMultiplier) : UInt) : (1 : UInt)) : UInt);
         ScalingMaxProjectiles = (ASCompat.toInt(param1.ScalingMaxProjectileMultiplier != null ? (ASCompat.toInt(param1.ScalingMaxProjectileMultiplier) : UInt) : (1 : UInt)) : UInt);
         ScalingProjectileStartAngle = ASCompat.toNumber(param1.ScalingProjectileStartAngle != null ? ASCompat.toNumberField(param1, "ScalingProjectileStartAngle") : 0);
         ScalingProjectileEndAngle = ASCompat.toNumber(param1.ScalingProjectileEndAngle != null ? ASCompat.toNumberField(param1, "ScalingProjectileEndAngle") : 0);
         ScalingDistanceTime = ASCompat.toNumber(param1.ScalingDistanceTime != null ? ASCompat.toNumberField(param1, "ScalingDistanceTime") : 0);
         ScalingHeroMinDistance = ASCompat.toNumber(param1.ScalingHeroMinDistance != null ? ASCompat.toNumberField(param1, "ScalingHeroMinDistance") : 0);
         ScalingHeroMaxDistance = ASCompat.toNumber(param1.ScalingHeroMaxDistance != null ? ASCompat.toNumberField(param1, "ScalingHeroMaxDistance") : 0);
         ScalingProjectileMinDistance = ASCompat.toNumber(param1.ScalingProjectileMinDistance != null ? ASCompat.toNumberField(param1, "ScalingProjectileMinDistance") : 0);
         ScalingProjectileMaxDistance = ASCompat.toNumber(param1.ScalingProjectileMaxDistance != null ? ASCompat.toNumberField(param1, "ScalingProjectileMaxDistance") : 0);
         RepeaterOnlyChargeRepeated = ASCompat.toBool(param1.RepeaterOnlyChargeRepeated);
         RepeaterIncrementSpeedPercent = ASCompat.toNumber(param1.RepeaterIncrementSpeedPercent != null ? ASCompat.toNumberField(param1, "RepeaterIncrementSpeedPercent") : 0.5);
         RepeaterMaxSpeedPercent = ASCompat.toNumber(param1.RepeaterMaxSpeedPercent != null ? ASCompat.toNumberField(param1, "RepeaterMaxSpeedPercent") : 3);
         TapIcon = param1.TapIcon;
         TapTitle = ASCompat.toBool(param1.TapTitle) ? param1.TapTitle : "";
         TapDescription = ASCompat.toBool(param1.TapDescription) ? param1.TapDescription : "";
         HoldIcon = param1.HoldIcon;
         HoldTitle = ASCompat.toBool(param1.HoldTitle) ? param1.HoldTitle : "";
         HoldDescription = ASCompat.toBool(param1.HoldDescription) ? param1.HoldDescription : "";
         AbilityArray = [param1.Ability1,param1.Ability2,param1.Ability3,param1.Ability4,param1.Ability5];
         AttackArray = [param1.Attack1,param1.Attack2,param1.Attack3,param1.Attack4,param1.Attack5,param1.Attack6,param1.Attack7,param1.Attack8,param1.Attack9,param1.Attack10];
         ChooseRandomAttack = ASCompat.toBool(param1.ChooseRandomAttack);
         WeaponAestheticList = new Vector<GMWeaponAesthetic>();
         ItemCategory = "WEAPON";
         PotentialModifiers = new Vector<GMModifier>();
         PotentialLegendaryModifiers = new Vector<GMLegendaryModifier>();
      }
      
      public function getWeaponAesthetic(param1:UInt, param2:Bool = false) : GMWeaponAesthetic
      {
         var _loc3_= 0;
         if(WeaponAestheticList == null)
         {
            Logger.error("No weapon aesthetic list on weapon: " + this.Constant + ", id: " + this.Id);
            return null;
         }
         _loc3_ = 0;
         while(_loc3_ < WeaponAestheticList.length)
         {
            if(param2)
            {
               if(WeaponAestheticList[_loc3_].IsLegendary)
               {
                  return WeaponAestheticList[_loc3_];
               }
            }
            else if(param1 >= WeaponAestheticList[_loc3_].MinLevel && param1 <= WeaponAestheticList[_loc3_].MaxLevel)
            {
               return WeaponAestheticList[_loc3_];
            }
            _loc3_++;
         }
         if(param2)
         {
            return WeaponAestheticList[0];
         }
         Logger.error("Unable to find Weapon Aesthetic for weapon : " + this.Constant);
         return WeaponAestheticList[0];
      }
   }


