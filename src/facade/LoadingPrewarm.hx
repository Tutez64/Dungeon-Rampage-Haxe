package facade;

import account.AvatarInfo;
import account.Consumable;
import account.ItemInfo;
import account.PetInfo;
import brain.assetRepository.StarlingAssetMapper;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import gameMasterDictionary.GMAttack;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.GMStackable;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import generatedCode.HeroPreloadLook;
import generatedCode.WeaponDetails;
import brain.assetRepository.StarlingAssetMapper;
import brain.logger.Logger;
import effects.EffectGameObject;
import effects.EffectView;
import facade.DBFacade;
import flash.geom.Point;
import starling.extensions.animate.Animation;

class LoadingPrewarm {
	public static inline final MAX_HOLD_MS = 900;

	static inline final SLICE_MS = 30;

	static inline final HOLD_SLICE_MS = 60;

	static inline final BACKGROUND_SLICE_MS = 3;

	static inline final BACKGROUND_DEADLINE_MS = 30000;

	public static inline final MAX_SEGMENT_FRAMES = 90;

	static inline final HERO_EFFECTS = 4;

	static inline final HERO_ANGLE_EFFECTS = 2;

	static inline final HERO_HITS = 12;

	static inline final NPC_EFFECTS = 4;

	static inline final NPC_HITS = 4;

	static inline final NPC_ALLY_HITS = 2;

	static inline final DEATHS = 3;

	static inline final COMMON_HITS = 4;

	static inline final FX_LIBRARY = "Resources/Art2D/FX/db_fx_library.swf";

	static var sLoading:LoadingPrewarm;

	static var sFrameKey:UInt = 0;

	static var sFrameUsedMs:Int = 0;

	static var COMMON_EFFECTS:Array<ASAny>;

	static var RARE_EFFECTS:Array<ASAny>;

	static var ANGLES:Array<ASAny>;

	static var sPendingLooks:Array<ASAny>;

	static var sBackground:Vector<LoadingPrewarm> = new Vector();

	static var sWarmedLooks:ASObject;

	var mDBFacade:DBFacade;

	var mBackground:Bool = false;

	var mWork:LogicalWorkComponent;

	var mJobs:Vector<PrewarmJob> = new Vector();

	var mJobsByKey:ASObject = {};

	var mNext:Int = 0;

	var mFirstSlice:UInt = 0;

	var mSliced:Bool = false;

	var mHoldStart:UInt = 0;

	var mHoldAllowance:Int = 0;

	var mHolding:Bool = false;

	var mOnRelease:ASFunction;

	var mDone:Bool = false;

	var mTrailOverrides:Array<ASAny> = [];

	var mLookKey:String;

	public function new(dbFacade:DBFacade, background:Bool) {
		mDBFacade = dbFacade;
		mBackground = background;
	}

	public static function startLoading(dbFacade:DBFacade, cacheNpc:Vector<UInt>):LoadingPrewarm {
		var look:HeroPreloadLook;
		var looks = sPendingLooks;
		sPendingLooks = [];
		sWarmedLooks = {};
		sLoading = new LoadingPrewarm(dbFacade, false);
		sLoading.start(function() {
			sLoading.planLoading(cacheNpc);
		});
		if (checkNullIteratee(looks))
			for (_tmp_ in looks) {
				look = ASCompat.coerce(_tmp_, generatedCode.HeroPreloadLook);
				startBackground(dbFacade, look);
			}
		return sLoading;
	}

	public static function startLoadingAndRelease(dbFacade:DBFacade, cacheNpc:Vector<UInt>, entryGeneration:Int):LoadingPrewarm {
		var _loc4_ = startLoading(dbFacade, cacheNpc);
		dbFacade.assetLoadingComponent.releaseBundlesUnusedSince(entryGeneration);
		return _loc4_;
	}

	public static function heroJoined(dbFacade:DBFacade, look:HeroPreloadLook) {
		if (look == null) {
			return;
		}
		if (sLoading == null && dbFacade.mainStateMachine.currentStateName == "LoadingScreenState") {
			sPendingLooks.push(look);
			return;
		}
		startBackground(dbFacade, look);
	}

