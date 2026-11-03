package facade;

import account.Consumable;
import account.ItemInfo;
import account.PetInfo;
import actor.ActorData;
import actor.ActorRenderer;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.logger.Logger;
import combat.weapon.WeaponRenderer;
import dBGlobals.DBGlobal;
import gameMasterDictionary.GMActor;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMProjectile;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.GMStackable;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import gameMasterDictionary.GameMaster;
import generatedCode.HeroPreloadLook;
import generatedCode.WeaponDetails;
import flash.filesystem.File;

class TrickleCacheLoader {
	static final STARLING_LIBRARY_SWFS:Vector<String> = Vector.ofArray([
		"Resources/Art2D/Doobers/db_items_doobers.swf",
		"Resources/Art2D/projectiles/db_projectiles_library.swf"
	]);

	static final STARLING_COMMON_SWFS:Vector<String> = Vector.ofArray([
		"Resources/Art2D/Environments/shared/props/db_prop_shared_library.swf",
		"Resources/Art2D/Doobers/db_items_doobers.swf",
		"Resources/Art2D/projectiles/db_projectiles_library.swf",
		"Resources/Art2D/FX/db_fx_library.swf"
	]);

	public function new() {}

	public static function queueHeroKitStarlingAtlases(dbFacade:DBFacade) {
		if (dbFacade.assetLoadingComponent == null) {
			return;
		}
		var _loc2_:String;
		final __ax4_iter_65 = starlingAtlasPaths(dbFacade, null);
		if (checkNullIteratee(__ax4_iter_65))
			for (_tmp_ in __ax4_iter_65) {
				_loc2_ = _tmp_;
				dbFacade.assetLoadingComponent.queueStarlingAssetsForPath(_loc2_);
			}
	}

	public static function queueHeroLookAtlases(dbFacade:DBFacade, look:HeroPreloadLook, isBackground:Bool) {
		var _loc8_:GMHero = null;
		var _loc13_:GMWeaponItem = null;
		var _loc20_ = false;
		var _loc4_:GMWeaponAesthetic = null;
		var _loc6_:GMStackable = null;
		var _loc23_:GMNpc = null;
		var _loc19_ = dbFacade.assetLoadingComponent;
		if (_loc19_ == null || look == null) {
			return;
		}
		var _loc17_ = dbFacade.gameMaster;
		var _loc11_ = _loc17_.getSkinByType(look.skinType);
		if (_loc11_ == null) {
			_loc8_ = ASCompat.coerce(_loc17_.heroById.itemFor(look.heroType), gameMasterDictionary.GMHero);
			_loc11_ = ASCompat.coerce(_loc8_ != null ? _loc17_.getSkinByConstant(_loc8_.DefaultSkin) : null, gameMasterDictionary.GMSkin);
		}
		var _loc21_ = new Vector<GMWeaponItem>();
		var _loc16_ = new Vector<String>();
		var _loc14_:WeaponDetails;
		final __ax4_iter_66 = look.weapons;
		if (checkNullIteratee(__ax4_iter_66))
			for (_tmp_ in __ax4_iter_66) {
				_loc14_ = _tmp_;
				_loc13_ = ASCompat.coerce(_loc14_.type != 0 ? ASCompat.coerce(_loc17_.weaponItemById.itemFor(_loc14_.type),
					gameMasterDictionary.GMWeaponItem) : null,
					gameMasterDictionary.GMWeaponItem);
				if (_loc13_ != null) {
					_loc20_ = _loc14_.legendarymodifier > 0 && _loc17_.legendaryModifiersById.itemFor(_loc14_.legendarymodifier) != null;
					_loc4_ = _loc13_.getWeaponAesthetic(_loc14_.requiredlevel, _loc20_);
					if (_loc4_ != null) {
						_loc21_.push(_loc13_);
						_loc16_.push(_loc4_.ModelName);
					}
				}
			}
		var _loc9_ = new Vector<GMStackable>();
		var _loc10_:UInt;
		final __ax4_iter_67 = look.consumableTypes;
		if (checkNullIteratee(__ax4_iter_67))
			for (_tmp_ in __ax4_iter_67) {
				_loc10_ = _tmp_;
				_loc6_ = ASCompat.coerce(_loc10_ != 0 ? ASCompat.coerce(_loc17_.stackableById.itemFor(_loc10_), gameMasterDictionary.GMStackable) : null,
					gameMasterDictionary.GMStackable);
				if (_loc6_ != null) {
					_loc9_.push(_loc6_);
				}
			}
		var _loc5_ = new Vector<GMNpc>();
		var _loc22_:UInt;
		final __ax4_iter_68 = look.petTypes;
		if (checkNullIteratee(__ax4_iter_68))
			for (_tmp_ in __ax4_iter_68) {
				_loc22_ = _tmp_;
				_loc23_ = ASCompat.coerce(_loc17_.npcById.itemFor(_loc22_), gameMasterDictionary.GMNpc);
				if (_loc23_ != null) {
					_loc5_.push(_loc23_);
				}
			}
		var _loc12_ = ASCompat.coerceFunction(dbFacade.timelineFactory != null ? dbFacade.timelineFactory.getTimelineJson : null);
		var _loc18_ = collectStarlingAtlasPaths(_loc17_, _loc12_, _loc11_, _loc21_, _loc16_, _loc9_, _loc5_, null);
		var _loc7_:ASObject = isBackground ? heroLookAtlasTiers(_loc17_, _loc12_, _loc11_, _loc21_, _loc16_, _loc9_, _loc5_) : {};
		var _loc15_:String;
		if (checkNullIteratee(_loc18_))
			for (_tmp_ in _loc18_) {
				_loc15_ = _tmp_;
				_loc19_.queueStarlingAssetsForPath(_loc15_, null, false, isBackground, _loc7_.hasOwnProperty(_loc15_) ? ASCompat.toInt(_loc7_[_loc15_]) : 2);
			}
	}

