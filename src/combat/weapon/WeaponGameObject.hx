package combat.weapon
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.gameObject.GameObject;
   import brain.utils.MemoryTracker;
   import combat.attack.AttackTimeline;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMLegendaryModifier;
   import gameMasterDictionary.GMModifier;
   import gameMasterDictionary.GMRarity;
   import gameMasterDictionary.GMWeaponAesthetic;
   import gameMasterDictionary.GMWeaponItem;
   import generatedCode.WeaponDetails;
   import org.as3commons.collections.Map;
   
    class WeaponGameObject extends GameObject
   {
      
      var mDBFacade:DBFacade;
      
      var mActorGameObject:ActorGameObject;
      
      var mActorView:ActorView;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mAttackTimelineMap:Map;
      
      var mWeaponCharge:Float = Math.NaN;
      
      var mWeaponDetails:WeaponDetails;
      
      var mGMWeapon:GMWeaponItem;
      
      var mGMRarity:GMRarity;
      
      var mSlot:Float = Math.NaN;
      
      var mAttackSpeedModifier:Vector<Float>;
      
      var mManaModifier:Float = Math.NaN;
      
      var mChains:Float = Math.NaN;
      
      var mPierces:Float = Math.NaN;
      
      var mCooldownReduction:Float = Math.NaN;
      
      var mChargeReduction:Float = Math.NaN;
      
      var mCollisionScale:Float = 1;
      
      var mWeaponView:WeaponView;
      
      var mModifiers:Vector<GMModifier>;
      
      var mLegendaryModifier:GMLegendaryModifier;
      
      var mWeaponAesthetic:GMWeaponAesthetic;
      
      public function new(param1:WeaponDetails, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:DistributedDungeonFloor, param6:Float)
      {
         super(param4);
         mSlot = param6;
         mDBFacade = param4;
         mWeaponCharge = 1;
         mAttackSpeedModifier = new Vector<Float>();
         mAttackSpeedModifier.push(1);
         mAttackSpeedModifier.push(1);
         mAttackSpeedModifier.push(1);
         mChains = 0;
         mPierces = 0;
         mManaModifier = 1;
         mCooldownReduction = 1;
         mChargeReduction = 1;
         mWeaponDetails = param1;
         mGMRarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mWeaponDetails.rarity), gameMasterDictionary.GMRarity);
         mActorGameObject = param2;
         mModifiers = new Vector<GMModifier>();
         if(mWeaponDetails.modifier1 > 0)
         {
            mModifiers.push(ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier1), gameMasterDictionary.GMModifier));
         }
         if(mWeaponDetails.modifier2 > 0)
         {
            mModifiers.push(ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(mWeaponDetails.modifier2), gameMasterDictionary.GMModifier));
         }
         if(mWeaponDetails.legendarymodifier > 0)
         {
            mLegendaryModifier = ASCompat.dynamicAs(mDBFacade.gameMaster.legendaryModifiersById.itemFor(mWeaponDetails.legendarymodifier), gameMasterDictionary.GMLegendaryModifier);
         }
         updateStatsForModifiers();
         updateStatsForLegendaryModifier();
         mGMWeapon = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mWeaponDetails.type), gameMasterDictionary.GMWeaponItem);
         mActorView = param3;
         mDistributedDungeonFloor = param5;
         mAttackTimelineMap = new Map();
         mWeaponAesthetic = mGMWeapon.getWeaponAesthetic((requiredLevel : UInt),mLegendaryModifier != null);
         mWeaponView = new WeaponView(mDBFacade,this);
         MemoryTracker.track(mWeaponView,"WeaponView - created in WeaponGameObject.constructor()");
      }
      
      public function updateStatsForModifiers() 
      {
         var _loc1_:GMModifier;
         final __ax4_iter_1 = mModifiers;
         if (checkNullIteratee(__ax4_iter_1)) for (_tmp_ in __ax4_iter_1)
         {
            _loc1_ = _tmp_;
            mAttackSpeedModifier[0] *= ASCompat.toNumberField(_loc1_, "MELEE_SPD");
            mAttackSpeedModifier[1] *= ASCompat.toNumberField(_loc1_, "SHOOT_SPD");
            mAttackSpeedModifier[2] *= ASCompat.toNumberField(_loc1_, "MAGIC_SPD");
            mManaModifier *= ASCompat.toNumberField(_loc1_, "MP_COST");
            mChains += ASCompat.toNumberField(_loc1_, "CHAIN");
            mPierces += ASCompat.toNumberField(_loc1_, "PIERCE");
            mCooldownReduction *= ASCompat.toNumberField(_loc1_, "COOLDOWN_REDUC");
            mChargeReduction *= ASCompat.toNumberField(_loc1_, "CHARGE_REDUC");
            mCollisionScale = ASCompat.toNumberField(_loc1_, "INCREASE_COLLISION");
         }
      }
      
      public function updateStatsForLegendaryModifier() 
      {
         if(mLegendaryModifier == null)
         {
         }
      }
      
      public function finalWeaponSpeedWithModifiers(param1:Int) : Float
      {
         return attackSpeedModifier(param1) * this.weaponData.Speed;
      }
      
      public function attackSpeedModifier(param1:Int) : Float
      {
         if(param1 >= 0 && param1 < 3)
         {
            return mAttackSpeedModifier[param1];
         }
         return 1;
      }
      
      @:isVar public var manaCostModifier(get,never):Float;
