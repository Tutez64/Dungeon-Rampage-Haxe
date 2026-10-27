package gameMasterDictionary;

import brain.clock.GameClock;
import brain.logger.Logger;
import dBGlobals.DBGlobal;
import org.as3commons.collections.Map;

class GameMaster {
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

	public function new(gameMasterJson:ASObject, splitTests:ASObject) {
		mGameMasterJson = gameMasterJson;
		try {
			buildDictionary(splitTests);
		} catch (e:Dynamic) {
			Logger.fatal("Failed to process DB_GameMaster.json\n" + Std.string(e.message), e);
		}
		PostProcess(splitTests);
	}

	public static function getSplitTestString(key:String, defaultValue:String, tests:ASObject):String {
		var _loc4_:ASObject;
		if (checkNullIteratee(tests))
			for (_tmp_ in iterateDynamicValues(tests)) {
				_loc4_ = _tmp_;
				if (_loc4_.name == key) {
					return _loc4_.value;
				}
			}
		return defaultValue;
	}

	public function init() {}

	public function destroy() {}

	@:isVar public var securityChecksum(get, never):Int;

	public function get_securityChecksum():Int {
		return mSecurityValue;
	}

	public function getActorMap(type:UInt):Map {
		if (heroById.hasKey(type)) {
			return heroById;
		}
		if (npcById.hasKey(type)) {
			return npcById;
		}
		Logger.warn("ID: " + Std.string(type) + " not found in hero or npc map. Returning null");
		return null;
	}

	public function PostProcessWeaponItem() {
		var _loc2_ = 0;
		var _loc1_:GMWeaponItem = null;
		_loc2_ = 0;
		while (_loc2_ < WeaponItems.length) {
			_loc1_ = WeaponItems[_loc2_];
			_loc1_.WeaponAestheticList = (weaponAestheticByWeaponItemConstant.itemFor(_loc1_.Constant) : Vector<GMWeaponAesthetic>);
			if (_loc1_.WeaponAestheticList == null) {
				Logger.error(_loc1_.Constant + " doesn\'t have an aesthetic");
			}
			_loc2_++;
		}
	}

	public function PostProcess(slpittests:ASObject) {
		var _loc3_ = 0;
		var _loc2_:GMStat = null;
		PostProcessWeaponItem();
		stat_bias = new StatVector();
		stat_BonusMultiplier = new StatVector();
		stat_MaxCap = new StatVector();
		_loc3_ = 0;
		while (_loc3_ < DBGlobal.StatNames.length) {
			_loc2_ = ASCompat.coerce(statByConstant.itemFor(DBGlobal.StatNames[_loc3_]), gameMasterDictionary.GMStat);
			if (_loc2_ != null) {
				stat_BonusMultiplier.values[_loc3_] = _loc2_.Bonus;
				stat_MaxCap.values[_loc3_] = _loc2_.MaxCap;
			}
			_loc3_++;
		}
		stat_bias.values[8] = 1;
		stat_bias.values[9] = 1;
		stat_bias.values[10] = 1;
		stat_bias.values[13] = 1;
	}