	static function startBackground(dbFacade:DBFacade, look:HeroPreloadLook) {
		var background:LoadingPrewarm;
		var key = look.heroType + "|" + look.skinType + "|" + lookParts(look.weapons) + "|" + look.consumableTypes + "|" + look.petTypes;
		if (ASCompat.toBool(sWarmedLooks[key])) {
			return;
		}
		sWarmedLooks[key] = true;
		background = new LoadingPrewarm(dbFacade, true);
		background.mLookKey = key;
		sBackground.push(background);
		background.start(function() {
			background.planLook(look);
		});
	}

	static function lookParts(weapons:Vector<WeaponDetails>):String {
		var _loc3_:Array<ASAny> = [];
		var _loc2_:WeaponDetails;
		if (checkNullIteratee(weapons))
			for (_tmp_ in weapons) {
				_loc2_ = _tmp_;
				_loc3_.push(_loc2_.type + "/" + _loc2_.requiredlevel + "/" + _loc2_.legendarymodifier);
			}
		return _loc3_.join(",");
	}

	public static function cancelLoading() {
		if (sLoading != null) {
			sLoading.cancel();
		}
		sLoading = null;
	}

	public static function cancelAll() {
		cancelLoading();
		sPendingLooks = [];
		sWarmedLooks = {};
		var _loc1_:LoadingPrewarm;
		final __ax4_iter_47 = sBackground.concat();
		if (checkNullIteratee(__ax4_iter_47))
			for (_tmp_ in __ax4_iter_47) {
				_loc1_ = _tmp_;
				_loc1_.cancel();
			}
		sBackground.length = 0;
	}

	@:isVar public static var busy(get, never):Bool;

	static public function get_busy():Bool {
		return sLoading != null && sLoading.running || sBackground.length > 0 || sPendingLooks.length > 0;
	}

	function start(plan:ASFunction) {
		var _loc3_:String = null;
		try {
			plan();
		} catch (error:Dynamic) {
			Logger.error("LoadingPrewarm: planning failed: " + Std.string(error.message));
		}
		var _loc2_ = mDBFacade.assetLoadingComponent;
		var _loc4_:PrewarmJob;
		final __ax4_iter_48 = mJobs;
		if (checkNullIteratee(__ax4_iter_48))
			for (_tmp_ in __ax4_iter_48) {
				_loc4_ = _tmp_;
				_loc3_ = StarlingAssetMapper.getActorAtlasKeyFromPath(_loc4_.swfPath);
				if (_loc2_ != null && _loc3_ != null) {
					_loc2_.markStarlingKeyUsed(_loc3_);
				}
			}
		mWork = new LogicalWorkComponent(mDBFacade, "LoadingPrewarm");
		mWork.doEveryFrame(onFrame);
	}

	@:isVar public var running(get, never):Bool;

	public function get_running():Bool {
		return !mDone;
	}

	public function hold(onRelease:ASFunction) {
		if (mDone) {
			onRelease();
			return;
		}
		mOnRelease = onRelease;
		if (mHolding) {
			return;
		}
		mHolding = true;
		mHoldStart = (flash.Lib.getTimer() : UInt);
		mHoldAllowance = mDBFacade.featureFlags.getFlagValue("loading-prewarm-hold") ? 900 : 0;
		if (pastDeadline) {
			finish();
		}
	}

	public function cancel() {
		if (!mDone) {
			finish(false);
		}
	}

	@:isVar var pastDeadline(get, never):Bool;

	function get_pastDeadline():Bool {
		return mBackground ? mSliced
			&& ASCompat.floatToInt(flash.Lib.getTimer() - (mFirstSlice : Float)) >= 30000 : mHolding
			&& ASCompat.floatToInt(flash.Lib.getTimer() - (mHoldStart : Float)) >= mHoldAllowance;
	}

