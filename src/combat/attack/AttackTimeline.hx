package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import effects.ChargeEffectGameObject;
   import effects.EffectGameObject;
   import facade.DBFacade;
   import generatedCode.AttackChoreography;
   import generatedCode.CombatResult;
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class AttackTimeline extends ScriptTimeline
   {
      
      var mCombatResultActions:Map;
      
      var mAttackName:String;
      
      var mWeapon:WeaponGameObject;
      
      var mChoreographed:Bool = false;
      
      var mRegisteredEffects:Map;
      
      var mChargeEffect:ChargeEffectGameObject;
      
      var mPowerMultiplier:Float = 1;
      
      var mProjectileMultiplier:UInt = (1 : UInt);
      
      var mProjectileScalingAngle:Float = 20;
      
      var mDistanceScalingTime:Float = 0;
      
      var mDistanceScalingForHero:Float = 0;
      
      var mDistanceScalingForProjectiles:Float = 0;
      
      public function new(param1:WeaponGameObject, param2:ActorGameObject, param3:ActorView, param4:ASObject, param5:DBFacade, param6:DistributedDungeonFloor)
      {
         mWeapon = param1;
         super(param2,param3,param4,param5,param6);
         mCombatResultActions = new Map();
         mRegisteredEffects = new Map();
         mAttackName = param4.attackName;
         mChoreographed = ASCompat.toBool(param4.choreographed);
      }
      
      override public function destroy() 
      {
         this.cleanUpRegisteredEffects();
         mRegisteredEffects.clear();
         mRegisteredEffects = null;
         mCombatResultActions.clear();
         mCombatResultActions = null;
         mWeapon = null;
         super.destroy();
      }
      
      @:isVar public var weapon(get,never):WeaponGameObject;
public function  get_weapon() : WeaponGameObject
      {
         return mWeapon;
      }
      
      override public function  get_attackName() : String
      {
         return mAttackName;
      }
      
      @:isVar public var totalFrames(get,never):UInt;
public function  get_totalFrames() : UInt
      {
         return mTotalFrames;
      }
      
      public function isAttackWithinComboWindow() : Bool
      {
         var _loc1_= (Std.int(currentGMAttack.ComboWindow * mTotalFrames) : UInt);
         var _loc2_= (mLastExecutedFrame : UInt);
         if(_loc2_ >= _loc1_)
         {
            return true;
         }
         return false;
      }
      
      override function parseAction(param1:ASObject) : AttackTimelineAction
      {
         var _loc3_= ASCompat.asString(param1.type );
         var _loc2_:AttackTimelineAction = null;
         switch(_loc3_)
         {
            case "attackEffect":
               _loc2_ = PlayEffectAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,param1,mWeapon,registerEffect);
               
            case "projectile":
               _loc2_ = ProjectileAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,mDistributedDungeonFloor,param1,mWeapon);
               
            case "automove":
               _loc2_ = AutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               
            case "attackautomove":
               _loc2_ = AttackAutoMoveTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               
            case "block":
               _loc2_ = BlockAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,param1);
               
            default:
               return super.parseAction(param1);
         }
         return _loc2_;
      }
      
      override function processTimelineActions(param1:Int, param2:GameClock) 
      {
         super.processTimelineActions(param1,param2);
         processTimelineFrame(mCombatResultActions,param1,param2);
      }
      
      override public function stop() 
      {
         super.stop();
         cleanUpRegisteredEffects();
      }
      
      function cleanUpRegisteredEffects() 
      {
         var _loc2_:EffectGameObject = null;
         var _loc1_= ASCompat.reinterpretAs(mRegisteredEffects.iterator() , IMapIterator);
         while(ASCompat.toBool(_loc1_.next()))
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.current , EffectGameObject);
            _loc2_.destroy();
         }
         mRegisteredEffects.clear();
         if(mChargeEffect != null)
         {
            mChargeEffect.destroy();
            mChargeEffect = null;
         }
      }
      
      public function appendChoreography(param1:AttackChoreography) 
      {
         var _loc2_:CombatResultAttackTimelineAction = null;
         var _loc4_:LinkedList = null;
         var _loc5_:ASAny = 0;
         var _loc3_:CombatResult;
         final __ax4_iter_40 = param1.combatResults;
         if (checkNullIteratee(__ax4_iter_40)) for (_tmp_ in __ax4_iter_40)
         {
            _loc3_ = _tmp_;
            _loc5_ = _loc3_.when;
            _loc2_ = new CombatResultAttackTimelineAction(mActorGameObject,mActorView,mDBFacade,_loc3_,mDistributedDungeonFloor);
            if(mCombatResultActions.hasKey(_loc5_))
            {
               _loc4_ = ASCompat.dynamicAs(mCombatResultActions.itemFor(_loc5_), org.as3commons.collections.LinkedList);
               _loc4_.add(_loc2_);
            }
            else
            {
               _loc4_ = new LinkedList();
               _loc4_.add(_loc2_);
               mCombatResultActions.add(_loc5_,_loc4_);
            }
         }
      }
      
      public function registerEffect(param1:EffectGameObject) 
      {
         if(Std.isOfType(param1 , ChargeEffectGameObject))
         {
            if(mChargeEffect != null)
            {
               Logger.error("Trying to register more than one charge effect on timeline.");
               mRegisteredEffects.removeKey(mChargeEffect.id);
               mChargeEffect.destroy();
               mChargeEffect = null;
               return;
            }
            mChargeEffect = ASCompat.reinterpretAs(param1 , ChargeEffectGameObject);
         }
         mRegisteredEffects.add(param1.id,param1);
      }
      
      @:isVar public var chargeEffect(get,never):ChargeEffectGameObject;
public function  get_chargeEffect() : ChargeEffectGameObject
      {
         return mChargeEffect;
      }
      
            
      @:isVar public var powerMultiplier(get,set):Float;
public function  set_powerMultiplier(param1:Float) :Float      {
         return mPowerMultiplier = param1;
      }
function  get_powerMultiplier() : Float
      {
         return mPowerMultiplier;
      }
      
            
      @:isVar public var projectileMultiplier(get,set):UInt;
public function  set_projectileMultiplier(param1:UInt) :UInt      {
         return mProjectileMultiplier = param1;
      }
function  get_projectileMultiplier() : UInt
      {
         return mProjectileMultiplier;
      }
      
            
      @:isVar public var projectileScalingAngle(get,set):UInt;
public function  set_projectileScalingAngle(param1:UInt) :UInt      {
         mProjectileScalingAngle = param1;
return param1;
      }
function  get_projectileScalingAngle() : UInt
      {
         return (Std.int(mProjectileScalingAngle) : UInt);
      }
      
            
      @:isVar public var distanceScalingTime(get,set):Float;
public function  set_distanceScalingTime(param1:Float) :Float      {
         return mDistanceScalingTime = param1;
      }
function  get_distanceScalingTime() : Float
      {
         return mDistanceScalingTime;
      }
      
            
      @:isVar public var distanceScalingHero(get,set):Float;
public function  set_distanceScalingHero(param1:Float) :Float      {
         return mDistanceScalingForHero = param1;
      }
function  get_distanceScalingHero() : Float
      {
         return mDistanceScalingForHero;
      }
      
            
      @:isVar public var distanceScalingProjectile(get,set):Float;
public function  set_distanceScalingProjectile(param1:Float) :Float      {
         return mDistanceScalingForProjectiles = param1;
      }
function  get_distanceScalingProjectile() : Float
      {
         return mDistanceScalingForProjectiles;
      }
   }


