package gameMasterDictionary
;
   import brain.logger.Logger;
   import dBGlobals.DBGlobal;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class GMHero extends GMActor
   {
      
      public var IsExclusive:Bool = false;
      
      public var Hidden:Bool = false;
      
      public var AmtStat1:Float = Math.NaN;
      
      public var StatUpgrade1:String;
      
      public var AmtStat2:Float = Math.NaN;
      
      public var StatUpgrade2:String;
      
      public var AmtStat3:Float = Math.NaN;
      
      public var StatUpgrade3:String;
      
      public var AmtStat4:Float = Math.NaN;
      
      public var StatUpgrade4:String;
      
      public var Power1R1:Float = Math.NaN;
      
      public var Power1R2:Float = Math.NaN;
      
      public var Power1R3:Float = Math.NaN;
      
      public var Power1R4:Float = Math.NaN;
      
      public var Power1R5:Float = Math.NaN;
      
      public var Power1:String;
      
      public var Power2R1:Float = Math.NaN;
      
      public var Power2R2:Float = Math.NaN;
      
      public var Power2R3:Float = Math.NaN;
      
      public var Power2R4:Float = Math.NaN;
      
      public var Power2R5:Float = Math.NaN;
      
      public var Power2:String;
      
      public var Power3R1:Float = Math.NaN;
      
      public var Power3R2:Float = Math.NaN;
      
      public var Power3R3:Float = Math.NaN;
      
      public var Power3R4:Float = Math.NaN;
      
      public var Power3R5:Float = Math.NaN;
      
      public var Power3:String;
      
      public var Power4R1:Float = Math.NaN;
      
      public var Power4R2:Float = Math.NaN;
      
      public var Power4R3:Float = Math.NaN;
      
      public var Power4R4:Float = Math.NaN;
      
      public var Power4R5:Float = Math.NaN;
      
      public var Power4:String;
      
      public var DBuster1:String;
      
      public var TeamAttack:String;
      
      public var Pet:String;
      
      public var AllowedWeapons:Map;
      
      public var UISwfFilepath:String;
      
      public var FeedPostPicture:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var CharUnlockLocation:String;
      
      public var CharDescription:String;
      
      public var StoreDescription:String;
      
      public var Coins:UInt = 0;
      
      public var Cash:UInt = 0;
      
      public var SpeedRating:Float = Math.NaN;
      
      public var AttackRating:Float = Math.NaN;
      
      public var DefenseRating:Float = Math.NaN;
      
      public var DefaultSkin:String;
      
      var ExperienceToLevel:Vector<ExpToLevel>;
      
      public var UpgradeToSlotOffset:Vector<Vector<Int>>;
      
      public var Normalized_upgrades:StatVector;
      
      public function new(param1:ASObject, param2:ASObject)
      {
         var _loc3_= false;
         UpgradeToSlotOffset = new Vector<Vector<Int>>((4 : UInt),true);
         super(param1);
         Normalized_upgrades = new StatVector();
         UpgradeToSlotOffset = new Vector<Vector<Int>>();
         UpgradeToSlotOffset.push(new Vector<Int>());
         UpgradeToSlotOffset.push(new Vector<Int>());
         UpgradeToSlotOffset.push(new Vector<Int>());
         UpgradeToSlotOffset.push(new Vector<Int>());
         ExperienceToLevel = new Vector<ExpToLevel>();
         IsExclusive = ASCompat.toBool(param1.IsExclusive);
         Hidden = ASCompat.toBool(param1.Hidden);
         AmtStat1 = ASCompat.toNumberField(param1, "AmtStat1");
         StatUpgrade1 = param1.StatUpgrade1;
         AmtStat2 = ASCompat.toNumberField(param1, "AmtStat2");
         StatUpgrade2 = param1.StatUpgrade2;
         AmtStat3 = ASCompat.toNumberField(param1, "AmtStat3");
         StatUpgrade3 = param1.StatUpgrade3;
         AmtStat4 = ASCompat.toNumberField(param1, "AmtStat4");
         StatUpgrade4 = param1.StatUpgrade4;
         Power1R1 = ASCompat.toNumberField(param1, "Power1R1");
         Power1R2 = ASCompat.toNumberField(param1, "Power1R2");
         Power1R3 = ASCompat.toNumberField(param1, "Power1R3");
         Power1R4 = ASCompat.toNumberField(param1, "Power1R4");
         Power1R5 = ASCompat.toNumberField(param1, "Power1R5");
         Power1 = param1.Power1;
         Power2R1 = ASCompat.toNumberField(param1, "Power2R1");
         Power2R2 = ASCompat.toNumberField(param1, "Power2R2");
         Power2R3 = ASCompat.toNumberField(param1, "Power2R3");
         Power2R4 = ASCompat.toNumberField(param1, "Power2R4");
         Power2R5 = ASCompat.toNumberField(param1, "Power2R5");
         Power2 = param1.Power2;
         Power3R1 = ASCompat.toNumberField(param1, "Power3R1");
         Power3R2 = ASCompat.toNumberField(param1, "Power3R2");
         Power3R3 = ASCompat.toNumberField(param1, "Power3R3");
         Power3R4 = ASCompat.toNumberField(param1, "Power3R4");
         Power3R5 = ASCompat.toNumberField(param1, "Power3R5");
         Power3 = param1.Power3;
         Power4R1 = ASCompat.toNumberField(param1, "Power4R1");
         Power4R2 = ASCompat.toNumberField(param1, "Power4R2");
         Power4R3 = ASCompat.toNumberField(param1, "Power4R3");
         Power4R4 = ASCompat.toNumberField(param1, "Power4R4");
         Power4R5 = ASCompat.toNumberField(param1, "Power4R5");
         Power4 = param1.Power4;
         DBuster1 = param1.DBuster1;
         TeamAttack = param1.TeamAttack;
         Pet = param1.Pet;
         DefaultSkin = param1.DefaultSkin;
         CharNickname = param1.CharNickname;
         CharLikes = param1.CharLikes;
         CharDislikes = param1.CharDislikes;
         CharUnlockLocation = param1.CharUnlockLocation;
         CharDescription = param1.Description;
         StoreDescription = param1.StoreDescription;
         Coins = (ASCompat.toInt(param1.Coins) : UInt);
         Cash = (ASCompat.toInt(param1.Cash) : UInt);
         AttackRating = ASCompat.toNumberField(param1, "AttackRating");
         DefenseRating = ASCompat.toNumberField(param1, "DefenseRating");
         SpeedRating = ASCompat.toNumberField(param1, "SpeedRating");
         Ability = (0 : UInt);
         if(param1.Ability1 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability1) : UInt) : UInt);
         }
         if(param1.Ability2 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability2) : UInt) : UInt);
         }
         if(param1.Ability3 != null)
         {
            Ability = ((Ability | DBGlobal.mapAbilityMask(param1.Ability3) : UInt) : UInt);
         }
         AllowedWeapons = new Map();
         if(param1.SWORD_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.SWORD_TYPE);
            AllowedWeapons.add("SWORD_TYPE",_loc3_);
         }
         if(param1.AXE_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.AXE_TYPE);
            AllowedWeapons.add("AXE_TYPE",_loc3_);
         }
         if(param1.HAMMER_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.HAMMER_TYPE);
            AllowedWeapons.add("HAMMER_TYPE",_loc3_);
         }
         if(param1.FLAIL_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FLAIL_TYPE);
            AllowedWeapons.add("FLAIL_TYPE",_loc3_);
         }
         if(param1.KATANA_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.KATANA_TYPE);
            AllowedWeapons.add("KATANA_TYPE",_loc3_);
         }
         if(param1.GREATSWORD_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.GREATSWORD_TYPE);
            AllowedWeapons.add("GREATSWORD_TYPE",_loc3_);
         }
         if(param1.SPEAR_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.SPEAR_TYPE);
            AllowedWeapons.add("SPEAR_TYPE",_loc3_);
         }
         if(param1.SHIELD_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.SHIELD_TYPE);
            AllowedWeapons.add("SHIELD_TYPE",_loc3_);
         }
         if(param1.FARMTOOL_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FARMTOOL_TYPE);
            AllowedWeapons.add("FARMTOOL_TYPE",_loc3_);
         }
         if(param1.MEATCLEAVER_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.MEATCLEAVER_TYPE);
            AllowedWeapons.add("MEATCLEAVER_TYPE",_loc3_);
         }
         if(param1.FRYING_PAN_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FRYING_PAN_TYPE);
            AllowedWeapons.add("FRYING_PAN_TYPE",_loc3_);
         }
         if(param1.COOKING_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.COOKING_TYPE);
            AllowedWeapons.add("COOKING_TYPE",_loc3_);
         }
         if(param1.BOW_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.BOW_TYPE);
            AllowedWeapons.add("BOW_TYPE",_loc3_);
         }
         if(param1.CROSSBOW_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.CROSSBOW_TYPE);
            AllowedWeapons.add("CROSSBOW_TYPE",_loc3_);
         }
         if(param1.PISTOL_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.PISTOL_TYPE);
            AllowedWeapons.add("PISTOL_TYPE",_loc3_);
         }
         if(param1.TRAP_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.TRAP_TYPE);
            AllowedWeapons.add("TRAP_TYPE",_loc3_);
         }
         if(param1.SEED_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.SEED_TYPE);
            AllowedWeapons.add("SEED_TYPE",_loc3_);
         }
         if(param1.LIGHTNING_STAFF_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.LIGHTNING_STAFF_TYPE);
            AllowedWeapons.add("LIGHTNING_STAFF_TYPE",_loc3_);
         }
         if(param1.FIRE_STAFF_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FIRE_STAFF_TYPE);
            AllowedWeapons.add("FIRE_STAFF_TYPE",_loc3_);
         }
         if(param1.FIRE_MAGIC_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FIRE_MAGIC_TYPE);
            AllowedWeapons.add("FIRE_MAGIC_TYPE",_loc3_);
         }
         if(param1.LIGHTNING_MAGIC_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.LIGHTNING_MAGIC_TYPE);
            AllowedWeapons.add("LIGHTNING_MAGIC_TYPE",_loc3_);
         }
         if(param1.THROWING_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.THROWING_TYPE);
            AllowedWeapons.add("THROWING_TYPE",_loc3_);
         }
         if(param1.SCROLL_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.SCROLL_TYPE);
            AllowedWeapons.add("SCROLL_TYPE",_loc3_);
         }
         if(param1.FLAME_STAFF_TYPE != null)
         {
            _loc3_ = ASCompat.toBool(param1.FLAME_STAFF_TYPE);
            AllowedWeapons.add("FLAME_STAFF_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.LIGHT_THROWING_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.LIGHT_THROWING_TYPE);
            AllowedWeapons.add("LIGHT_THROWING_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.HEAVY_THROWING_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.HEAVY_THROWING_TYPE);
            AllowedWeapons.add("HEAVY_THROWING_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.THROWING_WEAPON_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.THROWING_WEAPON_TYPE);
            AllowedWeapons.add("THROWING_WEAPON_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.VINTAGE_SCROLL_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.VINTAGE_SCROLL_TYPE);
            AllowedWeapons.add("VINTAGE_SCROLL_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.FIRE_ORB_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.FIRE_ORB_TYPE);
            AllowedWeapons.add("FIRE_ORB_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.FIRE_RUNE_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.FIRE_RUNE_TYPE);
            AllowedWeapons.add("FIRE_RUNE_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.FIRE_GLOVE_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.FIRE_GLOVE_TYPE);
            AllowedWeapons.add("FIRE_GLOVE_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.LIGHT_SPEAR_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.LIGHT_SPEAR_TYPE);
            AllowedWeapons.add("LIGHT_SPEAR_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.HEAVY_SPEAR_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.HEAVY_SPEAR_TYPE);
            AllowedWeapons.add("HEAVY_SPEAR_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.THROWING_SPEAR_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.THROWING_SPEAR_TYPE);
            AllowedWeapons.add("THROWING_SPEAR_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.DRAGON_CHARM_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.DRAGON_CHARM_TYPE);
            AllowedWeapons.add("DRAGON_CHARM_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.DRAGON_BOOTS_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.DRAGON_BOOTS_TYPE);
            AllowedWeapons.add("DRAGON_BOOTS_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.GUN_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.GUN_TYPE);
            AllowedWeapons.add("GUN_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.HEAVY_WEAPONS_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.HEAVY_WEAPONS_TYPE);
            AllowedWeapons.add("HEAVY_WEAPONS_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.TURRET_GADGET_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.TURRET_GADGET_TYPE);
            AllowedWeapons.add("TURRET_GADGET_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.LUCHADOR_GLOVE_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.LUCHADOR_GLOVE_TYPE);
            AllowedWeapons.add("LUCHADOR_GLOVE_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.LUCHADOR_BOOT_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.LUCHADOR_BOOT_TYPE);
            AllowedWeapons.add("LUCHADOR_BOOT_TYPE",_loc3_);
         }
         if(ASCompat.toBool(param1.LUCHADOR_CHAIR_TYPE))
         {
            _loc3_ = ASCompat.toBool(param1.LUCHADOR_CHAIR_TYPE);
            AllowedWeapons.add("LUCHADOR_CHAIR_TYPE",_loc3_);
         }
         UISwfFilepath = param1.UISwfFilepath;
         FeedPostPicture = param1.FeedPostPicture;
         IsMover = true;
      }
      
      public function getAllowedWeaponSubTypes() : Vector<String>
      {
         var _loc3_:String = null;
         var _loc2_= new Vector<String>();
         var _loc1_= ASCompat.reinterpretAs(AllowedWeapons.iterator() , IMapIterator);
         while(ASCompat.toBool(_loc1_.next()))
         {
            _loc3_ = ASCompat.asString(_loc1_.key );
            if(ASCompat.asBool(AllowedWeapons.itemFor(_loc3_) ))
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function HeroSlotHelper(param1:String, param2:Int, param3:Float, param4:GameMaster) 
      {
         var _loc6_:GMSuperStat = null;
         var _loc7_= 0;
         if(param3 == 0)
         {
            return;
         }
         var _loc5_= DBGlobal.NameToSlotOffset(param1);
         if(_loc5_ >= 0)
         {
            UpgradeToSlotOffset[param2].push(_loc5_);
            Normalized_upgrades.values[_loc5_] += param3;
         }
         else
         {
            _loc6_ = ASCompat.dynamicAs(param4.superStatByConstant.itemFor(param1), gameMasterDictionary.GMSuperStat);
            if(_loc6_ != null)
            {
               _loc7_ = 0;
               while((_loc7_ : UInt) < StatVector.slotCount)
               {
                  if(_loc6_.BaseValues.values[_loc7_] != 0)
                  {
                     UpgradeToSlotOffset[param2].push(_loc7_);
                     Normalized_upgrades.values[_loc7_] += _loc6_.BaseValues.values[_loc7_];
                  }
                  _loc7_++;
               }
            }
            else
            {
               Logger.error("Can not find Definition for Stat: " + param1);
            }
         }
      }
      
      public function LoadingOnly_addExpRecord(param1:UInt, param2:UInt, param3:UInt) 
      {
         ExperienceToLevel.push(new ExpToLevel(param1,param2,param3));
      }
      
      public function getLevelIndex(param1:Float) : Int
      {
         var _loc3_= 0;
         var _loc5_= 0;
         var _loc4_= ExperienceToLevel.length;
         var _loc6_= 0;
         var _loc2_= _loc4_;
         var _loc7_:Float = _loc2_ - _loc6_;
         while(0 < _loc7_)
         {
            _loc3_ = Std.int(_loc7_ / 2);
            _loc5_ = ASCompat.toInt(_loc6_ + _loc3_);
            if(ExperienceToLevel[_loc5_].mExperience < param1)
            {
               _loc6_ = ++_loc5_;
               _loc7_ -= _loc3_ + 1;
            }
            else
            {
               _loc7_ = _loc3_;
            }
         }
         if(_loc6_ >= _loc4_)
         {
            return _loc4_ - 1;
         }
         return _loc6_;
      }
      
      public function getLevelFromExp(param1:UInt) : UInt
      {
         return ExperienceToLevel[getLevelIndex(param1)].mLevel;
      }
      
      public function getTotalStatFromExp(param1:UInt) : UInt
      {
         return ExperienceToLevel[getLevelIndex(param1)].mTotalStatPoints;
      }
      
      public function getLevelFromIndex(param1:UInt) : UInt
      {
         return ExperienceToLevel[(param1 : Int)].mLevel;
      }
      
      public function getExpFromIndex(param1:UInt) : UInt
      {
         return ExperienceToLevel[(param1 : Int)].mExperience + 1;
      }
      
      public function getTotalStatFromIndex(param1:UInt) : UInt
      {
         return ExperienceToLevel[(param1 : Int)].mTotalStatPoints;
      }
   }


private class ExpToLevel
{
   
   public var mLevel:UInt = 0;
   
   public var mExperience:UInt = 0;
   
   public var mTotalStatPoints:UInt = 0;
   
   public function new(param1:UInt, param2:UInt, param3:UInt)
   {
      
      mLevel = param1;
      mExperience = param2;
      mTotalStatPoints = param3;
   }
}