public function  get_manaCostModifier() : Float
      {
         return mManaModifier;
      }
      
      @:isVar public var weaponView(get,never):WeaponView;
public function  get_weaponView() : WeaponView
      {
         return mWeaponView;
      }
      
      @:isVar public var actorGameObject(get,never):ActorGameObject;
public function  get_actorGameObject() : ActorGameObject
      {
         return mActorGameObject;
      }
      
      @:isVar public var weaponData(get,never):GMWeaponItem;
public function  get_weaponData() : GMWeaponItem
      {
         return mGMWeapon;
      }
      
      @:isVar public var weaponAesthetic(get,never):GMWeaponAesthetic;
public function  get_weaponAesthetic() : GMWeaponAesthetic
      {
         return mWeaponAesthetic;
      }
      
      @:isVar public var modifierList(get,never):Vector<GMModifier>;
public function  get_modifierList() : Vector<GMModifier>
      {
         return mModifiers;
      }
      
      @:isVar public var legendaryModifier(get,never):GMLegendaryModifier;
public function  get_legendaryModifier() : GMLegendaryModifier
      {
         return mLegendaryModifier;
      }
      
      @:isVar public var name(get,never):String;
public function  get_name() : String
      {
         return mWeaponAesthetic.Name;
      }
      
      override public function destroy() 
      {
         mDBFacade = null;
         mActorGameObject = null;
         mActorView = null;
         mDistributedDungeonFloor = null;
         mGMWeapon = null;
         mAttackTimelineMap.clear();
         mAttackTimelineMap = null;
         mWeaponView.destroy();
         mWeaponView = null;
         mModifiers = null;
         super.destroy();
      }
      
      @:isVar public var weaponType(get,never):UInt;
public function  get_weaponType() : UInt
      {
         return mWeaponDetails.type;
      }
      
      @:isVar public var power(get,never):UInt;
public function  get_power() : UInt
      {
         return mWeaponDetails.power;
      }
      
      @:isVar public var slot(get,never):Int;
public function  get_slot() : Int
      {
         return Std.int(this.mSlot);
      }
      
      @:isVar public var requiredLevel(get,never):Int;
public function  get_requiredLevel() : Int
      {
         return (mWeaponDetails.requiredlevel : Int);
      }
      
      @:isVar public var rarity(get,never):Int;
public function  get_rarity() : Int
      {
         return (mWeaponDetails.rarity : Int);
      }
      
      @:isVar public var gmRarity(get,never):GMRarity;
public function  get_gmRarity() : GMRarity
      {
         return mGMRarity;
      }
      
      public function chains() : Float
      {
         return mChains;
      }
      
      public function pierces() : Float
      {
         return mPierces;
      }
      
      public function cooldownReduction() : Float
      {
         return mCooldownReduction;
      }
      
      public function chargeReduction() : Float
      {
         return mChargeReduction;
      }
      
      public function collisionScale() : Float
      {
         return mCollisionScale;
      }
      
      public function getAttackTimeline(param1:UInt) : AttackTimeline
      {
         var _loc2_= findTimelineNameFromAttackType(param1);
         var _loc3_= ASCompat.dynamicAs(mAttackTimelineMap.itemFor(_loc2_), combat.attack.AttackTimeline);
         if(_loc3_ == null)
         {
            _loc3_ = mDBFacade.timelineFactory.createAttackTimeline(_loc2_,this,mActorGameObject,mDistributedDungeonFloor);
            mAttackTimelineMap.add(_loc2_,_loc3_);
         }
         return _loc3_;
      }
      
      function findTimelineNameFromAttackType(param1:UInt) : String
      {
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(param1), gameMasterDictionary.GMAttack);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_.AttackTimeline;
      }
      
      public function isConsumable() : Bool
      {
         return false;
      }
   }