	function onFrame(clock:GameClock) {
		var _loc8_:PrewarmJob = null;
		var _loc2_ = 0;
		if (mDone) {
			return;
		}
		if (pastDeadline) {
			finish();
			return;
		}
		var _loc3_ = (mDBFacade.gameClock.realTime : UInt);
		if (_loc3_ != sFrameKey) {
			sFrameKey = _loc3_;
			sFrameUsedMs = 0;
		}
		if (mBackground && sLoading != null && sLoading.running) {
			return;
		}
		var _loc5_ = !mBackground ? (mHolding ? 60 : 30) : (mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState" ? 30 : 3);
		var _loc6_ = _loc5_ - sFrameUsedMs;
		if (_loc6_ <= 0) {
			return;
		}
		var _loc4_ = flash.Lib.getTimer();
		if (!mSliced) {
			mSliced = true;
			mFirstSlice = (_loc4_ : UInt);
		}
		var _loc7_ = 0;
		while (mNext < mJobs.length && !pastDeadline) {
			_loc8_ = mJobs[mNext];
			try {
				_loc2_ = _loc8_.step(mDBFacade, mBackground);
			} catch (error:Dynamic) {
				_loc8_.abort(mDBFacade);
				_loc2_ = PrewarmJob.DONE;
				Logger.error("LoadingPrewarm: building " + _loc8_.name + " failed: " + Std.string(error.message));
			}
			if (_loc2_ == PrewarmJob.DONE) {
				mNext = mNext + 1;
				_loc7_ = 0;
			} else if (_loc2_ == 2) {
				mJobs.splice(mNext, (1 : UInt));
				mJobs.push(_loc8_);
				if (++_loc7_ >= mJobs.length - mNext) {
					break;
				}
			}
			if (flash.Lib.getTimer() - _loc4_ >= _loc6_) {
				break;
			}
		}
		sFrameUsedMs += flash.Lib.getTimer() - _loc4_;
		if (mNext >= mJobs.length || pastDeadline) {
			finish();
		}
	}

	function finish(callBack:Bool = true) {
		var _loc3_ = 0;
		mDone = true;
		if (mNext < mJobs.length) {
			mJobs[mNext].abort(mDBFacade);
		}
		if (mWork != null) {
			mWork.destroy();
			mWork = null;
		}
		if (mBackground) {
			if (mLookKey != null && mNext < mJobs.length) {
				ASCompat.deleteProperty(sWarmedLooks, mLookKey);
			}
			_loc3_ = sBackground.indexOf(this);
			if (_loc3_ >= 0) {
				sBackground.splice(_loc3_, (1 : UInt));
			}
		}
		var _loc2_ = mOnRelease;
		mOnRelease = null;
		mJobs = new Vector<PrewarmJob>();
		mJobsByKey = {};
		if (callBack && _loc2_ != null) {
			_loc2_();
		}
	}

	function planLoading(cacheNpc:Vector<UInt>) {
		var _loc5_:ItemInfo;
		var __ax4_iter_49:Vector<ItemInfo>;
		var _loc11_:Consumable;
		var __ax4_iter_50:Vector<Consumable>;
		var _loc15_:PetInfo;
		var __ax4_iter_51:Vector<PetInfo>;
		var _loc3_:GMNpc = null;
		var _loc14_:Array<ASAny> = null;
		var _loc6_:Array<ASAny> = null;
		var _loc4_:Array<ASAny> = null;
		var _loc7_:GMSkin = null;
		var _loc10_ = mDBFacade.gameMaster;
		var _loc2_ = mDBFacade.dbAccountInfo;
		var _loc8_ = ASCompat.coerce(_loc2_ != null ? _loc2_.activeAvatarInfo : null, account.AvatarInfo);
		var _loc13_ = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
		if (_loc8_ != null && _loc2_.inventoryInfo != null) {
			_loc14_ = [];
			__ax4_iter_49 = _loc2_.inventoryInfo.getEquipedItemsOnAvatar(_loc8_.id);
			if (checkNullIteratee(__ax4_iter_49))
				for (_tmp_ in __ax4_iter_49) {
					_loc5_ = _tmp_;
					if (_loc5_.gmWeaponItem != null) {
						_loc14_.push(([_loc5_.gmWeaponItem, _loc5_.gmWeaponAesthetic] : Array<ASAny>));
					}
				}
			_loc6_ = [];
			__ax4_iter_50 = _loc8_.equippedConsumables;
			if (checkNullIteratee(__ax4_iter_50))
				for (_tmp_ in __ax4_iter_50) {
					_loc11_ = _tmp_;
					if (_loc11_.stackId != 0) {
						_loc6_.push(_loc10_.stackableById.itemFor(_loc11_.stackId));
					}
				}
			_loc4_ = [];
			__ax4_iter_51 = _loc2_.inventoryInfo.getEquipedPetsOnAvatar(_loc8_.id);
			if (checkNullIteratee(__ax4_iter_51))
				for (_tmp_ in __ax4_iter_51) {
					_loc15_ = _tmp_;
					_loc4_.push(_loc15_.gmNpc);
				}
			_loc7_ = _loc10_.getSkinByType(_loc8_.skinId);
			addHero(ASCompat.coerce(_loc7_ != null ? _loc10_.getHeroByConstant(_loc7_.ForHero) : null, gameMasterDictionary.GMHero), _loc14_, _loc6_, _loc4_);
		}
		var _loc9_:String;
		final __ax4_iter_52 = COMMON_EFFECTS;
		if (checkNullIteratee(__ax4_iter_52))
			for (_tmp_ in __ax4_iter_52) {
				_loc9_ = _tmp_;
				addEffect(_loc13_, _loc9_, 4);
			}
		var _loc16_:UInt;
		if (checkNullIteratee(cacheNpc))
			for (_tmp_ in cacheNpc) {
				_loc16_ = _tmp_;
				addNpc(ASCompat.coerce(_loc10_.npcById.itemFor(_loc16_), gameMasterDictionary.GMNpc), false);
			}
		if (checkNullIteratee(cacheNpc))
			for (_tmp_ in cacheNpc) {
				_loc16_ = _tmp_;
				_loc3_ = ASCompat.coerce(_loc10_.npcById.itemFor(_loc16_), gameMasterDictionary.GMNpc);
				if (_loc3_ != null
					&& ASCompat.stringAsBool(_loc3_.ViolentDeathClassName)
					&& ASCompat.stringAsBool(_loc3_.ViolentDeathFilePath)) {
					addEffect(DBFacade.buildFullDownloadPath(_loc3_.ViolentDeathFilePath), _loc3_.ViolentDeathClassName, 3);
				}
			}
		var _loc12_:String;
		final __ax4_iter_53 = RARE_EFFECTS;
		if (checkNullIteratee(__ax4_iter_53))
			for (_tmp_ in __ax4_iter_53) {
				_loc12_ = _tmp_;
				addEffect(_loc13_, _loc12_, 1);
			}
	}

	function planLook(look:HeroPreloadLook) {
		var _loc2_:GMWeaponItem = null;
		var _loc6_ = false;
		var _loc5_ = mDBFacade.gameMaster;
		var _loc9_:Array<ASAny> = [];
		var _loc4_:WeaponDetails;
		final __ax4_iter_54 = look.weapons;
		if (checkNullIteratee(__ax4_iter_54))
			for (_tmp_ in __ax4_iter_54) {
				_loc4_ = _tmp_;
				_loc2_ = ASCompat.coerce(_loc4_.type != 0 ? ASCompat.coerce(_loc5_.weaponItemById.itemFor(_loc4_.type),
					gameMasterDictionary.GMWeaponItem) : null,
					gameMasterDictionary.GMWeaponItem);
				if (_loc2_ != null) {
					_loc6_ = _loc4_.legendarymodifier > 0 && _loc5_.legendaryModifiersById.itemFor(_loc4_.legendarymodifier) != null;
					_loc9_.push(([_loc2_, _loc2_.getWeaponAesthetic(_loc4_.requiredlevel, _loc6_)] : Array<ASAny>));
				}
			}
		var _loc7_:Array<ASAny> = [];
		var _loc8_:UInt;
		final __ax4_iter_55 = look.consumableTypes;
		if (checkNullIteratee(__ax4_iter_55))
			for (_tmp_ in __ax4_iter_55) {
				_loc8_ = _tmp_;
				if (_loc8_ != 0) {
					_loc7_.push(_loc5_.stackableById.itemFor(_loc8_));
				}
			}
		var _loc3_:Array<ASAny> = [];
		var _loc10_:UInt;
		final __ax4_iter_56 = look.petTypes;
		if (checkNullIteratee(__ax4_iter_56))
			for (_tmp_ in __ax4_iter_56) {
				_loc10_ = _tmp_;
				_loc3_.push(_loc5_.npcById.itemFor(_loc10_));
			}
		addHero(ASCompat.coerce(_loc5_.heroById.itemFor(look.heroType), gameMasterDictionary.GMHero), _loc9_, _loc7_, _loc3_);
	}

	function addHero(gmHero:GMHero, weapons:Array<ASAny>, consumables:Array<ASAny>, pets:Array<ASAny>) {
		var _loc5_:GMWeaponAesthetic = null;
		mTrailOverrides = [null];
		var _loc7_:Array<ASAny>;
		if (checkNullIteratee(weapons))
			for (_tmp_ in weapons) {
				_loc7_ = ASCompat.coerce(_tmp_, Array);
				_loc5_ = ASCompat.coerce(_loc7_[1], gameMasterDictionary.GMWeaponAesthetic);
				if (_loc5_ != null
					&& ASCompat.stringAsBool(_loc5_.SwordTrailOverride)
					&& mTrailOverrides.indexOf(_loc5_.SwordTrailOverride) < 0) {
					mTrailOverrides.push(_loc5_.SwordTrailOverride);
				}
			}
		if (checkNullIteratee(weapons))
			for (_tmp_ in weapons) {
				_loc7_ = ASCompat.coerce(_tmp_, Array);
				addWeapon(ASCompat.coerce(_loc7_[0], gameMasterDictionary.GMWeaponItem), true);
			}
		if (gmHero != null) {
			addAttack(gmHero.DBuster1, true);
			addAttack(gmHero.TeamAttack, true);
			if (ASCompat.stringAsBool(gmHero.Pet)) {
				addNpc(ASCompat.coerce(mDBFacade.gameMaster.npcByConstant.itemFor(gmHero.Pet), gameMasterDictionary.GMNpc), true);
			}
		}
		var _loc6_:GMStackable;
		if (checkNullIteratee(consumables))
			for (_tmp_ in consumables) {
				_loc6_ = ASCompat.coerce(_tmp_, gameMasterDictionary.GMStackable);
				if (_loc6_ != null) {
					addAttack(_loc6_.UsageAttack, true);
				}
			}
		mTrailOverrides = [null];
		var _loc8_:GMNpc;
		if (checkNullIteratee(pets))
			for (_tmp_ in pets) {
				_loc8_ = ASCompat.coerce(_tmp_, gameMasterDictionary.GMNpc);
				addNpc(_loc8_, true);
			}
	}

	function addNpc(npc:GMNpc, heroSide:Bool) {
		if (npc == null) {
			return;
		}
		var _loc3_:String;
		final __ax4_iter_57:Array<ASAny> = [npc.Weapon1, npc.Weapon2, npc.Weapon3, npc.Weapon4, npc.Weapon5];
		if (checkNullIteratee(__ax4_iter_57))
			for (_tmp_ in __ax4_iter_57) {
				_loc3_ = _tmp_;
				if (ASCompat.stringAsBool(_loc3_)) {
					addWeapon(ASCompat.coerce(mDBFacade.gameMaster.weaponItemByConstant.itemFor(_loc3_), gameMasterDictionary.GMWeaponItem), heroSide);
				}
			}
	}

	function addWeapon(weapon:GMWeaponItem, heroSide:Bool) {
		if (weapon == null) {
			return;
		}
		var _loc3_:String;
		final __ax4_iter_58 = weapon.AttackArray;
		if (checkNullIteratee(__ax4_iter_58))
			for (_tmp_ in __ax4_iter_58) {
				_loc3_ = _tmp_;
				if (_loc3_ == null) {
					break;
				}
				addAttack(_loc3_, heroSide);
			}
		addAttack(weapon.HoldingAttack, heroSide);
		addAttack(weapon.ChargeAttack, heroSide);
	}

	function addAttack(attackConstant:String, heroSide:Bool) {
		var _loc4_:ASObject;
		var __ax4_iter_60:ASAny;
		var _loc3_:String = null;
		if (!ASCompat.stringAsBool(attackConstant)) {
			return;
		}
		var _loc5_ = ASCompat.coerce(mDBFacade.gameMaster.attackByConstant.itemFor(attackConstant), gameMasterDictionary.GMAttack);
		if (_loc5_ == null) {
			return;
		}
		if (ASCompat.stringAsBool(_loc5_.HitEffectFilepath)) {
			_loc3_ = DBFacade.buildFullDownloadPath(_loc5_.HitEffectFilepath);
			if (ASCompat.stringAsBool(_loc5_.HitEffect)) {
				addEffect(_loc3_, _loc5_.HitEffect, heroSide ? 12 : 2);
			}
			if (!heroSide) {
				addEffect(_loc3_, "db_fx_hitRed", 4);
			}
		}
		var _loc6_:ASObject = mDBFacade.timelineFactory != null ? mDBFacade.timelineFactory.getTimelineJson(_loc5_.AttackTimeline) : null;
		if (_loc6_ == null || _loc6_.frames == null) {
			return;
		}
		var _loc7_:ASObject;
		final __ax4_iter_59:ASAny = _loc6_.frames;
		if (checkNullIteratee(__ax4_iter_59))
			for (_tmp_ in __ax4_iter_59) {
				_loc7_ = _tmp_;
				__ax4_iter_60 = _loc7_.actions;
				if (checkNullIteratee(__ax4_iter_60))
					for (_tmp_ in __ax4_iter_60) {
						_loc4_ = _tmp_;
						if (_loc4_ != null
							&& ASCompat.toBool(_loc4_.path)
							&& ASCompat.toBool(_loc4_.name)
							&& !ASCompat.toBool(_loc4_.managed)
							&& (_loc4_.type == "effect" || _loc4_.type == "attackEffect")) {
							addEffectNames(DBFacade.buildFullDownloadPath(_loc4_.path), ASCompat.toString(_loc4_.name), heroSide);
						}
					}
			}
	}

	function addEffectNames(swfPath:String, name:String, heroSide:Bool) {
		var _loc6_:String;
		var __ax4_iter_62:Array<ASAny>;
		var _loc5_:String = null;
		if (name.indexOf("_angle") < 0) {
			addEffect(swfPath, name, heroSide ? 4 : 4);
			return;
		}
		var _loc4_:String;
		final __ax4_iter_61 = mTrailOverrides;
		if (checkNullIteratee(__ax4_iter_61))
			for (_tmp_ in __ax4_iter_61) {
				_loc4_ = _tmp_;
				_loc5_ = ASCompat.stringAsBool(_loc4_) ? StringTools.replace(name, "db_fx_attack", _loc4_) : name;
				__ax4_iter_62 = ANGLES;
				if (checkNullIteratee(__ax4_iter_62))
					for (_tmp_ in __ax4_iter_62) {
						_loc6_ = _tmp_;
						if (_loc5_.indexOf("swing_angle") >= 0) {
							addEffect(swfPath, _loc5_ + _loc6_ + "_right", heroSide ? 2 : 1);
							addEffect(swfPath, _loc5_ + _loc6_ + "_left", heroSide ? 2 : 1);
						} else {
							addEffect(swfPath, _loc5_ + _loc6_, heroSide ? 2 : 1);
						}
					}
			}
	}

	function addEffect(swfPath:String, className:String, count:Int) {
		var _loc5_ = swfPath + "|" + className;
		var _loc4_ = ASCompat.coerce(mJobsByKey[_loc5_], PrewarmJob);
		if (_loc4_ != null) {
			_loc4_.count = ASCompat.floatToInt(Math.max(_loc4_.count, count));
			return;
		}
		_loc4_ = new PrewarmJob(swfPath, className, count);
		mJobsByKey[_loc5_] = _loc4_;
		mJobs.push(_loc4_);
	}

	static function __init__() {
		COMMON_EFFECTS = [
			"db_fx_hit_bang",
			"db_fx_hit_super",
			"db_fx_hit_sweet",
			"db_fx_hit_weak",
			"db_fx_hit_fail",
			"db_fx_hitRed"
		];
		RARE_EFFECTS = ["db_fx_levelup", "db_fx_levelup_background"];
		ANGLES = ["90", "135", "180", "225", "270"];
		sPendingLooks = [];
		sWarmedLooks = {};
	}
}

private class PrewarmJob {
	public static inline final DONE = 0;