	public function buildDictionary(splitTests:ASObject) {
		var __ax4_iter_49:Vector<GMModifier>;
		var __ax4_iter_50:Vector<GMLegendaryModifier>;
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
		mSecurityValue = 0;
		var securityCatergoryCounter = 0;
		statById = new Map();
		statByConstant = new Map();
		var statArray:Array<ASAny> = ASCompat.coerce(mGameMasterJson.Stats, Array);
		var idx:Float = 0;
		while (idx < statArray.length) {
			Stats[ASCompat.floatToInt(idx)] = new GMStat(statArray[ASCompat.floatToInt(idx)]);
			statById.add(Stats[ASCompat.floatToInt(idx)].Id, Stats[ASCompat.floatToInt(idx)]);
			statByConstant.add(Stats[ASCompat.floatToInt(idx)].Constant, Stats[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		superStatById = new Map();
		superStatByConstant = new Map();
		superStatArray = ASCompat.coerce(mGameMasterJson.SuperStats, Array);
		idx = 0;
		while (idx < superStatArray.length) {
			SuperStats[ASCompat.floatToInt(idx)] = new GMSuperStat(superStatArray[ASCompat.floatToInt(idx)]);
			superStatById.add(SuperStats[ASCompat.floatToInt(idx)].Id, SuperStats[ASCompat.floatToInt(idx)]);
			superStatByConstant.add(SuperStats[ASCompat.floatToInt(idx)].Constant, SuperStats[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		heroById = new Map();
		heroByConstant = new Map();
		heroArray = ASCompat.coerce(mGameMasterJson.Hero, Array);
		levelingArray = ASCompat.coerce(mGameMasterJson.Leveling, Array);
		idx = 0;
		while (idx < heroArray.length) {
			Heroes[ASCompat.floatToInt(idx)] = new GMHero(heroArray[ASCompat.floatToInt(idx)], splitTests);
			TotalExperience = 0;
			TotalStats = 0;
			lidx = 0;
			while (lidx < levelingArray.length) {
				levelId = ASCompat.toNumber(levelingArray[ASCompat.floatToInt(lidx)].Level);
				levelValue = ASCompat.toNumber(levelingArray[ASCompat.floatToInt(lidx)][Heroes[ASCompat.floatToInt(idx)].Constant]);
				statValue = ASCompat.toNumber(levelingArray[ASCompat.floatToInt(lidx)].StatPoints);
				if (levelValue != 0) {
					TotalExperience += levelValue;
					TotalStats += statValue;
					Heroes[ASCompat.floatToInt(idx)].LoadingOnly_addExpRecord((ASCompat.floatToInt(levelId) : UInt),
						(ASCompat.floatToInt(TotalExperience - 1) : UInt), (ASCompat.floatToInt(TotalStats) : UInt));
				}
				lidx = lidx + 1;
			}
			heroById.add(Heroes[ASCompat.floatToInt(idx)].Id, Heroes[ASCompat.floatToInt(idx)]);
			heroByConstant.add(Heroes[ASCompat.floatToInt(idx)].Constant, Heroes[ASCompat.floatToInt(idx)]);
			Heroes[ASCompat.floatToInt(idx)].HeroSlotHelper(Heroes[ASCompat.floatToInt(idx)].StatUpgrade1, 0, Heroes[ASCompat.floatToInt(idx)].AmtStat1, this);
			Heroes[ASCompat.floatToInt(idx)].HeroSlotHelper(Heroes[ASCompat.floatToInt(idx)].StatUpgrade2, 1, Heroes[ASCompat.floatToInt(idx)].AmtStat2, this);
			Heroes[ASCompat.floatToInt(idx)].HeroSlotHelper(Heroes[ASCompat.floatToInt(idx)].StatUpgrade3, 2, Heroes[ASCompat.floatToInt(idx)].AmtStat3, this);
			Heroes[ASCompat.floatToInt(idx)].HeroSlotHelper(Heroes[ASCompat.floatToInt(idx)].StatUpgrade4, 3, Heroes[ASCompat.floatToInt(idx)].AmtStat4, this);
			securityCatergoryCounter += Heroes[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		npcById = new Map();
		npcByConstant = new Map();
		npcArray = ASCompat.coerce(mGameMasterJson.Npc, Array);
		idx = 0;
		while (idx < npcArray.length) {
			Npcs[ASCompat.floatToInt(idx)] = new GMNpc(npcArray[ASCompat.floatToInt(idx)]);
			npcById.add(Npcs[ASCompat.floatToInt(idx)].Id, Npcs[ASCompat.floatToInt(idx)]);
			npcByConstant.add(Npcs[ASCompat.floatToInt(idx)].Constant, Npcs[ASCompat.floatToInt(idx)]);
			securityCatergoryCounter += Npcs[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		attackById = new Map();
		attackByConstant = new Map();
		attackArray = ASCompat.coerce(mGameMasterJson.Attack, Array);
		idx = 0;
		while (idx < attackArray.length) {
			Attacks[ASCompat.floatToInt(idx)] = new GMAttack(attackArray[ASCompat.floatToInt(idx)]);
			attackById.add(Attacks[ASCompat.floatToInt(idx)].Id, Attacks[ASCompat.floatToInt(idx)]);
			attackByConstant.add(Attacks[ASCompat.floatToInt(idx)].Constant, Attacks[ASCompat.floatToInt(idx)]);
			securityCatergoryCounter += Attacks[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		projectileById = new Map();
		projectileByConstant = new Map();
		projectileArray = ASCompat.coerce(mGameMasterJson.Projectile, Array);
		idx = 0;
		while (idx < projectileArray.length) {
			Projectiles[ASCompat.floatToInt(idx)] = new GMProjectile(projectileArray[ASCompat.floatToInt(idx)]);
			projectileById.add(Projectiles[ASCompat.floatToInt(idx)].Id, Projectiles[ASCompat.floatToInt(idx)]);
			projectileByConstant.add(Projectiles[ASCompat.floatToInt(idx)].Constant, Projectiles[ASCompat.floatToInt(idx)]);
			securityCatergoryCounter += Projectiles[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		buffById = new Map();
		buffByConstant = new Map();
		buffArray = ASCompat.coerce(mGameMasterJson.Buff, Array);
		idx = 0;
		while (idx < buffArray.length) {
			Buffs[ASCompat.floatToInt(idx)] = new GMBuff(buffArray[ASCompat.floatToInt(idx)]);
			buffById.add(Buffs[ASCompat.floatToInt(idx)].Id, Buffs[ASCompat.floatToInt(idx)]);
			buffByConstant.add(Buffs[ASCompat.floatToInt(idx)].Constant, Buffs[ASCompat.floatToInt(idx)]);
			securityCatergoryCounter += Buffs[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		buffColorTypeById = new Map();
		buffColorTypeArray = ASCompat.coerce(mGameMasterJson.BuffColorType, Array);
		idx = 0;
		while (idx < buffColorTypeArray.length) {
			gmBuffColorType = new GMBuffColorType(buffColorTypeArray[ASCompat.floatToInt(idx)]);
			buffColorTypeById.add(gmBuffColorType.Id, gmBuffColorType);
			idx = idx + 1;
		}
		auraById = new Map();
		auraByConstant = new Map();
		auraArray = ASCompat.coerce(mGameMasterJson.Auras, Array);
		idx = 0;
		while (idx < auraArray.length) {
			Auras[ASCompat.floatToInt(idx)] = new GMAura(auraArray[ASCompat.floatToInt(idx)]);
			auraById.add(Auras[ASCompat.floatToInt(idx)].Id, Auras[ASCompat.floatToInt(idx)]);
			auraByConstant.add(Auras[ASCompat.floatToInt(idx)].Constant, Auras[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		modifiersById = new Map();
		modifiersByConstant = new Map();
		ModifiersArray = ASCompat.coerce(mGameMasterJson.Modifiers, Array);
		idx = 0;
		while (idx < ModifiersArray.length) {
			modifier = new GMModifier(ModifiersArray[ASCompat.floatToInt(idx)]);
			Modifiers[ASCompat.floatToInt(idx)] = modifier;
			modifiersById.add(modifier.Id, modifier);
			modifiersByConstant.add(modifier.Constant, modifier);
			idx = idx + 1;
		}
		legendaryModifiersById = new Map();
		legendaryModifiersByConstant = new Map();
		LegendaryModifiersArray = ASCompat.coerce(mGameMasterJson.LegendaryModifiers, Array);
		idx = 0;
		while (idx < LegendaryModifiersArray.length) {
			legendaryModifier = new GMLegendaryModifier(LegendaryModifiersArray[ASCompat.floatToInt(idx)]);
			LegendaryModifiers[ASCompat.floatToInt(idx)] = legendaryModifier;
			legendaryModifiersById.add(legendaryModifier.Id, legendaryModifier);
			legendaryModifiersByConstant.add(legendaryModifier.Constant, legendaryModifier);
			idx = idx + 1;
		}
		weaponItemById = new Map();
		weaponItemByConstant = new Map();
		weaponItemArray = ASCompat.coerce(mGameMasterJson.WeaponItem, Array);
		idx = 0;
		while (idx < weaponItemArray.length) {
			gmWeapon = new GMWeaponItem(weaponItemArray[ASCompat.floatToInt(idx)]);
			WeaponItems[ASCompat.floatToInt(idx)] = gmWeapon;
			weaponItemById.add(gmWeapon.Id, gmWeapon);
			weaponItemByConstant.add(gmWeapon.Constant, gmWeapon);
			__ax4_iter_49 = Modifiers;
			if (checkNullIteratee(__ax4_iter_49))
				for (_tmp_ in __ax4_iter_49) {
					gmMod = _tmp_;
					if (ASCompat.toBool(weaponItemArray[ASCompat.floatToInt(idx)][gmMod.MODIFIER_TYPE])) {
						gmWeapon.PotentialModifiers.push(gmMod);
					}
				}
			__ax4_iter_50 = LegendaryModifiers;
			if (checkNullIteratee(__ax4_iter_50))
				for (_tmp_ in __ax4_iter_50) {
					gmLegendaryMod = _tmp_;
					gmWeapon.PotentialLegendaryModifiers.push(gmLegendaryMod);
				}
			idx = idx + 1;
		}
		weaponSubtypeById = new Map();
		weaponSubtypeByConstant = new Map();
		weaponSubtypesSortedByID = [];
		weaponMastertypeArray = ASCompat.coerce(mGameMasterJson.WeaponMastertype, Array);
		idx = 0;
		while (idx < weaponMastertypeArray.length) {
			WeaponMastertypes[ASCompat.floatToInt(idx)] = new GMWeaponMastertype(weaponMastertypeArray[ASCompat.floatToInt(idx)]);
			weaponSubtypeById.add(WeaponMastertypes[ASCompat.floatToInt(idx)].Id, WeaponMastertypes[ASCompat.floatToInt(idx)]);
			weaponSubtypeByConstant.add(WeaponMastertypes[ASCompat.floatToInt(idx)].Constant, WeaponMastertypes[ASCompat.floatToInt(idx)]);
			weaponSubtypesSortedByID.push(WeaponMastertypes[ASCompat.floatToInt(idx)].Id);
			idx = idx + 1;
		}
		weaponSubtypesSortedByID.sort(Reflect.compare);
		dooberById = new Map();
		dooberByConstant = new Map();
		dooberByChestId = new Map();
		dooberArray = ASCompat.coerce(mGameMasterJson.Doobers, Array);
		idx = 0;
		while (idx < dooberArray.length) {
			Doobers[ASCompat.floatToInt(idx)] = new GMDoober(dooberArray[ASCompat.floatToInt(idx)]);
			dooberById.add(Doobers[ASCompat.floatToInt(idx)].Id, Doobers[ASCompat.floatToInt(idx)]);
			dooberByConstant.add(Doobers[ASCompat.floatToInt(idx)].Constant, Doobers[ASCompat.floatToInt(idx)]);
			if (Doobers[ASCompat.floatToInt(idx)].ChestId > 0) {
				dooberByChestId.add(Doobers[ASCompat.floatToInt(idx)].ChestId, Doobers[ASCompat.floatToInt(idx)]);
			}
			idx = idx + 1;
		}
		dooberDropById = new Map();
		dooberDropByConstant = new Map();
		dooberDropArray = ASCompat.coerce(mGameMasterJson.DooberDrop, Array);
		idx = 0;
		while (idx < dooberDropArray.length) {
			DooberDrops[ASCompat.floatToInt(idx)] = new GMDooberDrop(dooberDropArray[ASCompat.floatToInt(idx)]);
			dooberDropById.add(DooberDrops[ASCompat.floatToInt(idx)].Id, DooberDrops[ASCompat.floatToInt(idx)]);
			dooberDropByConstant.add(DooberDrops[ASCompat.floatToInt(idx)].Constant, DooberDrops[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		mapNodeById = new Map();
		mapNodeByConstant = new Map();
		mapNodeByBitIndex = new Map();
		mapNodeArray = ASCompat.coerce(mGameMasterJson.MapPage, Array);
		idx = 0;
		while (idx < mapNodeArray.length) {
			MapNodes[ASCompat.floatToInt(idx)] = new GMMapNode(mapNodeArray[ASCompat.floatToInt(idx)]);
			mapNodeById.add(MapNodes[ASCompat.floatToInt(idx)].Id, MapNodes[ASCompat.floatToInt(idx)]);
			mapNodeByConstant.add(MapNodes[ASCompat.floatToInt(idx)].Constant, MapNodes[ASCompat.floatToInt(idx)]);
			mapNodeByBitIndex.add(MapNodes[ASCompat.floatToInt(idx)].BitIndex, MapNodes[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		addChildrenToParentNodes();
		fixupMapNodeParents();
		infiniteDungeonsById = new Map();
		infiniteDungeonsByConstant = new Map();
		infiniteDungeonArray = ASCompat.coerce(mGameMasterJson.InfiniteDungeons, Array);
		idx = 0;
		while (idx < infiniteDungeonArray.length) {
			gmInfiniteDungeon = new GMInfiniteDungeon(infiniteDungeonArray[ASCompat.floatToInt(idx)]);
			infiniteDungeonsById.add(gmInfiniteDungeon.Id, gmInfiniteDungeon);
			infiniteDungeonsByConstant.add(gmInfiniteDungeon.Constant, gmInfiniteDungeon);
			idx = idx + 1;
		}
		dungeonModifierById = new Map();
		dungeonModifierByConstant = new Map();
		dungeonModifierArray = ASCompat.coerce(mGameMasterJson.DungeonModifier, Array);
		idx = 0;
		while (idx < dungeonModifierArray.length) {
			DungeonModifiers[ASCompat.floatToInt(idx)] = new GMDungeonModifier(dungeonModifierArray[ASCompat.floatToInt(idx)]);
			dungeonModifierById.add(DungeonModifiers[ASCompat.floatToInt(idx)].Id, DungeonModifiers[ASCompat.floatToInt(idx)]);
			dungeonModifierByConstant.add(DungeonModifiers[ASCompat.floatToInt(idx)].Constant, DungeonModifiers[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		propById = new Map();
		propByConstant = new Map();
		PropArray = ASCompat.coerce(mGameMasterJson.Prop, Array);
		idx = 0;
		while (idx < PropArray.length) {
			Props[ASCompat.floatToInt(idx)] = new GMProp(PropArray[ASCompat.floatToInt(idx)]);
			propById.add(Props[ASCompat.floatToInt(idx)].Id, Props[ASCompat.floatToInt(idx)]);
			propByConstant.add(Props[ASCompat.floatToInt(idx)].Constant, Props[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		offerById = new Map();
		OfferArray = ASCompat.coerce(mGameMasterJson.Offers, Array);
		idx = 0;
		while (idx < OfferArray.length) {
			offer = new GMOffer(OfferArray[ASCompat.floatToInt(idx)], splitTests);
			if (this.shouldIncludeOffer(offer, splitTests)) {
				Offers.push(offer);
				offerById.add(offer.Id, offer);
			}
			idx = idx + 1;
		}
		offerByStackableId = new Map();
		OfferDetailArray = ASCompat.coerce(mGameMasterJson.OfferDetails, Array);
		idx = 0;
		while (idx < OfferDetailArray.length) {
			detail = new GMOfferDetail(OfferDetailArray[ASCompat.floatToInt(idx)]);
			offer = ASCompat.coerce(offerById.itemFor(detail.OfferId), gameMasterDictionary.GMOffer);
			if (offer != null) {
				offer.Details.push(detail);
			}
			if (detail.StackableId > 0) {
				offerByStackableId.add(detail.StackableId, offer);
			}
			idx = idx + 1;
		}
		chestsById = new Map();
		ChestsArray = ASCompat.coerce(mGameMasterJson.Chests, Array);
		idx = 0;
		while (idx < ChestsArray.length) {
			chest = new GMChest(ChestsArray[ASCompat.floatToInt(idx)]);
			Chests[ASCompat.floatToInt(idx)] = chest;
			chestsById.add(chest.Id, chest);
			idx = idx + 1;
		}
		keysByOfferId = new Map();
		KeysArray = ASCompat.coerce(mGameMasterJson.Keys, Array);
		idx = 0;
		while (idx < KeysArray.length) {
			key = new GMKey(KeysArray[ASCompat.floatToInt(idx)]);
			Keys[ASCompat.floatToInt(idx)] = key;
			keysByOfferId.add(key.OfferId, key);
			idx = idx + 1;
		}
		rarityById = new Map();
		rarityByConstant = new Map();
		RarityArray = ASCompat.coerce(mGameMasterJson.Rarity, Array);
		idx = 0;
		while (idx < RarityArray.length) {
			rarity = new GMRarity(RarityArray[ASCompat.floatToInt(idx)]);
			Rarity[ASCompat.floatToInt(idx)] = rarity;
			rarityById.add(rarity.Id, rarity);
			rarityByConstant.add(rarity.Type, rarity);
			idx = idx + 1;
		}
		weaponAestheticByWeaponItemConstant = new Map();
		WeaponAestheticArray = ASCompat.coerce(mGameMasterJson.WeaponAesthetics, Array);
		idx = 0;
		while (idx < WeaponAestheticArray.length) {
			weaponAesthetic = new GMWeaponAesthetic(WeaponAestheticArray[ASCompat.floatToInt(idx)]);
			weaponAestheticVector = (weaponAestheticByWeaponItemConstant.itemFor(weaponAesthetic.WeaponItemConstant) : Vector<GMWeaponAesthetic>);
			if (weaponAestheticVector == null) {
				tempAestheticVector = new Vector<GMWeaponAesthetic>();
				tempAestheticVector.push(weaponAesthetic);
				weaponAestheticByWeaponItemConstant.add(weaponAesthetic.WeaponItemConstant, tempAestheticVector);
			} else {
				weaponAestheticVector.push(weaponAesthetic);
			}
			idx = idx + 1;
		}
		wantCoinAltOffers = true;
		wantCashRanger = true;
		final __ax4_iter_51 = Offers;
		if (checkNullIteratee(__ax4_iter_51))
			for (_tmp_ in __ax4_iter_51) {
				gmOffer = _tmp_;
				if (gmOffer.SaleTargetOfferId != 0) {
					fullPriceOffer = ASCompat.coerce(offerById.itemFor(gmOffer.SaleTargetOfferId), gameMasterDictionary.GMOffer);
					if (fullPriceOffer == null) {
						Logger.error("Invalid sale from offer: " + Std.string(gmOffer.Id) + " sale offer: " + Std.string(gmOffer.SaleTargetOfferId));
						continue;
					}
					gmOffer.SaleTargetOffer = fullPriceOffer;
					if (fullPriceOffer.SaleOffers == null) {
						fullPriceOffer.SaleOffers = new Vector<GMOffer>();
					}
					fullPriceOffer.SaleOffers.push(gmOffer);
				}
				if (gmOffer.CurrencyType == "PREMIUM" && gmOffer.CoinOfferId != 0) {
					coinOffer = ASCompat.coerce(offerById.itemFor(gmOffer.CoinOfferId), gameMasterDictionary.GMOffer);
					if (coinOffer == null) {
						Logger.error("Invalid coin offer: " + Std.string(gmOffer.Id) + " CoinOfferId: " + gmOffer.CoinOfferId);
					}
					if (coinOffer.CurrencyType != "BASIC") {
						Logger.error("CoinOfferId must be BASIC_CURRENCY: " + gmOffer.CoinOfferId);
					}
					coinOffer.IsCoinAltOffer = true;
					if (wantCoinAltOffers || gmOffer.Tab == "KEY") {
						gmOffer.CoinOffer = coinOffer;
					}
				}
			}
		stackableById = new Map();
		stackableByConstant = new Map();
		stackableArray = ASCompat.coerce(mGameMasterJson.Stackables, Array);
		idx = 0;
		while (idx < stackableArray.length) {
			stackable = new GMStackable(stackableArray[ASCompat.floatToInt(idx)]);
			Stackables[ASCompat.floatToInt(idx)] = stackable;
			stackableById.add(stackable.Id, stackable);
			stackableByConstant.add(stackable.Constant, stackable);
			securityCatergoryCounter += Stackables[ASCompat.floatToInt(idx)].SecurityValue;
			idx = idx + 1;
		}
		securityCatergoryCounter %= 1097;
		mSecurityValue += securityCatergoryCounter;
		securityCatergoryCounter = 0;
		idx = 0;
		while (idx < Offers.length) {
			offer = Offers[ASCompat.floatToInt(idx)];
			if (offer.Details == null) {
				Logger.error("Offer: " + offer.Id + " has no offer item details.");
			}
			if (!offer.IsBundle && offer.Details.length > 1) {
				Logger.error("Offer: " + offer.Id + " is not a bundle but has multiple item details.");
			}
			idx = idx + 1;
		}
		cashDealById = new Map();
		cashDealArray = ASCompat.coerce(mGameMasterJson.CashDeals, Array);
		idx = 0;
		while (idx < cashDealArray.length) {
			cashDeal = new GMCashDeal(cashDealArray[ASCompat.floatToInt(idx)], splitTests);
			CashDeals[ASCompat.floatToInt(idx)] = cashDeal;
			cashDealById.add(cashDeal.Id, cashDeal);
			idx = idx + 1;
		}
		sortOrder = getSplitTestString("CashDealSort", "HighestFirst", splitTests);
		if (sortOrder == "HighestFirst") {
			ASCompat.ASVector.sort(CashDeals, function(param1:GMCashDeal, param2:GMCashDeal):Int {
				return ASCompat.floatToInt(param2.Price - param1.Price);
			});
		} else {
			ASCompat.ASVector.sort(CashDeals, function(param1:GMCashDeal, param2:GMCashDeal):Int {
				return ASCompat.floatToInt(param1.Price - param2.Price);
			});
		}
		feedPostsById = new Map();
		feedPostsByConstant = new Map();
		feedPostsArray = ASCompat.coerce(mGameMasterJson.Feedposts, Array);
		idx = 0;
		while (idx < feedPostsArray.length) {
			feedPost = new GMFeedPosts(feedPostsArray[ASCompat.floatToInt(idx)]);
			FeedPosts[ASCompat.floatToInt(idx)] = feedPost;
			feedPostsById.add(feedPost.Id, feedPost);
			feedPostsByConstant.add(feedPost.Constant, feedPost);
			idx = idx + 1;
		}
		achievementsById = new Map();
		achievementsArray = ASCompat.coerce(mGameMasterJson.Achievements, Array);
		idx = 0;
		while (idx < achievementsArray.length) {
			achievement = new GMAchievement(achievementsArray[ASCompat.floatToInt(idx)]);
			Achievements[ASCompat.floatToInt(idx)] = achievement;
			achievementsById.add(achievement.Id, achievement);
			idx = idx + 1;
		}
		hintsByConstant = new Map();
		hintsArray = ASCompat.coerce(mGameMasterJson.Hints, Array);
		idx = 0;
		while (idx < hintsArray.length) {
			hint = new GMHints(hintsArray[ASCompat.floatToInt(idx)]);
			Hints[ASCompat.floatToInt(idx)] = hint;
			hintsByConstant.add(hint.Constant, hint);
			idx = idx + 1;
		}
		coliseumTierById = new Map();
		coliseumTierByConstant = new Map();
		coliseumTiersArray = ASCompat.coerce(mGameMasterJson.ColiseumTiers, Array);
		idx = 0;
		while (idx < coliseumTiersArray.length) {
			tier = new GMColiseumTier(coliseumTiersArray[ASCompat.floatToInt(idx)]);
			ColiseumTiers[ASCompat.floatToInt(idx)] = tier;
			coliseumTierById.add(tier.Id, tier);
			coliseumTierByConstant.add(tier.Constant, tier);
			idx = idx + 1;
		}
		skinsById = new Map();
		mSkinsByConstant = new Map();
		skinsArray = ASCompat.coerce(mGameMasterJson.Skins, Array);
		idx = 0;
		while (idx < skinsArray.length) {
			skin = new GMSkin(skinsArray[ASCompat.floatToInt(idx)]);
			Skins[ASCompat.floatToInt(idx)] = skin;
			skinsById.add(skin.Id, skin);
			mSkinsByConstant.add(skin.Constant, skin);
			idx = idx + 1;
		}
		ASCompat.ASVector.sort(Skins, function(param1:GMSkin, param2:GMSkin):Int {
			var _loc5_ = 0;
			var _loc4_:GMOffer = null;
			var _loc3_:GMOffer = null;
			_loc5_ = 0;
			while (_loc5_ < Offers.length) {
				offer = Offers[_loc5_];
				if (offer.Tab == "SKIN" && offer.Location == "STORE" && !offer.IsBundle && offer.SaleTargetOffer == null && !offer.IsCoinAltOffer) {
					if (offer.Details[0].SkinId == param1.Id) {
						_loc4_ = offer;
					} else if (offer.Details[0].SkinId == param2.Id) {
						_loc3_ = offer;
					}
					if (_loc4_ != null && _loc3_ != null) {
						break;
					}
				}
				_loc5_++;
			}
			if (_loc4_ != null && _loc3_ != null) {
				return ASCompat.floatToInt(_loc3_.Price - _loc4_.Price);
			}
			if (_loc4_ != null) {
				return 1;
			}
			if (_loc3_ != null) {
				return -1;
			}
			return 0;
		});
		mDefaultSkins = new Map();
		idx = 0;
		while (idx < heroArray.length) {
			defaultGmSkin = ASCompat.coerce(mSkinsByConstant.itemFor(Heroes[ASCompat.floatToInt(idx)].DefaultSkin), gameMasterDictionary.GMSkin);
			mDefaultSkins.add(defaultGmSkin.Id, defaultGmSkin);
			idx = idx + 1;
		}
		playerScales = ASCompat.coerce(mGameMasterJson.PlayerScale, Array);
		idx = 0;
		while (idx < playerScales.length) {
			new GMPlayerScale(playerScales[ASCompat.floatToInt(idx)]);
			idx = idx + 1;
		}
		triggerToTriggerable = new Map();
		TriggerableIdToTriggerableEvent = new Map();
	}

	function shouldIncludeOffer(gmOffer:GMOffer, splitTests:ASObject):Bool {
		var _loc3_:Float = 0;
		if (gmOffer.VisibleDate != null) {
			_loc3_ = gmOffer.VisibleDate.getTime();
		} else if (gmOffer.StartDate != null) {
			_loc3_ = gmOffer.StartDate.getTime();
		}
		var _loc5_:Float = 0;
		if (gmOffer.SoldOutDate != null) {
			_loc5_ = gmOffer.SoldOutDate.getTime();
		} else if (gmOffer.EndDate != null) {
			_loc5_ = gmOffer.EndDate.getTime();
		}
		var _loc4_ = GameClock.getWebServerTime();
		if (_loc4_ == 0) {
			_loc4_ = GameClock.date.getTime();
		}
		if (_loc3_ > 0) {
			if (_loc3_ > _loc4_) {
				return false;
			}
			if (_loc5_ > 0 && _loc5_ < _loc4_) {
				return false;
			}
		} else if (_loc5_ > 0 && _loc5_ < _loc4_) {
			return false;
		}
		return true;
	}

	public function storeHasSaleNow():Bool {
		var _loc1_:GMOffer = null;
		var _loc2_:GMOffer;
		final __ax4_iter_52 = Offers;
		if (checkNullIteratee(__ax4_iter_52))
			for (_tmp_ in __ax4_iter_52) {
				_loc2_ = _tmp_;
				_loc1_ = _loc2_.isOnSaleNow;
				if (_loc1_ != null && _loc1_.isSale) {
					return true;
				}
			}
		return false;
	}

	public function storeHasNewOffers():Bool {
		var _loc1_:GMOffer;
		final __ax4_iter_53 = Offers;
		if (checkNullIteratee(__ax4_iter_53))
			for (_tmp_ in __ax4_iter_53) {
				_loc1_ = _tmp_;
				if (_loc1_.isNew) {
					return true;
				}
			}
		return false;
	}

	function addChildrenToParentNodes() {
		var _loc2_:GMMapNode = null;
		var _loc1_:GMMapNode;
		final __ax4_iter_54 = MapNodes;
		if (checkNullIteratee(__ax4_iter_54))
			for (_tmp_ in __ax4_iter_54) {
				_loc1_ = _tmp_;
				if (ASCompat.stringAsBool(_loc1_.PrefixupParentNode)) {
					_loc2_ = ASCompat.coerce(mapNodeByConstant.itemFor(_loc1_.PrefixupParentNode), gameMasterDictionary.GMMapNode);
					_loc2_.ChildNodes.push(_loc1_.Constant);
				}
			}
	}

	function fixupMapNodeParents() {
		var _loc1_ = 0;
		var _loc2_ = 0;
		var _loc3_:GMMapNode = null;
		_loc1_ = 0;
		while (_loc1_ < MapNodes.length) {
			_loc2_ = 0;
			while (_loc2_ < MapNodes[_loc1_].ChildNodes.length) {
				_loc3_ = ASCompat.coerce(mapNodeByConstant.itemFor(MapNodes[_loc1_].ChildNodes[_loc2_]), gameMasterDictionary.GMMapNode);
				if (_loc3_ != null) {
					_loc3_.ParentNodes.push(MapNodes[_loc1_]);
					MapNodes[_loc1_].ChildNodes[_loc2_] = _loc3_;
				}
				_loc2_++;
			}
			_loc1_++;
		}
	}

	public function getSkinByType(skinType:UInt):GMSkin {
		var _loc2_ = ASCompat.coerce(skinsById.itemFor(skinType), gameMasterDictionary.GMSkin);
		if (_loc2_ == null) {
			Logger.error("Unable to find GMSkin for skinType: " + skinType);
		}
		return _loc2_;
	}

	public function getSkinByConstant(skinConstant:String):GMSkin {
		var _loc2_ = ASCompat.coerce(mSkinsByConstant.itemFor(skinConstant), gameMasterDictionary.GMSkin);
		if (_loc2_ == null) {
			Logger.error("Unable to find GMSkin for skinConstant: " + skinConstant);
		}
		return _loc2_;
	}

	public function isSkinTypeADefaultSkin(skinType:UInt):Bool {
		return mDefaultSkins.hasKey(skinType);
	}

	public function getHeroByConstant(heroConstant:String):GMHero {
		var _loc2_ = ASCompat.coerce(heroByConstant.itemFor(heroConstant), gameMasterDictionary.GMHero);
		if (_loc2_ == null) {
			Logger.error("Unable to find GMHero for constant: " + heroConstant);
		}
		return _loc2_;
	}

	public function getMapNode(idx:UInt):GMMapNode {
		return ASCompat.coerce(mapNodeById.itemFor(idx), gameMasterDictionary.GMMapNode);
	}

	public function getStackableByConstant(skinConstant:String):GMSkin {
		var _loc2_ = ASCompat.coerce(mSkinsByConstant.itemFor(skinConstant), gameMasterDictionary.GMSkin);
		if (_loc2_ == null) {
			Logger.error("Unable to find GMSkin for skinConstant: " + skinConstant);
		}
		return _loc2_;
	}
}
