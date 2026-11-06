package combat.weapon;

import actor.ActorGameObject;
import actor.ActorView;
import brain.assetRepository.StarlingAssetMapper;
import brain.gameObject.GameObject;
import brain.utils.MemoryTracker;
import collections.Map;
import combat.attack.AttackTimeline;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.NPCGameObject;
import effects.EffectGameObject;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import gameMasterDictionary.GMLegendaryModifier;
import gameMasterDictionary.GMModifier;
import gameMasterDictionary.GMProjectile;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import generatedCode.WeaponDetails;

class WeaponGameObject extends GameObject {
	var mDBFacade:DBFacade;

	var mActorGameObject:ActorGameObject;

	var mActorView:ActorView;

	var mDistributedDungeonFloor:DistributedDungeonFloor;

	var mAttackTimelineMap:Map;

	var mWeaponDetails:WeaponDetails;

	var mGMWeapon:GMWeaponItem;

	var mGMRarity:GMRarity;

	var mSlot:Float = Math.NaN;

	var mAttackSpeedModifier:Vector<Float>;

	var mManaModifier:Float = 1;

	var mChains:Float = 0;

	var mPierces:Float = 0;

	var mCooldownReduction:Float = 1;

	var mChargeReduction:Float = 1;

	var mCollisionScale:Float = 1;

	var mPreloadedEffectKeys:ASObject = {};

	var mWeaponView:WeaponView;

	var mModifiers:Vector<GMModifier>;

	var mLegendaryModifier:GMLegendaryModifier;

	var mWeaponAesthetic:GMWeaponAesthetic;

