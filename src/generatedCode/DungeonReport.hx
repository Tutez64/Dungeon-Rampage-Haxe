package generatedCode
;
   import networkCode.DcNetworkPacket;
   
    class DungeonReport
   {
      
      public var name:String;
      
      public var trophyCount:UInt = 0;
      
      public var id:UInt = 0;
      
      public var type:UInt = 0;
      
      public var skin_type:UInt = 0;
      
      public var kills:UInt = 0;
      
      public var xp:UInt = 0;
      
      public var xp_earned:UInt = 0;
      
      public var xp_bonus:UInt = 0;
      
      public var team_xp_bonus:UInt = 0;
      
      public var gold_earned:UInt = 0;
      
      public var gems_earned:UInt = 0;
      
      public var boost_xp:Float = Math.NaN;
      
      public var boost_gold:Float = Math.NaN;
      
      public var receivedTrophy:UInt = 0;
      
      public var dungeonModifier1:UInt = 0;
      
      public var dungeonModifier2:UInt = 0;
      
      public var dungeonModifier3:UInt = 0;
      
      public var dungeonModifier4:UInt = 0;
      
      public var loot_type_1:UInt = 0;
      
      public var loot_type_2:UInt = 0;
      
      public var loot_type_3:UInt = 0;
      
      public var loot_type_4:UInt = 0;
      
      public var weapon_level_1:UInt = 0;
      
      public var weapon_level_2:UInt = 0;
      
      public var weapon_level_3:UInt = 0;
      
      public var weapon_type_1:UInt = 0;
      
      public var weapon_type_2:UInt = 0;
      
      public var weapon_type_3:UInt = 0;
      
      public var modifier_type_1a:UInt = 0;
      
      public var modifier_type_1b:UInt = 0;
      
      public var legendary_modifier_type_1:UInt = 0;
      
      public var modifier_type_2a:UInt = 0;
      
      public var modifier_type_2b:UInt = 0;
      
      public var legendary_modifier_type_2:UInt = 0;
      
      public var modifier_type_3a:UInt = 0;
      
      public var modifier_type_3b:UInt = 0;
      
      public var legendary_modifier_type_3:UInt = 0;
      
      public var weapon_power_1:UInt = 0;
      
      public var weapon_power_2:UInt = 0;
      
      public var weapon_power_3:UInt = 0;
      
      public var weapon_rarity_1:UInt = 0;
      
      public var weapon_rarity_2:UInt = 0;
      
      public var weapon_rarity_3:UInt = 0;
      
      public var chest_type_1:UInt = 0;
      
      public var chest_type_2:UInt = 0;
      
      public var chest_type_3:UInt = 0;
      
      public var chest_type_4:UInt = 0;
      
      public var valid:UInt = 0;
      
      public var account_flags:UInt = 0;
      
      public var totalAvatarsOwned:UInt = 0;
      
      public var consumable1_id:UInt = 0;
      
      public var consumable1_count:UInt = 0;
      
      public var consumable2_id:UInt = 0;
      
      public var consumable2_count:UInt = 0;
      
      public function new()
      {
         
      }
      
      public static function readFromPacket(param1:DcNetworkPacket) : DungeonReport
      {
         var _loc2_= new DungeonReport();
         _loc2_.name = param1.readUTF();
         _loc2_.trophyCount = param1.readUnsignedInt();
         _loc2_.id = param1.readUnsignedInt();
         _loc2_.type = param1.readUnsignedInt();
         _loc2_.skin_type = param1.readUnsignedInt();
         _loc2_.kills = param1.readUnsignedInt();
         _loc2_.xp = param1.readUnsignedInt();
         _loc2_.xp_earned = param1.readUnsignedInt();
         _loc2_.xp_bonus = param1.readUnsignedInt();
         _loc2_.team_xp_bonus = param1.readUnsignedInt();
         _loc2_.gold_earned = param1.readUnsignedInt();
         _loc2_.gems_earned = param1.readUnsignedInt();
         _loc2_.boost_xp = param1.readFloat();
         _loc2_.boost_gold = param1.readFloat();
         _loc2_.receivedTrophy = param1.readUnsignedByte();
         _loc2_.dungeonModifier1 = param1.readUnsignedInt();
         _loc2_.dungeonModifier2 = param1.readUnsignedInt();
         _loc2_.dungeonModifier3 = param1.readUnsignedInt();
         _loc2_.dungeonModifier4 = param1.readUnsignedInt();
         _loc2_.loot_type_1 = param1.readUnsignedInt();
         _loc2_.loot_type_2 = param1.readUnsignedInt();
         _loc2_.loot_type_3 = param1.readUnsignedInt();
         _loc2_.loot_type_4 = param1.readUnsignedInt();
         _loc2_.weapon_level_1 = param1.readUnsignedInt();
         _loc2_.weapon_level_2 = param1.readUnsignedInt();
         _loc2_.weapon_level_3 = param1.readUnsignedInt();
         _loc2_.weapon_type_1 = param1.readUnsignedInt();
         _loc2_.weapon_type_2 = param1.readUnsignedInt();
         _loc2_.weapon_type_3 = param1.readUnsignedInt();
         _loc2_.modifier_type_1a = param1.readUnsignedInt();
         _loc2_.modifier_type_1b = param1.readUnsignedInt();
         _loc2_.legendary_modifier_type_1 = param1.readUnsignedInt();
         _loc2_.modifier_type_2a = param1.readUnsignedInt();
         _loc2_.modifier_type_2b = param1.readUnsignedInt();
         _loc2_.legendary_modifier_type_2 = param1.readUnsignedInt();
         _loc2_.modifier_type_3a = param1.readUnsignedInt();
         _loc2_.modifier_type_3b = param1.readUnsignedInt();
         _loc2_.legendary_modifier_type_3 = param1.readUnsignedInt();
         _loc2_.weapon_power_1 = param1.readUnsignedInt();
         _loc2_.weapon_power_2 = param1.readUnsignedInt();
         _loc2_.weapon_power_3 = param1.readUnsignedInt();
         _loc2_.weapon_rarity_1 = param1.readUnsignedInt();
         _loc2_.weapon_rarity_2 = param1.readUnsignedInt();
         _loc2_.weapon_rarity_3 = param1.readUnsignedInt();
         _loc2_.chest_type_1 = param1.readUnsignedInt();
         _loc2_.chest_type_2 = param1.readUnsignedInt();
         _loc2_.chest_type_3 = param1.readUnsignedInt();
         _loc2_.chest_type_4 = param1.readUnsignedInt();
         _loc2_.valid = param1.readUnsignedByte();
         _loc2_.account_flags = param1.readUnsignedInt();
         _loc2_.totalAvatarsOwned = param1.readUnsignedInt();
         _loc2_.consumable1_id = param1.readUnsignedInt();
         _loc2_.consumable1_count = param1.readUnsignedInt();
         _loc2_.consumable2_id = param1.readUnsignedInt();
         _loc2_.consumable2_count = param1.readUnsignedInt();
         return _loc2_;
      }
      
      public function writeToPacket(param1:DcNetworkPacket) 
      {
         param1.writeUTF(name);
         param1.writeUnsignedInt(trophyCount);
         param1.writeUnsignedInt(id);
         param1.writeUnsignedInt(type);
         param1.writeUnsignedInt(skin_type);
         param1.writeUnsignedInt(kills);
         param1.writeUnsignedInt(xp);
         param1.writeUnsignedInt(xp_earned);
         param1.writeUnsignedInt(xp_bonus);
         param1.writeUnsignedInt(team_xp_bonus);
         param1.writeUnsignedInt(gold_earned);
         param1.writeUnsignedInt(gems_earned);
         param1.writeFloat(boost_xp);
         param1.writeFloat(boost_gold);
         param1.writeByte((receivedTrophy : Int));
         param1.writeUnsignedInt(dungeonModifier1);
         param1.writeUnsignedInt(dungeonModifier2);
         param1.writeUnsignedInt(dungeonModifier3);
         param1.writeUnsignedInt(dungeonModifier4);
         param1.writeUnsignedInt(loot_type_1);
         param1.writeUnsignedInt(loot_type_2);
         param1.writeUnsignedInt(loot_type_3);
         param1.writeUnsignedInt(loot_type_4);
         param1.writeUnsignedInt(weapon_level_1);
         param1.writeUnsignedInt(weapon_level_2);
         param1.writeUnsignedInt(weapon_level_3);
         param1.writeUnsignedInt(weapon_type_1);
         param1.writeUnsignedInt(weapon_type_2);
         param1.writeUnsignedInt(weapon_type_3);
         param1.writeUnsignedInt(modifier_type_1a);
         param1.writeUnsignedInt(modifier_type_1b);
         param1.writeUnsignedInt(legendary_modifier_type_1);
         param1.writeUnsignedInt(modifier_type_2a);
         param1.writeUnsignedInt(modifier_type_2b);
         param1.writeUnsignedInt(legendary_modifier_type_2);
         param1.writeUnsignedInt(modifier_type_3a);
         param1.writeUnsignedInt(modifier_type_3b);
         param1.writeUnsignedInt(legendary_modifier_type_3);
         param1.writeUnsignedInt(weapon_power_1);
         param1.writeUnsignedInt(weapon_power_2);
         param1.writeUnsignedInt(weapon_power_3);
         param1.writeUnsignedInt(weapon_rarity_1);
         param1.writeUnsignedInt(weapon_rarity_2);
         param1.writeUnsignedInt(weapon_rarity_3);
         param1.writeUnsignedInt(chest_type_1);
         param1.writeUnsignedInt(chest_type_2);
         param1.writeUnsignedInt(chest_type_3);
         param1.writeUnsignedInt(chest_type_4);
         param1.writeByte((valid : Int));
         param1.writeUnsignedInt(account_flags);
         param1.writeUnsignedInt(totalAvatarsOwned);
         param1.writeUnsignedInt(consumable1_id);
         param1.writeUnsignedInt(consumable1_count);
         param1.writeUnsignedInt(consumable2_id);
         param1.writeUnsignedInt(consumable2_count);
      }
   }