	public static function heroLookAtlasTiers(gameMaster:GameMaster, timelineJson:ASFunction, gmSkin:GMSkin, weapons:Vector<GMWeaponItem>,
			weaponModels:Vector<String>, consumables:Vector<GMStackable>, pets:Vector<GMNpc>):ASObject {
		var _loc9_:String;
		var _loc8_:String = null;
		var _loc12_:String = null;
		var _loc10_:ASObject = {};
		var _loc11_ = collectStarlingAtlasPaths(gameMaster, timelineJson, gmSkin, weapons, weaponModels, consumables, new Vector<GMNpc>(), null);
		final __ax4_iter_69 = collectStarlingAtlasPaths(gameMaster, timelineJson, null, new Vector<GMWeaponItem>(), new Vector<String>(),
			new Vector<GMStackable>(), pets, null);
		if (checkNullIteratee(__ax4_iter_69))
			for (_tmp_ in __ax4_iter_69) {
				_loc8_ = _tmp_;
				if (_loc11_.indexOf(_loc8_) == -1) {
					_loc10_[_loc8_] = 4;
				}
			}
		if (gmSkin != null && ASCompat.stringAsBool(gmSkin.SwfFilepath) && gmSkin.SwfFilepath != "null") {
			_loc12_ = DBFacade.buildFullDownloadPath(gmSkin.SwfFilepath);
			_loc10_[_loc12_] = 0;
			if (checkNullIteratee(weaponModels))
				for (_tmp_ in weaponModels) {
					_loc9_ = _tmp_;
					_loc10_[WeaponRenderer.weaponSwfFilePath(_loc12_, _loc9_)] = 1;
				}
		}
		return _loc10_;
	}

	public static function queueCommonStarlingAtlases(dbFacade:DBFacade) {
		if (dbFacade.assetLoadingComponent == null) {
			return;
		}
		var _loc2_:String;
		final __ax4_iter_70 = STARLING_COMMON_SWFS;
		if (checkNullIteratee(__ax4_iter_70))
			for (_tmp_ in __ax4_iter_70) {
				_loc2_ = _tmp_;
				dbFacade.assetLoadingComponent.queueResidentStarlingAssetsForPath(DBFacade.buildFullDownloadPath(_loc2_));
			}
	}