	public static inline final MORE = 1;

	public static inline final WAIT = 2;

	static inline final READY = 0;

	static inline final LOADING = 1;

	static inline final NEVER = 2;

	public var swfPath:String;

	public var name:String;

	public var count:Int = 0;

	var mStarted:Bool = false;

	var mEntered:Bool = false;

	var mLabel:String;

	var mEffects:Array<ASAny> = [];

	var mAnimations:Array<ASAny> = [];

	var mFrame:Int = 0;

	var mEnd:Int = 0;

	var mRootEnd:Int = 0;

	public function new(swfPath:String, name:String, count:Int) {
		this.swfPath = swfPath;
		this.name = name;
		this.count = count;
	}

	public function step(dbFacade:DBFacade, waitForLoads:Bool):Int {
		var _loc4_ = 0;
		var _loc3_ = false;
		if (!mStarted) {
			_loc4_ = residency(dbFacade);
			if (_loc4_ != 0) {
				return _loc4_ == 1 && waitForLoads ? 2 : 0;
			}
			mStarted = true;
		}
		if (!mEntered) {
			_loc3_ = checkoutEffect(dbFacade);
			if (_loc3_ && mAnimations.length < count) {
				return 1;
			}
			mEntered = true;
			if (!_loc3_ || !enterSegment()) {
				handBack(dbFacade);
				return 0;
			}
			return finishedOrMore(dbFacade);
		}
		var _loc5_:Animation;
		final __ax4_iter_63 = mAnimations;
		if (checkNullIteratee(__ax4_iter_63))
			for (_tmp_ in __ax4_iter_63) {
				_loc5_ = ASCompat.coerce(_tmp_, starling.extensions.animate.Animation);
				_loc5_.currentFrame = ASCompat.floatToInt(Math.min(mFrame, mRootEnd));
				_loc5_.advanceMovieClips();
			}
		mFrame = ASCompat.floatToInt(mFrame + 1);
		return finishedOrMore(dbFacade);
	}