	public function new(weaponDetails:WeaponDetails, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, slot:Float) {
		super(dbFacade);
		mSlot = slot;
		mDBFacade = dbFacade;
		mAttackSpeedModifier = new Vector<Float>();
		mAttackSpeedModifier.push(1);
		mAttackSpeedModifier.push(1);
		mAttackSpeedModifier.push(1);
		mWeaponDetails = weaponDetails;
		mGMRarity = ASCompat.coerce(mDBFacade.gameMaster.rarityById.itemFor(mWeaponDetails.rarity), gameMasterDictionary.GMRarity);
		mActorGameObject = actorGameObject;
		mModifiers = new Vector<GMModifier>();
		if (mWeaponDetails.modifier1 > 0) {
			mModifiers.push(ASCompat.coerce(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier1), gameMasterDictionary.GMModifier));
		}
		if (mWeaponDetails.modifier2 > 0) {
			mModifiers.push(ASCompat.coerce(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier2), gameMasterDictionary.GMModifier));
		}
		if (mWeaponDetails.legendarymodifier > 0) {
			mLegendaryModifier = ASCompat.coerce(mDBFacade.gameMaster.legendaryModifiersById.itemFor(mWeaponDetails.legendarymodifier),
				gameMasterDictionary.GMLegendaryModifier);
		}
		updateStatsForModifiers();
		updateStatsForLegendaryModifier();
		mGMWeapon = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mWeaponDetails.type), gameMasterDictionary.GMWeaponItem);
		mActorView = actorView;
		mDistributedDungeonFloor = distributedDungeonFloor;
		mAttackTimelineMap = new Map();
		mWeaponAesthetic = mGMWeapon.getWeaponAesthetic((requiredLevel : UInt), mLegendaryModifier != null);
		mWeaponView = new WeaponView(mDBFacade, this);
		MemoryTracker.track(mWeaponView, "WeaponView - created in WeaponGameObject.constructor()");
		preloadProjectileAssets();
	}

	function preloadProjectileAssets() {
		if (mDBFacade.assetLoadingComponent == null || mDBFacade.starlingLayerManager == null) {
			return;
		}
		var _loc1_:String;
		final __ax4_iter_336 = mGMWeapon.AttackArray;
		if (checkNullIteratee(__ax4_iter_336))
			for (_tmp_ in __ax4_iter_336) {
				_loc1_ = _tmp_;
				if (_loc1_ == null) {
					break;
				}
				preloadProjectileAssetsForAttackConstant(_loc1_);
			}
		if (ASCompat.stringAsBool(mGMWeapon.HoldingAttack)) {
			preloadProjectileAssetsForAttackConstant(mGMWeapon.HoldingAttack);
		}
		if (ASCompat.stringAsBool(mGMWeapon.ChargeAttack)) {
			preloadProjectileAssetsForAttackConstant(mGMWeapon.ChargeAttack);
		}
	}

	function preloadProjectileAssetsForAttackConstant(attackConstant:String) {
		var _loc2_ = ASCompat.coerce(mDBFacade.gameMaster.attackByConstant.itemFor(attackConstant), gameMasterDictionary.GMAttack);
		if (_loc2_ == null) {
			return;
		}
		preloadProjectileAssetsForAttack(_loc2_);
	}

	function preloadProjectileAssetsForAttack(gmAttack:GMAttack) {
		var _loc2_:ASObject;
		var __ax4_iter_338:ASAny;
		var _loc3_:GMProjectile = null;
		if (ASCompat.stringAsBool(gmAttack.Projectile)) {
			_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.projectileByConstant.itemFor(gmAttack.Projectile), gameMasterDictionary.GMProjectile);
			if (_loc3_ != null && ASCompat.stringAsBool(_loc3_.SwfFilepath)) {
				mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(DBFacade.buildFullDownloadPath(_loc3_.SwfFilepath), null, false, isBackgroundLoad,
					backgroundLoadTier);
			}
		}
		if (mDBFacade.timelineFactory == null) {
			return;
		}
		var _loc4_:ASObject = mDBFacade.timelineFactory.getTimelineJson(gmAttack.AttackTimeline);
		if (_loc4_ == null || _loc4_.frames == null) {
			return;
		}
		var _loc5_:ASObject;
		final __ax4_iter_337:ASAny = _loc4_.frames;
		if (checkNullIteratee(__ax4_iter_337))
			for (_tmp_ in __ax4_iter_337) {
				_loc5_ = _tmp_;
				__ax4_iter_338 = _loc5_.actions;
				if (checkNullIteratee(__ax4_iter_338))
					for (_tmp_ in __ax4_iter_338) {
						_loc2_ = _tmp_;
						if (_loc2_ != null) {
							if (ASCompat.toBool(_loc2_.attackEffectPath) && ASCompat.toBool(_loc2_.attackEffectName)) {
								queueEffectAtlas(DBFacade.buildFullDownloadPath(_loc2_.attackEffectPath), _loc2_.attackEffectName);
							}
							if ((_loc2_.type == "effect" || _loc2_.type == "attackEffect")
								&& ASCompat.toBool(_loc2_.path)
								&& ASCompat.toBool(_loc2_.name)) {
								preloadEffectAsset(_loc2_);
							}
						}
					}
			}
	}

	function preloadEffectAsset(action:ASObject) {
		var effectName:String;
		var fullPath = DBFacade.buildFullDownloadPath(action.path);
		var poolKey = fullPath + ":" + Std.string(action.name);
		if (ASCompat.toBool(mPreloadedEffectKeys[poolKey])) {
			return;
		}
		mPreloadedEffectKeys[poolKey] = true;
		if (ASCompat.toBool(action.managed)) {
			queueEffectAtlas(fullPath, action.name);
			return;
		}
		effectName = action.name;
		queueEffectAtlas(fullPath, effectName, function() {
			prewarmEffectPool(fullPath, effectName);
		});
	}

	function queueEffectAtlas(fullPath:String, effectName:String, onComplete:ASFunction = null) {
		if (StarlingAssetMapper.isPropLibraryPath(fullPath)) {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(fullPath, [effectName], onComplete, isBackgroundLoad, backgroundLoadTier);
		} else {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(fullPath, onComplete, false, isBackgroundLoad, backgroundLoadTier);
		}
	}

	@:isVar var isBackgroundLoad(get, never):Bool;

	function get_isBackgroundLoad():Bool {
		return mActorGameObject != null && mActorGameObject.belongsToRemotePlayer;
	}

	@:isVar var backgroundLoadTier(get, never):Int;

	function get_backgroundLoadTier():Int {
		return Std.isOfType(mActorGameObject, NPCGameObject) ? 4 : 2;
	}

	function prewarmEffectPool(swfPath:String, className:String) {
		if (className.indexOf("_angle") >= 0) {
			return;
		}
		if (mDBFacade == null || mDBFacade.effectPool == null) {
			return;
		}
		var _loc3_ = ASCompat.reinterpretAs(mDBFacade.effectPool.checkout(mDBFacade, swfPath, className, null, null), EffectGameObject);
		if (_loc3_ != null) {
			mDBFacade.effectPool.checkin(_loc3_);
		}
	}

	public function updateStatsForModifiers() {
		var _loc1_:GMModifier;
		final __ax4_iter_339 = mModifiers;
		if (checkNullIteratee(__ax4_iter_339))
			for (_tmp_ in __ax4_iter_339) {
				_loc1_ = _tmp_;
				mAttackSpeedModifier[0] *= _loc1_.MELEE_SPD;
				mAttackSpeedModifier[1] *= _loc1_.SHOOT_SPD;
				mAttackSpeedModifier[2] *= _loc1_.MAGIC_SPD;
				mManaModifier *= _loc1_.MP_COST;
				mChains += _loc1_.CHAIN;
				mPierces += _loc1_.PIERCE;
				mCooldownReduction *= _loc1_.COOLDOWN_REDUC;
				mChargeReduction *= _loc1_.CHARGE_REDUC;
				mCollisionScale *= _loc1_.INCREASE_COLLISION;
			}
	}

	public function updateStatsForLegendaryModifier() {
		if (mLegendaryModifier == null) {}
	}

	public function finalWeaponSpeedWithModifiers(speedModifierIndex:Int):Float {
		return attackSpeedModifier(speedModifierIndex) * this.weaponData.Speed;
	}

	public function attackSpeedModifier(index:Int):Float {
		if (index >= 0 && index < 3) {
			return mAttackSpeedModifier[index];
		}
		return 1;
	}

	@:isVar public var manaCostModifier(get, never):Float;

	public function get_manaCostModifier():Float {
		return mManaModifier;
	}

	@:isVar public var weaponView(get, never):WeaponView;

	public function get_weaponView():WeaponView {
		return mWeaponView;
	}

	@:isVar public var actorGameObject(get, never):ActorGameObject;

	public function get_actorGameObject():ActorGameObject {
		return mActorGameObject;
	}

	@:isVar public var weaponData(get, never):GMWeaponItem;

	public function get_weaponData():GMWeaponItem {
		return mGMWeapon;
	}

	@:isVar public var weaponAesthetic(get, never):GMWeaponAesthetic;

	public function get_weaponAesthetic():GMWeaponAesthetic {
		return mWeaponAesthetic;
	}

	@:isVar public var modifierList(get, never):Vector<GMModifier>;

	public function get_modifierList():Vector<GMModifier> {
		return mModifiers;
	}

	@:isVar public var legendaryModifier(get, never):GMLegendaryModifier;

	public function get_legendaryModifier():GMLegendaryModifier {
		return mLegendaryModifier;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return mWeaponAesthetic.Name;
	}

	override public function destroy() {
		mDBFacade = null;
		mActorGameObject = null;
		mActorView = null;
		mDistributedDungeonFloor = null;
		mGMWeapon = null;
		mAttackTimelineMap.clear();
		mAttackTimelineMap = null;
		mPreloadedEffectKeys = null;
		mWeaponView.destroy();
		mWeaponView = null;
		mModifiers = null;
		super.destroy();
	}

	@:isVar public var weaponType(get, never):UInt;

	public function get_weaponType():UInt {
		return mWeaponDetails.type;
	}

	@:isVar public var power(get, never):UInt;

	public function get_power():UInt {
		return mWeaponDetails.power;
	}

	@:isVar public var slot(get, never):Int;

	public function get_slot():Int {
		return ASCompat.floatToInt(this.mSlot);
	}

	@:isVar public var requiredLevel(get, never):Int;

	public function get_requiredLevel():Int {
		return (mWeaponDetails.requiredlevel : Int);
	}

	@:isVar public var rarity(get, never):Int;

	public function get_rarity():Int {
		return (mWeaponDetails.rarity : Int);
	}

	@:isVar public var gmRarity(get, never):GMRarity;

	public function get_gmRarity():GMRarity {
		return mGMRarity;
	}

	public function chains():Float {
		return mChains;
	}

	public function pierces():Float {
		return mPierces;
	}

	public function cooldownReduction():Float {
		return mCooldownReduction;
	}

	public function chargeReduction():Float {
		return mChargeReduction;
	}

	public function collisionScale():Float {
		return mCollisionScale;
	}

	public function getAttackTimeline(attackType:UInt):AttackTimeline {
		var _loc2_ = findTimelineNameFromAttackType(attackType);
		var _loc3_ = ASCompat.coerce(mAttackTimelineMap.itemFor(_loc2_), combat.attack.AttackTimeline);
		if (_loc3_ == null) {
			_loc3_ = mDBFacade.timelineFactory.createAttackTimeline(_loc2_, this, mActorGameObject, mDistributedDungeonFloor);
			mAttackTimelineMap.add(_loc2_, _loc3_);
		}
		return _loc3_;
	}

	function findTimelineNameFromAttackType(attackType:UInt):String {
		var _loc2_ = ASCompat.coerce(mDBFacade.gameMaster.attackById.itemFor(attackType), gameMasterDictionary.GMAttack);
		if (_loc2_ == null) {
			return "";
		}
		return _loc2_.AttackTimeline;
	}

	public function isConsumable():Bool {
		return false;
	}
}