	public static function starlingAtlasPaths(dbFacade:DBFacade, cacheNpc:Vector<UInt>):Vector<String> {
		var _loc8_:GMWeaponAesthetic = null;
		var _loc4_:GMStackable = null;
		var _loc12_ = dbFacade.gameMaster;
		var _loc3_ = dbFacade.dbAccountInfo;
		var _loc10_ = _loc3_.activeAvatarInfo;
		var _loc15_ = new Vector<GMWeaponItem>();
		var _loc11_ = new Vector<String>();
		var _loc5_:ItemInfo;
		final __ax4_iter_71 = _loc3_.inventoryInfo.getEquipedItemsOnAvatar(_loc10_.id);
		if (checkNullIteratee(__ax4_iter_71))
			for (_tmp_ in __ax4_iter_71) {
				_loc5_ = _tmp_;
				_loc8_ = ASCompat.coerce(_loc5_.gmWeaponItem != null ? _loc5_.gmWeaponAesthetic : null, gameMasterDictionary.GMWeaponAesthetic);
				if (_loc8_ != null) {
					_loc15_.push(_loc5_.gmWeaponItem);
					_loc11_.push(_loc8_.ModelName);
				}
			}
		var _loc6_ = new Vector<GMStackable>();
		var _loc13_:Consumable;
		final __ax4_iter_72 = _loc10_.equippedConsumables;
		if (checkNullIteratee(__ax4_iter_72))
			for (_tmp_ in __ax4_iter_72) {
				_loc13_ = _tmp_;
				_loc4_ = ASCompat.coerce(_loc13_.stackId != 0 ? ASCompat.coerce(_loc12_.stackableById.itemFor(_loc13_.stackId),
					gameMasterDictionary.GMStackable) : null,
					gameMasterDictionary.GMStackable);
				if (_loc4_ != null) {
					_loc6_.push(_loc4_);
				}
			}
		var _loc14_ = new Vector<GMNpc>();
		var _loc16_:PetInfo;
		final __ax4_iter_73 = _loc3_.inventoryInfo.getEquipedPetsOnAvatar(_loc10_.id);
		if (checkNullIteratee(__ax4_iter_73))
			for (_tmp_ in __ax4_iter_73) {
				_loc16_ = _tmp_;
				_loc14_.push(_loc16_.gmNpc);
			}
		var _loc7_ = _loc12_.getSkinByType(_loc10_.skinId);
		var _loc9_ = ASCompat.coerceFunction(dbFacade.timelineFactory != null ? dbFacade.timelineFactory.getTimelineJson : null);
		return collectStarlingAtlasPaths(_loc12_, _loc9_, _loc7_, _loc15_, _loc11_, _loc6_, heroKitPets(_loc12_, _loc7_, _loc14_), cacheNpc);
	}

	public static function heroKitPets(gameMaster:GameMaster, gmSkin:GMSkin, equippedPets:Vector<GMNpc>):Vector<GMNpc> {
		var _loc4_ = new Vector<GMNpc>();
		var _loc5_ = ASCompat.coerce(gmSkin != null ? gameMaster.getHeroByConstant(gmSkin.ForHero) : null, gameMasterDictionary.GMHero);
		var _loc6_ = ASCompat.coerce(_loc5_ != null
			&& ASCompat.stringAsBool(_loc5_.Pet) ? ASCompat.coerce(gameMaster.npcByConstant.itemFor(_loc5_.Pet), gameMasterDictionary.GMNpc) : null,
			gameMasterDictionary.GMNpc);
		if (_loc6_ != null) {
			_loc4_.push(_loc6_);
		}
		var _loc7_:GMNpc;
		if (checkNullIteratee(equippedPets))
			for (_tmp_ in equippedPets) {
				_loc7_ = _tmp_;
				_loc4_.push(_loc7_);
			}
		return _loc4_;
	}