	public function abort(dbFacade:DBFacade) {
		handBack(dbFacade);
	}

	function finishedOrMore(dbFacade:DBFacade):Int {
		if (mFrame <= mEnd) {
			return 1;
		}
		handBack(dbFacade);
		return 0;
	}

	function residency(dbFacade:DBFacade):Int {
		var _loc2_ = dbFacade.assetLoadingComponent;
		var _loc3_ = StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath);
		if (_loc2_ == null
			|| _loc3_ == null
			|| dbFacade.starlingLayerManager == null
			|| StarlingAssetMapper.getActorAtlasFile(swfPath, true) == null) {
			return 2;
		}
		if (!_loc2_.isStarlingKeyResident(_loc3_)) {
			return 1;
		}
		return _loc2_.hasAnimationInAssetManager(name) ? 0 : 2;
	}

	function checkoutEffect(dbFacade:DBFacade):Bool {
		var _loc3_ = ASCompat.reinterpretAs(dbFacade.effectPool.checkout(dbFacade, swfPath, name, null, null), EffectGameObject);
		if (_loc3_ == null) {
			return false;
		}
		mEffects.push(_loc3_);
		var _loc2_ = cast(_loc3_.view, EffectView).prewarmRenderer();
		if (_loc2_ == null || _loc2_.animation == null) {
			return false;
		}
		mLabel = _loc2_.label;
		mAnimations.push(_loc2_.animation);
		return true;
	}

