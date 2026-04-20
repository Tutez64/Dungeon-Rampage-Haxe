package gameMasterDictionary
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import dBGlobals.DBGlobal;
   import org.as3commons.collections.Map;
   
    class GameMaster
   {
      
      public var Heroes:Vector<GMHero> = new Vector();
      
      public var Npcs:Vector<GMNpc> = new Vector();
      
      public var Attacks:Vector<GMAttack> = new Vector();
      
      public var Projectiles:Vector<GMProjectile> = new Vector();
      
      public var Buffs:Vector<GMBuff> = new Vector();
      
      public var Auras:Vector<GMAura> = new Vector();
      
      public var WeaponItems:Vector<GMWeaponItem> = new Vector();
      
      public var WeaponAesthetics:Vector<GMWeaponAesthetic> = new Vector();
      
      public var WeaponMastertypes:Vector<GMWeaponMastertype> = new Vector();
      
      public var ItemDrops:Vector<GMItemDrop> = new Vector();
      
      public var Doobers:Vector<GMDoober> = new Vector();
      
      public var DooberDrops:Vector<GMDooberDrop> = new Vector();
      
      public var MapNodes:Vector<GMMapNode> = new Vector();
      
      public var DungeonModifiers:Vector<GMDungeonModifier> = new Vector();
      
      public var Stats:Vector<GMStat> = new Vector();
      
      public var SuperStats:Vector<GMSuperStat> = new Vector();
      
      public var Props:Vector<GMProp> = new Vector();
      
      public var Offers:Vector<GMOffer> = new Vector();
      
      public var Stackables:Vector<GMStackable> = new Vector();
      
      public var CashDeals:Vector<GMCashDeal> = new Vector();
      
      public var FeedPosts:Vector<GMFeedPosts> = new Vector();
      
      public var Achievements:Vector<GMAchievement> = new Vector();
      
      public var Hints:Vector<GMHints> = new Vector();
      
      public var ColiseumTiers:Vector<GMColiseumTier> = new Vector();
      
      public var Skins:Vector<GMSkin> = new Vector();
      
      public var Chests:Vector<GMChest> = new Vector();
      
      public var Keys:Vector<GMKey> = new Vector();
      
      public var Rarity:Vector<GMRarity> = new Vector();
      
      public var Modifiers:Vector<GMModifier> = new Vector();
      
      public var LegendaryModifiers:Vector<GMLegendaryModifier> = new Vector();
      
      public var heroById:Map;
      
      public var npcById:Map;
      
      public var attackById:Map;
      
      public var projectileById:Map;
      
      public var buffById:Map;
      
      public var buffColorTypeById:Map;
      
      public var auraById:Map;
      
      public var weaponItemById:Map;
      
      public var weaponSubtypeById:Map;
      
      public var itemDropById:Map;
      
      public var dooberById:Map;
      
      public var dooberDropById:Map;
      
      public var dooberByChestId:Map;
      
      public var mapNodeById:Map;
      
      public var mapNodeByBitIndex:Map;
      
      public var infiniteDungeonsById:Map;
      
      public var dungeonModifierById:Map;
      
      public var statById:Map;
      
      public var superStatById:Map;
      
      public var propById:Map;
      
      public var offerById:Map;
      
      public var offerByStackableId:Map;
      
      public var stackableById:Map;
      
      public var cashDealById:Map;
      
      public var feedPostsById:Map;
      
      public var coliseumTierById:Map;
      
      public var achievementsById:Map;
      
      public var skinsById:Map;
      
      public var chestsById:Map;
      
      public var keysByOfferId:Map;
      
      public var rarityById:Map;
      
      public var modifiersById:Map;
      
      public var legendaryModifiersById:Map;
      
      public var heroByConstant:Map;
      
      public var npcByConstant:Map;
      
      public var attackByConstant:Map;
      
      public var projectileByConstant:Map;
      
      public var weaponAestheticByWeaponItemConstant:Map;
      
      public var buffByConstant:Map;
      
      public var auraByConstant:Map;
      
      public var weaponItemByConstant:Map;
      
      public var weaponSubtypeByConstant:Map;
      
      public var itemDropByConstant:Map;
      
      public var dooberByConstant:Map;
      
      public var dooberDropByConstant:Map;
      
      public var mapNodeByConstant:Map;
      
      public var infiniteDungeonsByConstant:Map;
      
      public var dungeonModifierByConstant:Map;
      
      public var statByConstant:Map;
      
      public var superStatByConstant:Map;
      
      public var propByConstant:Map;
      
      public var stackableByConstant:Map;
      
      public var feedPostsByConstant:Map;
      
      public var hintsByConstant:Map;
      
      public var coliseumTierByConstant:Map;
      
      var mSkinsByConstant:Map;
      
      var mDefaultSkins:Map;
      
      public var rarityByConstant:Map;
      
      public var modifiersByConstant:Map;
      
      public var legendaryModifiersByConstant:Map;
      
      var mSecurityValue:Int = 0;
      
      public var weaponSubtypesSortedByID:Array<ASAny>;
      
      public var stat_BonusMultiplier:StatVector;
      
      public var stat_bias:StatVector;
      
      public var stat_MaxCap:StatVector;
      
      var mGameMasterJson:ASObject;
      
      public var triggerToTriggerable:Map;
      
      public var TriggerableIdToTriggerableEvent:Map;
      
      public function new(param1:ASObject, param2:ASObject)
      {
         
         mGameMasterJson = param1;
         try
         {
            buildDictionary(param2);
         }
         catch(e:Dynamic)
         {
            Logger.fatal("Failed to process DB_GameMaster.json\n" + Std.string(e.message),e);
         }
         PostProcess(param2);
      }
      
      public static function getSplitTestString(param1:String, param2:String, param3:ASObject) : String
      {
         var _loc4_:ASAny;
         if (checkNullIteratee(param3)) for (_tmp_ in iterateDynamicValues(param3))
         {
            _loc4_ = _tmp_;
            if(_loc4_.name == param1)
            {
               return _loc4_.value;
            }
         }
         return param2;
      }
      
      public function init() 
      {
      }
      
      public function destroy() 
      {
      }
      
      @:isVar public var securityChecksum(get,never):Int;
public function  get_securityChecksum() : Int
      {
         return mSecurityValue;
      }
      
      public function getActorMap(param1:UInt) : Map
      {
         if(heroById.hasKey(param1))
         {
            return heroById;
         }
         if(npcById.hasKey(param1))
         {
            return npcById;
         }
         Logger.warn("ID: " + Std.string(param1) + " not found in hero or npc map. Returning null");
         return null;
      }
      
      public function PostProcessWeaponItem() 
      {
         var _loc2_= 0;
         var _loc1_:GMWeaponItem = null;
         _loc2_ = 0;
         while(_loc2_ < WeaponItems.length)
         {
            _loc1_ = WeaponItems[_loc2_];
            _loc1_.WeaponAestheticList = (weaponAestheticByWeaponItemConstant.itemFor(_loc1_.Constant) : Vector<GMWeaponAesthetic>);
            if(_loc1_.WeaponAestheticList == null)
            {
               Logger.error(_loc1_.Constant + " doesn\'t have an aesthetic");
            }
            _loc2_++;
         }
      }
      
      public function PostProcess(param1:ASObject) 
      {
         var _loc3_= 0;
         var _loc2_:GMStat = null;
         PostProcessWeaponItem();
         stat_bias = new StatVector();
         stat_BonusMultiplier = new StatVector();
         stat_MaxCap = new StatVector();
         _loc3_ = 0;
         while(_loc3_ < DBGlobal.StatNames.length)
         {
            _loc2_ = ASCompat.dynamicAs(statByConstant.itemFor(DBGlobal.StatNames[_loc3_]), gameMasterDictionary.GMStat);
            if(_loc2_ == null)
            {
               trace("Error Finding State By name ",DBGlobal.StatNames[_loc3_]);
            }
            else
            {
               stat_BonusMultiplier.values[_loc3_] = _loc2_.Bonus;
               stat_MaxCap.values[_loc3_] = _loc2_.MaxCap;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         stat_bias.values[8] = 1;
         stat_bias.values[9] = 1;
         stat_bias.values[10] = 1;
         stat_bias.values[13] = 1;
      }
      
      public function buildDictionary(param1:ASObject) 
      {
         var __ax4_iter_48:Vector<GMModifier>;
         var __ax4_iter_49:Vector<GMLegendaryModifier>;
         var superStatArray:Array<ASAny>;
         var heroArray:Array<ASAny>;
         var levelingArray:Array<ASAny>;
         var TotalExperience:Float;
         var TotalStats:Float;
         var lidx:Float;
         var levelId:Float;
         var levelValue:Float;
         var statValue:Float;
         var npcArray:Array<ASAny>;
         var attackArray:Array<ASAny>;
         var projectileArray:Array<ASAny>;
         var buffArray:Array<ASAny>;
         var buffColorTypeArray:Array<ASAny>;
         var gmBuffColorType:GMBuffColorType;
         var auraArray:Array<ASAny>;
         var ModifiersArray:Array<ASAny>;
         var modifier:GMModifier;
         var LegendaryModifiersArray:Array<ASAny>;
         var legendaryModifier:GMLegendaryModifier;
         var weaponItemArray:Array<ASAny>;
         var gmWeapon:GMWeaponItem;
         var gmMod:GMModifier;
         var gmLegendaryMod:GMLegendaryModifier;
         var weaponMastertypeArray:Array<ASAny>;
         var dooberArray:Array<ASAny>;
         var dooberDropArray:Array<ASAny>;
         var mapNodeArray:Array<ASAny>;
         var infiniteDungeonArray:Array<ASAny>;
         var gmInfiniteDungeon:GMInfiniteDungeon;
         var dungeonModifierArray:Array<ASAny>;
         var PropArray:Array<ASAny>;
         var OfferArray:Array<ASAny>;
         var offer:GMOffer;
         var OfferDetailArray:Array<ASAny>;
         var detail:GMOfferDetail;
         var ChestsArray:Array<ASAny>;
         var chest:GMChest;
         var KeysArray:Array<ASAny>;
         var key:GMKey;
         var RarityArray:Array<ASAny>;
         var rarity:GMRarity;
         var WeaponAestheticArray:Array<ASAny>;
         var weaponAesthetic:GMWeaponAesthetic;
         var weaponAestheticVector:Vector<GMWeaponAesthetic>;
         var tempAestheticVector:Vector<GMWeaponAesthetic>;
         var splitTest:ASObject;
         var wantCoinAltOffers:Bool;
         var wantCashRanger:Bool;
         var gmOffer:GMOffer;
         var fullPriceOffer:GMOffer;
         var coinOffer:GMOffer;
         var stackableArray:Array<ASAny>;
         var stackable:GMStackable;
         var cashDealArray:Array<ASAny>;
         var cashDeal:GMCashDeal;
         var sortOrder:String;
         var feedPostsArray:Array<ASAny>;
         var feedPost:GMFeedPosts;
         var achievementsArray:Array<ASAny>;
         var achievement:GMAchievement;
         var hintsArray:Array<ASAny>;
         var hint:GMHints;
         var coliseumTiersArray:Array<ASAny>;
         var tier:GMColiseumTier;
         var skinsArray:Array<ASAny>;
         var skin:GMSkin;
         var defaultGmSkin:GMSkin;
         var playerScales:Array<ASAny>;
         var splitTests:ASObject = param1;
         mSecurityValue = 0;
         var securityCatergoryCounter= 0;
         statById = new Map();
         statByConstant = new Map();
         var statArray:Array<ASAny> = ASCompat.dynamicAs(mGameMasterJson.Stats, Array);
         var idx:Float = 0;
         while(idx < statArray.length)
         {
            Stats[Std.int(idx)] = new GMStat(statArray[Std.int(idx)]);
            statById.add(Stats[Std.int(idx)].Id,Stats[Std.int(idx)]);
            statByConstant.add(Stats[Std.int(idx)].Constant,Stats[Std.int(idx)]);
            idx = idx + 1;
         }
         superStatById = new Map();
         superStatByConstant = new Map();
         superStatArray = ASCompat.dynamicAs(mGameMasterJson.SuperStats, Array);
         idx = 0;
         while(idx < superStatArray.length)
         {
            SuperStats[Std.int(idx)] = new GMSuperStat(superStatArray[Std.int(idx)]);
            superStatById.add(SuperStats[Std.int(idx)].Id,SuperStats[Std.int(idx)]);
            superStatByConstant.add(SuperStats[Std.int(idx)].Constant,SuperStats[Std.int(idx)]);
            idx = idx + 1;
         }
         heroById = new Map();
         heroByConstant = new Map();
         heroArray = ASCompat.dynamicAs(mGameMasterJson.Hero, Array);
         levelingArray = ASCompat.dynamicAs(mGameMasterJson.Leveling, Array);
         idx = 0;
         while(idx < heroArray.length)
         {
            Heroes[Std.int(idx)] = new GMHero(heroArray[Std.int(idx)],splitTests);
            TotalExperience = 0;
            TotalStats = 0;
            lidx = 0;
            while(lidx < levelingArray.length)
            {
               levelId = ASCompat.toNumber(levelingArray[Std.int(lidx)].Level);
               levelValue = ASCompat.toNumber(levelingArray[Std.int(lidx)][Heroes[Std.int(idx)].Constant]);
               statValue = ASCompat.toNumber(levelingArray[Std.int(lidx)].StatPoints);
               if(levelValue != 0)
               {
                  TotalExperience += levelValue;
                  TotalStats += statValue;
                  Heroes[Std.int(idx)].LoadingOnly_addExpRecord((Std.int(levelId) : UInt),(Std.int(TotalExperience - 1) : UInt),(Std.int(TotalStats) : UInt));
               }
               lidx = lidx + 1;
            }
            heroById.add(Heroes[Std.int(idx)].Id,Heroes[Std.int(idx)]);
            heroByConstant.add(Heroes[Std.int(idx)].Constant,Heroes[Std.int(idx)]);
            Heroes[Std.int(idx)].HeroSlotHelper(Heroes[Std.int(idx)].StatUpgrade1,0,Heroes[Std.int(idx)].AmtStat1,this);
            Heroes[Std.int(idx)].HeroSlotHelper(Heroes[Std.int(idx)].StatUpgrade2,1,Heroes[Std.int(idx)].AmtStat2,this);
            Heroes[Std.int(idx)].HeroSlotHelper(Heroes[Std.int(idx)].StatUpgrade3,2,Heroes[Std.int(idx)].AmtStat3,this);
            Heroes[Std.int(idx)].HeroSlotHelper(Heroes[Std.int(idx)].StatUpgrade4,3,Heroes[Std.int(idx)].AmtStat4,this);
            securityCatergoryCounter += Heroes[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         npcById = new Map();
         npcByConstant = new Map();
         npcArray = ASCompat.dynamicAs(mGameMasterJson.Npc, Array);
         idx = 0;
         while(idx < npcArray.length)
         {
            Npcs[Std.int(idx)] = new GMNpc(npcArray[Std.int(idx)]);
            npcById.add(Npcs[Std.int(idx)].Id,Npcs[Std.int(idx)]);
            npcByConstant.add(Npcs[Std.int(idx)].Constant,Npcs[Std.int(idx)]);
            securityCatergoryCounter += Npcs[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         attackById = new Map();
         attackByConstant = new Map();
         attackArray = ASCompat.dynamicAs(mGameMasterJson.Attack, Array);
         idx = 0;
         while(idx < attackArray.length)
         {
            Attacks[Std.int(idx)] = new GMAttack(attackArray[Std.int(idx)]);
            attackById.add(Attacks[Std.int(idx)].Id,Attacks[Std.int(idx)]);
            attackByConstant.add(Attacks[Std.int(idx)].Constant,Attacks[Std.int(idx)]);
            securityCatergoryCounter += Attacks[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         projectileById = new Map();
         projectileByConstant = new Map();
         projectileArray = ASCompat.dynamicAs(mGameMasterJson.Projectile, Array);
         idx = 0;
         while(idx < projectileArray.length)
         {
            Projectiles[Std.int(idx)] = new GMProjectile(projectileArray[Std.int(idx)]);
            projectileById.add(Projectiles[Std.int(idx)].Id,Projectiles[Std.int(idx)]);
            projectileByConstant.add(Projectiles[Std.int(idx)].Constant,Projectiles[Std.int(idx)]);
            securityCatergoryCounter += Projectiles[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         buffById = new Map();
         buffByConstant = new Map();
         buffArray = ASCompat.dynamicAs(mGameMasterJson.Buff, Array);
         idx = 0;
         while(idx < buffArray.length)
         {
            Buffs[Std.int(idx)] = new GMBuff(buffArray[Std.int(idx)]);
            buffById.add(Buffs[Std.int(idx)].Id,Buffs[Std.int(idx)]);
            buffByConstant.add(Buffs[Std.int(idx)].Constant,Buffs[Std.int(idx)]);
            securityCatergoryCounter += Buffs[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         buffColorTypeById = new Map();
         buffColorTypeArray = ASCompat.dynamicAs(mGameMasterJson.BuffColorType, Array);
         idx = 0;
         while(idx < buffColorTypeArray.length)
         {
            gmBuffColorType = new GMBuffColorType(buffColorTypeArray[Std.int(idx)]);
            buffColorTypeById.add(gmBuffColorType.Id,gmBuffColorType);
            idx = idx + 1;
         }
         auraById = new Map();
         auraByConstant = new Map();
         auraArray = ASCompat.dynamicAs(mGameMasterJson.Auras, Array);
         idx = 0;
         while(idx < auraArray.length)
         {
            Auras[Std.int(idx)] = new GMAura(auraArray[Std.int(idx)]);
            auraById.add(Auras[Std.int(idx)].Id,Auras[Std.int(idx)]);
            auraByConstant.add(Auras[Std.int(idx)].Constant,Auras[Std.int(idx)]);
            idx = idx + 1;
         }
         modifiersById = new Map();
         modifiersByConstant = new Map();
         ModifiersArray = ASCompat.dynamicAs(mGameMasterJson.Modifiers, Array);
         idx = 0;
         while(idx < ModifiersArray.length)
         {
            modifier = new GMModifier(ModifiersArray[Std.int(idx)]);
            Modifiers[Std.int(idx)] = modifier;
            modifiersById.add(modifier.Id,modifier);
            modifiersByConstant.add(modifier.Constant,modifier);
            idx = idx + 1;
         }
         legendaryModifiersById = new Map();
         legendaryModifiersByConstant = new Map();
         LegendaryModifiersArray = ASCompat.dynamicAs(mGameMasterJson.LegendaryModifiers, Array);
         idx = 0;
         while(idx < LegendaryModifiersArray.length)
         {
            legendaryModifier = new GMLegendaryModifier(LegendaryModifiersArray[Std.int(idx)]);
            LegendaryModifiers[Std.int(idx)] = legendaryModifier;
            legendaryModifiersById.add(legendaryModifier.Id,legendaryModifier);
            legendaryModifiersByConstant.add(legendaryModifier.Constant,legendaryModifier);
            idx = idx + 1;
         }
         weaponItemById = new Map();
         weaponItemByConstant = new Map();
         weaponItemArray = ASCompat.dynamicAs(mGameMasterJson.WeaponItem, Array);
         idx = 0;
         while(idx < weaponItemArray.length)
         {
            gmWeapon = new GMWeaponItem(weaponItemArray[Std.int(idx)]);
            WeaponItems[Std.int(idx)] = gmWeapon;
            weaponItemById.add(gmWeapon.Id,gmWeapon);
            weaponItemByConstant.add(gmWeapon.Constant,gmWeapon);
            __ax4_iter_48 = Modifiers;
            if (checkNullIteratee(__ax4_iter_48)) for (_tmp_ in __ax4_iter_48)
            {
               gmMod  = _tmp_;
               if(ASCompat.toBool(weaponItemArray[Std.int(idx)][gmMod.MODIFIER_TYPE]))
               {
                  gmWeapon.PotentialModifiers.push(gmMod);
               }
            }
            __ax4_iter_49 = LegendaryModifiers;
            if (checkNullIteratee(__ax4_iter_49)) for (_tmp_ in __ax4_iter_49)
            {
               gmLegendaryMod  = _tmp_;
               gmWeapon.PotentialLegendaryModifiers.push(gmLegendaryMod);
            }
            idx = idx + 1;
         }
         weaponSubtypeById = new Map();
         weaponSubtypeByConstant = new Map();
         weaponSubtypesSortedByID = [];
         weaponMastertypeArray = ASCompat.dynamicAs(mGameMasterJson.WeaponMastertype, Array);
         idx = 0;
         while(idx < weaponMastertypeArray.length)
         {
            WeaponMastertypes[Std.int(idx)] = new GMWeaponMastertype(weaponMastertypeArray[Std.int(idx)]);
            weaponSubtypeById.add(WeaponMastertypes[Std.int(idx)].Id,WeaponMastertypes[Std.int(idx)]);
            weaponSubtypeByConstant.add(WeaponMastertypes[Std.int(idx)].Constant,WeaponMastertypes[Std.int(idx)]);
            weaponSubtypesSortedByID.push(WeaponMastertypes[Std.int(idx)].Id);
            idx = idx + 1;
         }
         weaponSubtypesSortedByID.sort(Reflect.compare);
         dooberById = new Map();
         dooberByConstant = new Map();
         dooberByChestId = new Map();
         dooberArray = ASCompat.dynamicAs(mGameMasterJson.Doobers, Array);
         idx = 0;
         while(idx < dooberArray.length)
         {
            Doobers[Std.int(idx)] = new GMDoober(dooberArray[Std.int(idx)]);
            dooberById.add(Doobers[Std.int(idx)].Id,Doobers[Std.int(idx)]);
            dooberByConstant.add(Doobers[Std.int(idx)].Constant,Doobers[Std.int(idx)]);
            if(Doobers[Std.int(idx)].ChestId > 0)
            {
               dooberByChestId.add(Doobers[Std.int(idx)].ChestId,Doobers[Std.int(idx)]);
            }
            idx = idx + 1;
         }
         dooberDropById = new Map();
         dooberDropByConstant = new Map();
         dooberDropArray = ASCompat.dynamicAs(mGameMasterJson.DooberDrop, Array);
         idx = 0;
         while(idx < dooberDropArray.length)
         {
            DooberDrops[Std.int(idx)] = new GMDooberDrop(dooberDropArray[Std.int(idx)]);
            dooberDropById.add(DooberDrops[Std.int(idx)].Id,DooberDrops[Std.int(idx)]);
            dooberDropByConstant.add(DooberDrops[Std.int(idx)].Constant,DooberDrops[Std.int(idx)]);
            idx = idx + 1;
         }
         mapNodeById = new Map();
         mapNodeByConstant = new Map();
         mapNodeByBitIndex = new Map();
         mapNodeArray = ASCompat.dynamicAs(mGameMasterJson.MapPage, Array);
         idx = 0;
         while(idx < mapNodeArray.length)
         {
            MapNodes[Std.int(idx)] = new GMMapNode(mapNodeArray[Std.int(idx)]);
            mapNodeById.add(MapNodes[Std.int(idx)].Id,MapNodes[Std.int(idx)]);
            mapNodeByConstant.add(MapNodes[Std.int(idx)].Constant,MapNodes[Std.int(idx)]);
            mapNodeByBitIndex.add(MapNodes[Std.int(idx)].BitIndex,MapNodes[Std.int(idx)]);
            idx = idx + 1;
         }
         addChildrenToParentNodes();
         fixupMapNodeParents();
         infiniteDungeonsById = new Map();
         infiniteDungeonsByConstant = new Map();
         infiniteDungeonArray = ASCompat.dynamicAs(mGameMasterJson.InfiniteDungeons, Array);
         idx = 0;
         while(idx < infiniteDungeonArray.length)
         {
            gmInfiniteDungeon = new GMInfiniteDungeon(infiniteDungeonArray[Std.int(idx)]);
            infiniteDungeonsById.add(gmInfiniteDungeon.Id,gmInfiniteDungeon);
            infiniteDungeonsByConstant.add(gmInfiniteDungeon.Constant,gmInfiniteDungeon);
            idx = idx + 1;
         }
         dungeonModifierById = new Map();
         dungeonModifierByConstant = new Map();
         dungeonModifierArray = ASCompat.dynamicAs(mGameMasterJson.DungeonModifier, Array);
         idx = 0;
         while(idx < dungeonModifierArray.length)
         {
            DungeonModifiers[Std.int(idx)] = new GMDungeonModifier(dungeonModifierArray[Std.int(idx)]);
            dungeonModifierById.add(DungeonModifiers[Std.int(idx)].Id,DungeonModifiers[Std.int(idx)]);
            dungeonModifierByConstant.add(DungeonModifiers[Std.int(idx)].Constant,DungeonModifiers[Std.int(idx)]);
            idx = idx + 1;
         }
         propById = new Map();
         propByConstant = new Map();
         PropArray = ASCompat.dynamicAs(mGameMasterJson.Prop, Array);
         idx = 0;
         while(idx < PropArray.length)
         {
            Props[Std.int(idx)] = new GMProp(PropArray[Std.int(idx)]);
            propById.add(Props[Std.int(idx)].Id,Props[Std.int(idx)]);
            propByConstant.add(Props[Std.int(idx)].Constant,Props[Std.int(idx)]);
            idx = idx + 1;
         }
         offerById = new Map();
         OfferArray = ASCompat.dynamicAs(mGameMasterJson.Offers, Array);
         idx = 0;
         while(idx < OfferArray.length)
         {
            offer = new GMOffer(OfferArray[Std.int(idx)],splitTests);
            if(this.shouldIncludeOffer(offer,splitTests))
            {
               Offers.push(offer);
               offerById.add(offer.Id,offer);
            }
            idx = idx + 1;
         }
         offerByStackableId = new Map();
         OfferDetailArray = ASCompat.dynamicAs(mGameMasterJson.OfferDetails, Array);
         idx = 0;
         while(idx < OfferDetailArray.length)
         {
            detail = new GMOfferDetail(OfferDetailArray[Std.int(idx)]);
            offer = ASCompat.dynamicAs(offerById.itemFor(detail.OfferId), gameMasterDictionary.GMOffer);
            if(offer != null)
            {
               offer.Details.push(detail);
            }
            if(detail.StackableId > 0)
            {
               offerByStackableId.add(detail.StackableId,offer);
            }
            idx = idx + 1;
         }
         chestsById = new Map();
         ChestsArray = ASCompat.dynamicAs(mGameMasterJson.Chests, Array);
         idx = 0;
         while(idx < ChestsArray.length)
         {
            chest = new GMChest(ChestsArray[Std.int(idx)]);
            Chests[Std.int(idx)] = chest;
            chestsById.add(chest.Id,chest);
            idx = idx + 1;
         }
         keysByOfferId = new Map();
         KeysArray = ASCompat.dynamicAs(mGameMasterJson.Keys, Array);
         idx = 0;
         while(idx < KeysArray.length)
         {
            key = new GMKey(KeysArray[Std.int(idx)]);
            Keys[Std.int(idx)] = key;
            keysByOfferId.add(key.OfferId,key);
            idx = idx + 1;
         }
         rarityById = new Map();
         rarityByConstant = new Map();
         RarityArray = ASCompat.dynamicAs(mGameMasterJson.Rarity, Array);
         idx = 0;
         while(idx < RarityArray.length)
         {
            rarity = new GMRarity(RarityArray[Std.int(idx)]);
            Rarity[Std.int(idx)] = rarity;
            rarityById.add(rarity.Id,rarity);
            rarityByConstant.add(rarity.Type,rarity);
            idx = idx + 1;
         }
         weaponAestheticByWeaponItemConstant = new Map();
         WeaponAestheticArray = ASCompat.dynamicAs(mGameMasterJson.WeaponAesthetics, Array);
         idx = 0;
         while(idx < WeaponAestheticArray.length)
         {
            weaponAesthetic = new GMWeaponAesthetic(WeaponAestheticArray[Std.int(idx)]);
            weaponAestheticVector = (weaponAestheticByWeaponItemConstant.itemFor(weaponAesthetic.WeaponItemConstant) : Vector<GMWeaponAesthetic>);
            if(weaponAestheticVector == null)
            {
               tempAestheticVector = new Vector<GMWeaponAesthetic>();
               tempAestheticVector.push(weaponAesthetic);
               weaponAestheticByWeaponItemConstant.add(weaponAesthetic.WeaponItemConstant,tempAestheticVector);
            }
            else
            {
               weaponAestheticVector.push(weaponAesthetic);
            }
            idx = idx + 1;
         }
         wantCoinAltOffers = true;
         wantCashRanger = true;
         final __ax4_iter_50 = Offers;
         if (checkNullIteratee(__ax4_iter_50)) for (_tmp_ in __ax4_iter_50)
         {
            gmOffer  = _tmp_;
            if(gmOffer.SaleTargetOfferId != 0)
            {
               fullPriceOffer = ASCompat.dynamicAs(offerById.itemFor(gmOffer.SaleTargetOfferId), gameMasterDictionary.GMOffer);
               if(fullPriceOffer == null)
               {
                  Logger.error("Invalid sale from offer: " + Std.string(gmOffer.Id) + " sale offer: " + Std.string(gmOffer.SaleTargetOfferId));
                  continue;
               }
               gmOffer.SaleTargetOffer = fullPriceOffer;
               if(fullPriceOffer.SaleOffers == null)
               {
                  fullPriceOffer.SaleOffers = new Vector<GMOffer>();
               }
               fullPriceOffer.SaleOffers.push(gmOffer);
            }
            if(gmOffer.CurrencyType == "PREMIUM" && gmOffer.CoinOfferId != 0)
            {
               coinOffer = ASCompat.dynamicAs(offerById.itemFor(gmOffer.CoinOfferId), gameMasterDictionary.GMOffer);
               if(coinOffer == null)
               {
                  Logger.error("Invalid coin offer: " + Std.string(gmOffer.Id) + " CoinOfferId: " + gmOffer.CoinOfferId);
               }
               if(coinOffer.CurrencyType != "BASIC")
               {
                  Logger.error("CoinOfferId must be BASIC_CURRENCY: " + gmOffer.CoinOfferId);
               }
               coinOffer.IsCoinAltOffer = true;
               if(wantCoinAltOffers || gmOffer.Tab == "KEY")
               {
                  gmOffer.CoinOffer = coinOffer;
               }
            }
         }
         stackableById = new Map();
         stackableByConstant = new Map();
         stackableArray = ASCompat.dynamicAs(mGameMasterJson.Stackables, Array);
         idx = 0;
         while(idx < stackableArray.length)
         {
            stackable = new GMStackable(stackableArray[Std.int(idx)]);
            Stackables[Std.int(idx)] = stackable;
            stackableById.add(stackable.Id,stackable);
            stackableByConstant.add(stackable.Constant,stackable);
            securityCatergoryCounter += Stackables[Std.int(idx)].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         idx = 0;
         while(idx < Offers.length)
         {
            offer = Offers[Std.int(idx)];
            if(offer.Details == null)
            {
               Logger.error("Offer: " + offer.Id + " has no offer item details.");
            }
            if(!offer.IsBundle && offer.Details.length > 1)
            {
               Logger.error("Offer: " + offer.Id + " is not a bundle but has multiple item details.");
            }
            idx = idx + 1;
         }
         cashDealById = new Map();
         cashDealArray = ASCompat.dynamicAs(mGameMasterJson.CashDeals, Array);
         idx = 0;
         while(idx < cashDealArray.length)
         {
            cashDeal = new GMCashDeal(cashDealArray[Std.int(idx)],splitTests);
            CashDeals[Std.int(idx)] = cashDeal;
            cashDealById.add(cashDeal.Id,cashDeal);
            idx = idx + 1;
         }
         sortOrder = getSplitTestString("CashDealSort","HighestFirst",splitTests);
         if(sortOrder == "HighestFirst")
         {
            ASCompat.ASVector.sort(CashDeals, function(param1:GMCashDeal, param2:GMCashDeal):Int
            {
               return Std.int(param2.Price - param1.Price);
            });
         }
         else
         {
            ASCompat.ASVector.sort(CashDeals, function(param1:GMCashDeal, param2:GMCashDeal):Int
            {
               return Std.int(param1.Price - param2.Price);
            });
         }
         feedPostsById = new Map();
         feedPostsByConstant = new Map();
         feedPostsArray = ASCompat.dynamicAs(mGameMasterJson.Feedposts, Array);
         idx = 0;
         while(idx < feedPostsArray.length)
         {
            feedPost = new GMFeedPosts(feedPostsArray[Std.int(idx)]);
            FeedPosts[Std.int(idx)] = feedPost;
            feedPostsById.add(feedPost.Id,feedPost);
            feedPostsByConstant.add(feedPost.Constant,feedPost);
            idx = idx + 1;
         }
         achievementsById = new Map();
         achievementsArray = ASCompat.dynamicAs(mGameMasterJson.Achievements, Array);
         idx = 0;
         while(idx < achievementsArray.length)
         {
            achievement = new GMAchievement(achievementsArray[Std.int(idx)]);
            Achievements[Std.int(idx)] = achievement;
            achievementsById.add(achievement.Id,achievement);
            idx = idx + 1;
         }
         hintsByConstant = new Map();
         hintsArray = ASCompat.dynamicAs(mGameMasterJson.Hints, Array);
         idx = 0;
         while(idx < hintsArray.length)
         {
            hint = new GMHints(hintsArray[Std.int(idx)]);
            Hints[Std.int(idx)] = hint;
            hintsByConstant.add(hint.Constant,hint);
            idx = idx + 1;
         }
         coliseumTierById = new Map();
         coliseumTierByConstant = new Map();
         coliseumTiersArray = ASCompat.dynamicAs(mGameMasterJson.ColiseumTiers, Array);
         idx = 0;
         while(idx < coliseumTiersArray.length)
         {
            tier = new GMColiseumTier(coliseumTiersArray[Std.int(idx)]);
            ColiseumTiers[Std.int(idx)] = tier;
            coliseumTierById.add(tier.Id,tier);
            coliseumTierByConstant.add(tier.Constant,tier);
            idx = idx + 1;
         }
         skinsById = new Map();
         mSkinsByConstant = new Map();
         skinsArray = ASCompat.dynamicAs(mGameMasterJson.Skins, Array);
         idx = 0;
         while(idx < skinsArray.length)
         {
            skin = new GMSkin(skinsArray[Std.int(idx)]);
            Skins[Std.int(idx)] = skin;
            skinsById.add(skin.Id,skin);
            mSkinsByConstant.add(skin.Constant,skin);
            idx = idx + 1;
         }
         ASCompat.ASVector.sort(Skins, function(param1:GMSkin, param2:GMSkin):Int
         {
            var _loc5_= 0;
            var _loc4_:GMOffer = null;
            var _loc3_:GMOffer = null;
            _loc5_ = 0;
            while(_loc5_ < Offers.length)
            {
               offer = Offers[_loc5_];
               if(offer.Tab == "SKIN" && offer.Location == "STORE" && !offer.IsBundle && offer.SaleTargetOffer == null && !offer.IsCoinAltOffer)
               {
                  if(offer.Details[0].SkinId == param1.Id)
                  {
                     _loc4_ = offer;
                  }
                  else if(offer.Details[0].SkinId == param2.Id)
                  {
                     _loc3_ = offer;
                  }
                  if(_loc4_ != null && _loc3_ != null)
                  {
                     break;
                  }
               }
               _loc5_++;
            }
            if(_loc4_ != null && _loc3_ != null)
            {
               return Std.int(_loc3_.Price - _loc4_.Price);
            }
            if(_loc4_ != null)
            {
               return 1;
            }
            if(_loc3_ != null)
            {
               return -1;
            }
            return 0;
         });
         mDefaultSkins = new Map();
         idx = 0;
         while(idx < heroArray.length)
         {
            defaultGmSkin = ASCompat.dynamicAs(mSkinsByConstant.itemFor(Heroes[Std.int(idx)].DefaultSkin), gameMasterDictionary.GMSkin);
            mDefaultSkins.add(defaultGmSkin.Id,defaultGmSkin);
            idx = idx + 1;
         }
         playerScales = ASCompat.dynamicAs(mGameMasterJson.PlayerScale, Array);
         idx = 0;
         while(idx < playerScales.length)
         {
            new GMPlayerScale(playerScales[Std.int(idx)]);
            idx = idx + 1;
         }
         triggerToTriggerable = new Map();
         TriggerableIdToTriggerableEvent = new Map();
      }
      
      function shouldIncludeOffer(param1:GMOffer, param2:ASObject) : Bool
      {
         var _loc3_:Float = 0;
         if(param1.VisibleDate != null)
         {
            _loc3_ = param1.VisibleDate.getTime();
         }
         else if(param1.StartDate != null)
         {
            _loc3_ = param1.StartDate.getTime();
         }
         var _loc5_:Float = 0;
         if(param1.SoldOutDate != null)
         {
            _loc5_ = param1.SoldOutDate.getTime();
         }
         else if(param1.EndDate != null)
         {
            _loc5_ = param1.EndDate.getTime();
         }
         var _loc4_= GameClock.getWebServerTime();
         if(_loc4_ == 0)
         {
            _loc4_ = GameClock.date.getTime();
         }
         if(_loc3_ > 0)
         {
            if(_loc3_ > _loc4_)
            {
               return false;
            }
            if(_loc5_ > 0 && _loc5_ < _loc4_)
            {
               return false;
            }
         }
         else if(_loc5_ > 0 && _loc5_ < _loc4_)
         {
            return false;
         }
         return true;
      }
      
      public function storeHasSaleNow() : Bool
      {
         var _loc1_:GMOffer = null;
         var _loc2_:GMOffer;
         final __ax4_iter_51 = Offers;
         if (checkNullIteratee(__ax4_iter_51)) for (_tmp_ in __ax4_iter_51)
         {
            _loc2_ = _tmp_;
            _loc1_ = ASCompat.dynamicAs(_loc2_.isOnSaleNow, gameMasterDictionary.GMOffer);
            if(_loc1_ != null && _loc1_.isSale)
            {
               return true;
            }
         }
         return false;
      }
      
      public function storeHasNewOffers() : Bool
      {
         var _loc1_:GMOffer;
         final __ax4_iter_52 = Offers;
         if (checkNullIteratee(__ax4_iter_52)) for (_tmp_ in __ax4_iter_52)
         {
            _loc1_ = _tmp_;
            if(ASCompat.toBool(_loc1_.isNew))
            {
               return true;
            }
         }
         return false;
      }
      
      function addChildrenToParentNodes() 
      {
         var _loc2_:GMMapNode = null;
         var _loc1_:GMMapNode;
         final __ax4_iter_53 = MapNodes;
         if (checkNullIteratee(__ax4_iter_53)) for (_tmp_ in __ax4_iter_53)
         {
            _loc1_ = _tmp_;
            if(ASCompat.toBool(_loc1_.PrefixupParentNode))
            {
               _loc2_ = ASCompat.dynamicAs(mapNodeByConstant.itemFor(_loc1_.PrefixupParentNode), gameMasterDictionary.GMMapNode);
               _loc2_.ChildNodes.push(_loc1_.Constant);
            }
         }
      }
      
      function fixupMapNodeParents() 
      {
         var _loc1_= 0;
         var _loc2_= 0;
         var _loc3_:GMMapNode = null;
         _loc1_ = 0;
         while(_loc1_ < MapNodes.length)
         {
            _loc2_ = 0;
            while(_loc2_ < MapNodes[_loc1_].ChildNodes.length)
            {
               _loc3_ = ASCompat.dynamicAs(mapNodeByConstant.itemFor(MapNodes[_loc1_].ChildNodes[_loc2_]), gameMasterDictionary.GMMapNode);
               if(_loc3_ != null)
               {
                  _loc3_.ParentNodes.push(MapNodes[_loc1_]);
                  MapNodes[_loc1_].ChildNodes[_loc2_] = _loc3_;
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function getSkinByType(param1:UInt) : GMSkin
      {
         var _loc2_= ASCompat.dynamicAs(skinsById.itemFor(param1), gameMasterDictionary.GMSkin);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinType: " + param1);
         }
         return _loc2_;
      }
      
      public function getSkinByConstant(param1:String) : GMSkin
      {
         var _loc2_= ASCompat.dynamicAs(mSkinsByConstant.itemFor(param1), gameMasterDictionary.GMSkin);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinConstant: " + param1);
         }
         return _loc2_;
      }
      
      public function isSkinTypeADefaultSkin(param1:UInt) : Bool
      {
         return mDefaultSkins.hasKey(param1);
      }
      
      public function getHeroByConstant(param1:String) : GMHero
      {
         var _loc2_= ASCompat.dynamicAs(heroByConstant.itemFor(param1), gameMasterDictionary.GMHero);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMHero for constant: " + param1);
         }
         return _loc2_;
      }
      
      public function getMapNode(param1:UInt) : GMMapNode
      {
         return ASCompat.dynamicAs(mapNodeById.itemFor(param1), gameMasterDictionary.GMMapNode);
      }
      
      public function getStackableByConstant(param1:String) : GMSkin
      {
         var _loc2_= ASCompat.dynamicAs(mSkinsByConstant.itemFor(param1), gameMasterDictionary.GMSkin);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinConstant: " + param1);
         }
         return _loc2_;
      }
   }