	public static function collectStarlingAtlasPaths(gameMaster:GameMaster, timelineJson:ASFunction, gmSkin:GMSkin, weapons:Vector<GMWeaponItem>,
			weaponModels:Vector<String>, consumables:Vector<GMStackable>, pets:Vector<GMNpc>, cacheNpc:Vector<UInt>):Vector<String> {
		var gmHero:GMHero;
		var defaultSkin:GMSkin;
		var weapon:GMWeaponItem;
		var stackable:GMStackable;
		var pet:GMNpc;
		var npcId:UInt;
		var librarySwf:String;
		var paths = new Vector<String>();
		var add:ASFunction = function(param1:String) {
			if (ASCompat.stringAsBool(param1) && paths.indexOf(param1) == -1 && StarlingAssetMapper.getActorAtlasFile(param1) != null) {
				paths.push(param1);
			}
		};
		var addActor:ASFunction = function(param1:String, param2:Vector<String>) {
			if (!ASCompat.stringAsBool(param1) || param1 == "null") {
				return;
			}
			var _loc3_ = DBFacade.buildFullDownloadPath(param1);
			add(_loc3_);
			var _loc4_:String;
			if (checkNullIteratee(param2))
				for (_tmp_ in param2) {
					_loc4_ = _tmp_;
					add(WeaponRenderer.weaponSwfFilePath(_loc3_, _loc4_));
				}
		};
		var addAttack:ASFunction = function(param1:gameMasterDictionary.GMAttack) {
			var _loc3_:ASObject;
			var __ax4_iter_75:Array<ASAny>;
			var _loc4_:GMProjectile = null;
			if (param1 == null) {
				return;
			}
			if (ASCompat.stringAsBool(param1.Projectile)) {
				_loc4_ = ASCompat.coerce(gameMaster.projectileByConstant.itemFor(param1.Projectile), gameMasterDictionary.GMProjectile);
				if (_loc4_ != null && ASCompat.stringAsBool(_loc4_.SwfFilepath)) {
					add(DBFacade.buildFullDownloadPath(_loc4_.SwfFilepath));
				}
			}
			var _loc2_:ASObject = timelineJson != null ? timelineJson(param1.AttackTimeline) : null;
			if (_loc2_ == null || _loc2_.frames == null) {
				return;
			}
			var _loc5_:ASObject;
			final __ax4_iter_74:Array<ASAny> = _loc2_.frames;
			if (checkNullIteratee(__ax4_iter_74))
				for (_tmp_ in __ax4_iter_74) {
					_loc5_ = _tmp_;
					__ax4_iter_75 = _loc5_.actions;
					if (checkNullIteratee(__ax4_iter_75))
						for (_tmp_ in __ax4_iter_75) {
							_loc3_ = _tmp_;
							if (_loc3_ != null) {
								if (ASCompat.toBool(_loc3_.attackEffectPath) && ASCompat.toBool(_loc3_.attackEffectName)) {
									add(DBFacade.buildFullDownloadPath(_loc3_.attackEffectPath));
								}
								if ((_loc3_.type == "effect" || _loc3_.type == "attackEffect")
									&& ASCompat.toBool(_loc3_.path)
									&& ASCompat.toBool(_loc3_.name)) {
									add(DBFacade.buildFullDownloadPath(_loc3_.path));
								}
							}
						}
				}
		};
		var addWeaponAttacks:ASFunction = function(param1:GMWeaponItem) {
			if (param1 == null) {
				return;
			}
			var _loc3_:String;
			final __ax4_iter_76 = param1.AttackArray;
			if (checkNullIteratee(__ax4_iter_76))
				for (_tmp_ in __ax4_iter_76) {
					_loc3_ = _tmp_;
					if (_loc3_ == null) {
						break;
					}
					addAttack(gameMaster.attackByConstant.itemFor(_loc3_));
				}
			var _loc2_:String;
			final __ax4_iter_77:Array<ASAny> = [param1.HoldingAttack, param1.ChargeAttack];
			if (checkNullIteratee(__ax4_iter_77))
				for (_tmp_ in __ax4_iter_77) {
					_loc2_ = _tmp_;
					if (ASCompat.stringAsBool(_loc2_)) {
						addAttack(gameMaster.attackByConstant.itemFor(_loc2_));
					}
				}
		};
		var addNpc:ASFunction = function(param1:GMNpc) {
			var _loc2_:GMWeaponItem = null;
			if (param1 == null) {
				return;
			}
			var _loc4_ = new Vector<String>();
			var _loc3_:String;
			final __ax4_iter_78:Array<ASAny> = [param1.Weapon1, param1.Weapon2, param1.Weapon3, param1.Weapon4, param1.Weapon5];
			if (checkNullIteratee(__ax4_iter_78))
				for (_tmp_ in __ax4_iter_78) {
					_loc3_ = _tmp_;
					_loc2_ = ASCompat.coerce(ASCompat.stringAsBool(_loc3_) ? ASCompat.coerce(gameMaster.weaponItemByConstant.itemFor(_loc3_),
						gameMasterDictionary.GMWeaponItem) : null,
						gameMasterDictionary.GMWeaponItem);
					if (_loc2_ != null && _loc2_.WeaponAestheticList != null && _loc2_.WeaponAestheticList.length > 0) {
						_loc4_.push(_loc2_.WeaponAestheticList[0].ModelName);
					}
				}
			addActor(param1.SwfFilepath, _loc4_);
			final __ax4_iter_79:Array<ASAny> = [param1.Weapon1, param1.Weapon2, param1.Weapon3, param1.Weapon4, param1.Weapon5];
			if (checkNullIteratee(__ax4_iter_79))
				for (_tmp_ in __ax4_iter_79) {
					_loc3_ = _tmp_;
					addWeaponAttacks(ASCompat.stringAsBool(_loc3_) ? gameMaster.weaponItemByConstant.itemFor(_loc3_) : null);
				}
		};
		if (gmSkin != null) {
			addActor(gmSkin.SwfFilepath, weaponModels);
			gmHero = gameMaster.getHeroByConstant(gmSkin.ForHero);
			if (gmHero != null && gmHero.Id == DBGlobal.GHOST_SAMURAI_TYPE_ID && !gameMaster.isSkinTypeADefaultSkin(gmSkin.Id)) {
				defaultSkin = gameMaster.getSkinByConstant(gmHero.DefaultSkin);
				if (defaultSkin != null) {
					addActor(defaultSkin.SwfFilepath, new Vector<String>());
				}
			}
		}
		if (checkNullIteratee(weapons))
			for (_tmp_ in weapons) {
				weapon = _tmp_;
				addWeaponAttacks(weapon);
			}
		if (checkNullIteratee(consumables))
			for (_tmp_ in consumables) {
				stackable = _tmp_;
				if (stackable != null && ASCompat.stringAsBool(stackable.UsageAttack)) {
					addAttack(gameMaster.attackByConstant.itemFor(stackable.UsageAttack));
				}
			}
		if (checkNullIteratee(pets))
			for (_tmp_ in pets) {
				pet = _tmp_;
				addNpc(pet);
			}
		if (checkNullIteratee(cacheNpc))
			for (_tmp_ in cacheNpc) {
				npcId = _tmp_;
				addNpc(gameMaster.npcById.itemFor(npcId));
			}
		final __ax4_iter_80 = STARLING_LIBRARY_SWFS;
		if (checkNullIteratee(__ax4_iter_80))
			for (_tmp_ in __ax4_iter_80) {
				librarySwf = _tmp_;
				add(DBFacade.buildFullDownloadPath(librarySwf));
			}
		return paths;
	}