	function enterSegment():Bool {
		var _loc3_:Point = null;
		if (mAnimations.length == 0) {
			return false;
		}
		var _loc2_ = 0;
		var _loc4_ = cast(mAnimations[0], Animation).numFrames - 1;
		var _loc5_:Animation;
		final __ax4_iter_64 = mAnimations;
		if (checkNullIteratee(__ax4_iter_64))
			for (_tmp_ in __ax4_iter_64) {
				_loc5_ = ASCompat.coerce(_tmp_, starling.extensions.animate.Animation);
				if (mLabel != null && _loc5_.getFrame(mLabel) >= 0) {
					_loc3_ = _loc5_.gotoLabel(mLabel, false);
					if (_loc3_.x < 0) {
						return false;
					}
					_loc2_ = ASCompat.floatToInt(_loc3_.x);
					_loc4_ = ASCompat.floatToInt(_loc3_.y);
				} else {
					_loc5_.currentFrame = 0;
				}
				_loc5_.advanceMovieClips();
			}
		mFrame = _loc2_ + 1;
		mRootEnd = _loc4_;
		var _loc1_ = cast(mAnimations[0], Animation).deepestFrames;
		mEnd = ASCompat.floatToInt(Math.min(Math.max(_loc4_, _loc2_ + _loc1_ - 1), _loc2_ + 90 - 1));
		return true;
	}

	function handBack(dbFacade:DBFacade) {
		var _loc2_ = mEffects;
		mEffects = [];
		mAnimations = [];
		mFrame = mEnd + 1;
		var _loc3_:EffectGameObject;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = ASCompat.coerce(_tmp_, effects.EffectGameObject);
				try {
					if (!_loc3_.isDestroyed) {
						dbFacade.effectPool.checkin(_loc3_);
					}
				} catch (error:Dynamic) {
					Logger.error("LoadingPrewarm: returning " + name + " to the effect pool failed: " + Std.string(error.message));
				}
			}
	}
}
