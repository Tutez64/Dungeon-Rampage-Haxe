package dBGlobals
;
   import brain.logger.Logger;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   
    class DBGlobal
   {
      
      public static var TUTORIAL_MAP_NODE_ID:UInt = (50002 : UInt);
      
      public static var MUSIC_VOLUME:Float = 0.7;
      
      public static var SFX_VOLUME:Float = 0.7;
      
      public static inline final RESSURECTION_POTION_STACK_ID= (60001 : UInt);
      
      public static inline final RESSURECTION_POTION_OFFER_ID= (51304 : UInt);
      
      public static inline final PARTYBOMB_POTION_STACK_ID= (60018 : UInt);
      
      public static inline final PARTYBOMB_POTION_OFFER_ID= (51369 : UInt);
      
      public static inline final SFX_PATH= "Resources/Audio/soundEffects.swf";
      
      public static inline final DEFAULT_ICON_NATIVE_SIZE:Float = 100;
      
      public static inline final WEAPON_ICON_NATIVE_SIZE:Float = 100;
      
      public static inline final CHEST_ICON_NATIVE_SIZE:Float = 120;
      
      public static inline final CHARGE_ICON_NATIVE_SIZE:Float = 60;
      
      public static inline final HERO_ICON_NATIVE_SIZE:Float = 72;
      
      public static inline final PET_ICON_NATIVE_SIZE:Float = 68;
      
      public static inline final BERSERKER_TYPE_ID= (101 : UInt);
      
      public static inline final RANGER_TYPE_ID= (102 : UInt);
      
      public static inline final SORCERER_TYPE_ID= (103 : UInt);
      
      public static inline final BATTLE_CHEF_TYPE_ID= (104 : UInt);
      
      public static inline final VAMPIRE_HUNTER_TYPE_ID= (105 : UInt);
      
      public static inline final GHOST_SAMURAI_TYPE_ID= (106 : UInt);
      
      public static inline final MELEE_ITEM_CATEGORY= "MELEE";
      
      public static inline final SHOOTING_ITEM_CATEGORY= "SHOOTING";
      
      public static inline final MAGIC_ITEM_CATEGORY= "MAGIC";
      
      public static inline final HP_BOOST:Float = 0;
      
      public static inline final MP_BOOST:Float = 1;
      
      public static inline final MELEE_ATK:Float = 2;
      
      public static inline final SHOOT_ATK:Float = 3;
      
      public static inline final MAGIC_ATK:Float = 4;
      
      public static inline final MELEE_DEF:Float = 5;
      
      public static inline final SHOOT_DEF:Float = 6;
      
      public static inline final MAGIC_DEF:Float = 7;
      
      public static inline final MELEE_SPD:Float = 8;
      
      public static inline final SHOOT_SPD:Float = 9;
      
      public static inline final MAGIC_SPD:Float = 10;
      
      public static inline final HP_REGEN:Float = 11;
      
      public static inline final MP_REGEN:Float = 12;
      
      public static inline final MOVEMENT:Float = 13;
      
      public static inline final LUCK:Float = 14;
      
      public static inline final LV_HP_BOOST:Float = 0;
      
      public static inline final LV_MP_BOOST:Float = 1;
      
      public static inline final LV_MELEE_ATK:Float = 2;
      
      public static inline final LV_SHOOT_ATK:Float = 3;
      
      public static inline final LV_MAGIC_ATK:Float = 4;
      
      public static inline final LV_MELEE_DEF:Float = 5;
      
      public static inline final LV_SHOOT_DEF:Float = 6;
      
      public static inline final LV_MAGIC_DEF:Float = 7;
      
      public static inline final LV_MELEE_SPD:Float = 8;
      
      public static inline final LV_SHOOT_SPD:Float = 9;
      
      public static inline final LV_MAGIC_SPD:Float = 10;
      
      public static inline final LV_HP_REGEN:Float = 11;
      
      public static inline final LV_MP_REGEN:Float = 12;
      
      public static inline final LV_MOVEMENT:Float = 13;
      
      public static inline final LV_LUCK:Float = 14;
      
      public static inline final ATTTACK_TYPE_MELEE:Float = 0;
      
      public static inline final ATTTACK_TYPE_RANGE:Float = 1;
      
      public static inline final ATTTACK_TYPE_MAGIC:Float = 2;
      
      public static inline final B2D_ENVIRONMENT_MASK= (1 : UInt);
      
      public static inline final B2D_COMBAT_MASK= (2 : UInt);
      
      public static inline final TEAM_ENVIRONMENT= (1 : UInt);
      
      public static inline final TEAM_1= (5 : UInt);
      
      public static inline final TEAM_2= (6 : UInt);
      
      public static inline final TEAM_3= (7 : UInt);
      
      public static inline final ABILITY_SUFFER_IMMUNITY= (1 : UInt);
      
      public static inline final ABILITY_INVULNERABLE_MELEE= (2 : UInt);
      
      public static inline final ABILITY_INVULNERABLE_MAGIC= (4 : UInt);
      
      public static inline final ABILITY_INVULNERABLE_SHOOT= (8 : UInt);
      
      public static inline final ABILITY_INVULNERABLE_ALL= (14 : UInt);
      
      public static inline final ABILITY_BERSERK_MODE= (16 : UInt);
      
      public static inline final ABILITY_PARALYZED= (32 : UInt);
      
      public static inline final ABILITY_BREAK_FREE= (64 : UInt);
      
      public static inline final ABILITY_PANIC= (128 : UInt);
      
      public static inline final ABILITY_PARALYZE_IMMUNITY= (256 : UInt);
      
      public static inline final ABILITY_DISABLE_CONTROLS= (512 : UInt);
      
      public static inline final ABILITY_PIERCE_IMMUNE= (16777216 : UInt);
      
      public static inline final BERSERKER_RAMPAGE= "RAMPAGE";
      
      public static inline final UI_16_TO_9_PORT_OBJECT_SCALE:Float = 1.8;
      
      public static inline final FILTER_QUALITY_LOW= (0 : UInt);
      
      public static inline final FILTER_QUALITY_MEDIUM= (1 : UInt);
      
      public static inline final FILTER_QUALITY_HIGH= (2 : UInt);
      
      public static var StatNames:Vector<String> = Vector.ofArray(["HP_BOOST","MP_BOOST","MELEE_ATK","SHOOT_ATK","MAGIC_ATK","SHOOT_DEF","MELEE_DEF","MAGIC_DEF","MELEE_SPD","SHOOT_SPD","MAGIC_SPD","HP_REGEN","MP_REGEN","MOVEMENT","LUCK"]);
      
      public static final UI_ROLLOVER_FILTER:GlowFilter = new GlowFilter((16633879 : UInt),1,8,8,5);
      
      public static final UI_SELECTED_FILTER:GlowFilter = new GlowFilter((16777215 : UInt),1,6,6,12);
      
      public static final UI_DISABLED_FILTER:GlowFilter = new GlowFilter((16711680 : UInt),0.1,5,5,2.6);
      
      public function new()
      {
         
      }
      
      public static function NameToSlotOffset(param1:String) : Int
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < StatNames.length)
         {
            if(StatNames[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         return -1;
      }
      
      public static function b2dMaskForAllTeamsBut(param1:UInt) : UInt
      {
         if(param1 == 5)
         {
            return (193 : UInt);
         }
         if(param1 == 6)
         {
            return (161 : UInt);
         }
         if(param1 == 7)
         {
            return (97 : UInt);
         }
         if(param1 == 1)
         {
            return (96 : UInt);
         }
         Logger.error("Unable to determine box2D team mask for team: " + param1 + " in function: b2dMaskForAllTeamsBut");
         return (0 : UInt);
      }
      
      public static function b2dMaskForTeam(param1:UInt) : UInt
      {
         if(param1 == 5)
         {
            return (1 << 5 : UInt);
         }
         if(param1 == 6)
         {
            return (1 << 6 : UInt);
         }
         if(param1 == 7)
         {
            return (1 << 7 : UInt);
         }
         if(param1 == 1)
         {
            return (1 : UInt);
         }
         Logger.error("Unable to determine box2D team mask for team: " + param1 + " in function: b2dMaskForTeam");
         return (0 : UInt);
      }
      
      public static function mapAbilityMask(param1:String) : UInt
      {
         if(param1 == "SUFFER_IMMUNE")
         {
            return (1 : UInt);
         }
         if(param1 == "INVULNERABLE_MELEE")
         {
            return (2 : UInt);
         }
         if(param1 == "INVULNERABLE_MAGIC")
         {
            return (4 : UInt);
         }
         if(param1 == "INVULNERABLE_SHOOT")
         {
            return (8 : UInt);
         }
         if(param1 == "INVULNERABLE_ALL")
         {
            return (14 : UInt);
         }
         if(param1 == "BERSERK_MODE")
         {
            return (16 : UInt);
         }
         if(param1 == "PARALYZED")
         {
            return (32 : UInt);
         }
         if(param1 == "DISABLE_CONTROLS")
         {
            return (512 : UInt);
         }
         if(param1 == "BREAK_FREE")
         {
            return (64 : UInt);
         }
         if(param1 == "PANIC")
         {
            return (128 : UInt);
         }
         if(param1 == "PARALYZE_IMMUNITY")
         {
            return (256 : UInt);
         }
         if(param1 == "PIERCE_IMMUNE")
         {
            return (16777216 : UInt);
         }
         return (0 : UInt);
      }
      
      public static function traceClipChildren(param1:MovieClip) 
      {
         var _loc2_= 0;
         trace("+ number of DisplayObject: " + param1.numChildren + "  --------------------------------");
         _loc2_ = 0;
         while(_loc2_ < param1.numChildren)
         {
            trace("\t|\t " + _loc2_ + ".\t name:" + param1.getChildAt(_loc2_).name + "\t type:" + ASCompat.typeof(param1.getChildAt(_loc2_)) + "\t" + param1.getChildAt(_loc2_));
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         trace("\t+ --------------------------------------------------------------------------------------");
      }
      
      public static function highlightButton(param1:ASAny, param2:UInt = (1 : UInt)) 
      {
         var _loc3_= UI_ROLLOVER_FILTER;
         if(param2 == 0)
         {
            _loc3_.quality = 1;
         }
         else if(param2 == 1)
         {
            _loc3_.quality = 2;
         }
         else if(param2 == 2)
         {
            _loc3_.quality = 3;
         }
         else
         {
            Logger.warn("No such quality exists..");
         }
         if(Std.isOfType(param1 , MovieClip))
         {
            ASCompat.setProperty(param1, "filters", [_loc3_]);
         }
         else
         {
            ASCompat.setProperty(param1.root, "filters", [_loc3_]);
         }
      }
      
      public static function unHighlightButton(param1:ASAny) 
      {
         if(param1 == null)
         {
            Logger.warn("Cannot unhilight null button/movieclip");
         }
         if(Std.isOfType(param1 , MovieClip))
         {
            ASCompat.setProperty(param1, "filters", []);
         }
         else
         {
            ASCompat.setProperty(param1.root, "filters", null);
         }
      }
      
      public static function endsWith(param1:String, param2:String) : Bool
      {
         return param2 == param1.substring(param1.length - param2.length);
      }
   }