	public static function starlingPropAtlasClassNames(dbFacade:DBFacade, cacheNpc:Vector<UInt>, floorBiomeKey:String):ASObject {
		var _loc8_:String;
		var _loc4_:GMNpc = null;
		var _loc6_:String = null;
		var _loc11_:String = null;
		var _loc7_:Array<ASAny> = null;
		var _loc5_:Array<ASAny> = null;
		var _loc10_:ASObject = {};
		if (floorBiomeKey == null) {
			return _loc10_;
		}
		var _loc9_:UInt;
		if (checkNullIteratee(cacheNpc))
			for (_tmp_ in cacheNpc) {
				_loc9_ = _tmp_;
				_loc4_ = ASCompat.coerce(dbFacade.gameMaster.npcById.itemFor(_loc9_), gameMasterDictionary.GMNpc);
				if (!(_loc4_ == null || !ASCompat.stringAsBool(_loc4_.SwfFilepath) || _loc4_.SwfFilepath == "null")) {
					_loc6_ = DBFacade.buildFullDownloadPath(_loc4_.SwfFilepath);
					if (StarlingAssetMapper.isPropLibraryPath(_loc6_)) {
						_loc11_ = StarlingAssetMapper.getBiomeKeyFromPath(_loc6_);
						if (!(_loc11_ != floorBiomeKey && _loc11_ != "shared")) {
							_loc7_ = ASCompat.coerce(_loc10_[_loc6_], Array);
							if (_loc7_ == null) {
								_loc7_ = [];
								_loc10_[_loc6_] = _loc7_;
							}
							_loc5_ = _loc4_.CharType == GMActor.CHAR_TYPE_PROP ? ActorRenderer.propAtlasClassNames(_loc4_, true)
								.concat(ActorRenderer.propAtlasClassNames(_loc4_,
									false)) : ActorRenderer.npcAtlasClassNames(_loc4_.AssetClassName)
								.concat([ActorData.offMovieClipClassName(_loc4_.AssetClassName)]);
							if (checkNullIteratee(_loc5_))
								for (_tmp_ in _loc5_) {
									_loc8_ = _tmp_;
									if (ASCompat.stringAsBool(_loc8_) && _loc7_.indexOf(_loc8_) == -1) {
										_loc7_.push(_loc8_);
									}
								}
						}
					}
				}
			}
		return _loc10_;
	}

	public static function swfAsset(name:String, dbFacade:DBFacade) {
		var trash_AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		trash_AssetLoadingComponent.getSwfAsset(name, function(param1:brain.assetRepository.SwfAsset) {});
	}

	public static function tileLibrary(name:String, dbFacade:DBFacade) {
		var makeCallback:ASFunction;
		var trash_AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		if (dbFacade.getTileLibraryJson(name) == null) {
			makeCallback = function(param1:String):ASFunction {
				var path = param1;
				return function(param1:brain.assetRepository.JsonAsset) {
					dbFacade.AddTileLibraryJson(path, param1);
				};
			};
			loadJsonHelperFunction(trash_AssetLoadingComponent, DBFacade.buildFullDownloadPath(name), ASCompat.coerceFunction(makeCallback(name)));
		}
	}

	static function loadJsonHelperFunction(assetLoader:AssetLoadingComponent, path:String, successCallback:ASFunction) {
		assetLoader.getJsonAsset(path, successCallback, function() {
			Logger.error("Unable to load tileLibrary from path: " + path);
		}, false);
	}

	public static function swfVector(files:Vector<String>, dbFacade:DBFacade) {
		var _loc4_ = (0 : UInt);
		var _loc3_:String = null;
		_loc4_ = (0 : UInt);
		while (_loc4_ < (files.length:UInt)) {
			_loc3_ = files[(_loc4_ : Int)];
			if (!StarlingAssetMapper.isArt3DPath(_loc3_)) {
				swfAsset(_loc3_, dbFacade);
			}
			_loc4_++;
		}
	}

	public static function queueBossAtlases(dbFacade:DBFacade, cacheNpc:Vector<UInt>) {
		var _loc3_:GMNpc = null;
		var _loc4_:String = null;
		var _loc5_:File = null;
		if (dbFacade.assetLoadingComponent == null) {
			return;
		}
		var _loc6_:UInt;
		if (checkNullIteratee(cacheNpc))
			for (_tmp_ in cacheNpc) {
				_loc6_ = _tmp_;
				_loc3_ = ASCompat.coerce(dbFacade.gameMaster.npcById.itemFor(_loc6_), gameMasterDictionary.GMNpc);
				if (!(_loc3_ == null || !_loc3_.IsBoss || !ASCompat.stringAsBool(_loc3_.SwfFilepath) || _loc3_.SwfFilepath == "null")) {
					_loc4_ = DBFacade.buildFullDownloadPath(_loc3_.SwfFilepath);
					_loc5_ = StarlingAssetMapper.getActorAtlasFile(_loc4_, true);
					if (_loc5_ != null) {
						dbFacade.assetLoadingComponent.queueStarlingAssets(StarlingAssetMapper.getActorAtlasKeyFromPath(_loc4_), null, false, [_loc5_]);
						dbFacade.assetLoadingComponent.markStarlingKeyUsed(_loc3_.AssetClassName + "_idle");
					}
				}
			}
	}
}
