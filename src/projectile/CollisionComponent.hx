package projectile
;
   import actor.ActorGameObject;
   import brain.logger.Logger;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import combat.CombatGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import generatedCode.Attack;
   import generatedCode.CombatResult;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class CollisionComponent
   {
      
      var mDBFacade:DBFacade;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mProjectile:ProjectileGameObject;
      
      var mParentActorId:UInt = 0;
      
      var mDungeonFloor:DistributedDungeonFloor;
      
      var mUpdatedVelocity:Bool = false;
      
      var mNumCollisions:UInt = 0;
      
      var mCombatResultCallback:ASFunction;
      
      var mWeaponType:UInt = 0;
      
      var mWeaponPower:UInt = 0;
      
      var mWeaponSlot:Int = 0;
      
      var mActorCollisions:Map;
      
      var mHitsPerActor:UInt = 0;
      
      var mHitRecurDelay:Float = Math.NaN;
      
      var mMaxCollisions:UInt = 0;
      
      var mRecurringHitDelayTasks:Map;
      
      var mGMAttack:GMAttack;
      
      var mGeneration:UInt = 0;
      
      var mDontTrackGenerations:Bool = false;
      
      var mIsPierceProjectile:Bool = false;
      
      var mMarkedForDeletion:Bool = false;
      
      public function new(param1:DBFacade, param2:ProjectileGameObject, param3:UInt, param4:DistributedDungeonFloor, param5:UInt, param6:UInt, param7:GMAttack, param8:ASFunction, param9:Int, param10:Float, param11:Bool, param12:UInt = (0 : UInt))
      {
         
         mDBFacade = param1;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"CollisionComponent");
         mDungeonFloor = param4;
         mNumCollisions = (0 : UInt);
         mDontTrackGenerations = param2.gmProjectile.NoGenerations;
         mGeneration = (ASCompat.toInt(mDontTrackGenerations ? (0 : UInt) : param12) : UInt);
         mProjectile = param2;
         mParentActorId = param3;
         mCombatResultCallback = param8;
         mUpdatedVelocity = false;
         mWeaponType = param5;
         mWeaponPower = param6;
         mWeaponSlot = param9;
         mActorCollisions = new Map();
         mHitRecurDelay = mProjectile.gmProjectile.HitRecurDelay;
         mHitsPerActor = (Std.int(mProjectile.gmProjectile.HitsPerActor) : UInt);
         mMaxCollisions = (Std.int(mProjectile.gmProjectile.MaxCollisions + param10) : UInt);
         mRecurringHitDelayTasks = new Map();
         mGMAttack = param7;
         mIsPierceProjectile = param11;
      }
      
      @:isVar public var numCollisions(get,never):UInt;
public function  get_numCollisions() : UInt
      {
         return mNumCollisions;
      }
      
      @:isVar public var updatedVelocity(get,never):Bool;
public function  get_updatedVelocity() : Bool
      {
         return mUpdatedVelocity;
      }
      
      public function destroy() 
      {
         var _loc3_:Task = null;
         var _loc2_= 0;
         mDungeonFloor = null;
         mCombatResultCallback = null;
         var _loc1_= ASCompat.reinterpretAs(mRecurringHitDelayTasks.iterator() , IMapIterator);
         while(ASCompat.toBool(_loc1_.next()))
         {
            _loc2_ = (ASCompat.asUint(_loc1_.key ) : Int);
            _loc3_ = ASCompat.dynamicAs(mRecurringHitDelayTasks.itemFor(_loc2_) , Task);
            if(_loc3_ != null)
            {
               _loc3_.destroy();
            }
         }
         mRecurringHitDelayTasks.clear();
         mRecurringHitDelayTasks = null;
         mActorCollisions.clear();
         mActorCollisions = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
      }
      
      public function hitWall() 
      {
         mProjectile.onHitWall();
         mProjectile.destroy();
      }
      
      public function hitActor(param1:ActorGameObject) : Bool
      {
         var _loc2_= 0;
         var _loc6_= Math.NaN;
         var _loc3_= Math.NaN;
         mProjectile.onHitActor(param1);
         var _loc5_= ASCompat.dynamicAs(mActorCollisions.itemFor(param1.id) , CollisionHelper);
         if(_loc5_ != null)
         {
            _loc5_ = ASCompat.dynamicAs(mActorCollisions.itemFor(param1.id) , CollisionHelper);
            _loc2_ = (_loc5_.hits : Int);
            if((_loc2_ : UInt) >= mHitsPerActor)
            {
               return false;
            }
         }
         if(_loc5_ != null)
         {
            _loc6_ = _loc5_.lastHitTime + mHitRecurDelay * 1000;
            if(mDBFacade.gameClock.gameTime < _loc6_)
            {
               _loc3_ = _loc6_ - mDBFacade.gameClock.gameTime;
               addRecurringHitDelayTask(param1,_loc3_ / 1000);
               return false;
            }
         }
         else
         {
            _loc5_ = new CollisionHelper(param1.id);
         }
         if(!mActorCollisions.hasKey(param1.id))
         {
            mActorCollisions.add(param1.id,_loc5_);
         }
         _loc5_.hits++;
         _loc5_.lastHitTime = mDBFacade.gameClock.gameTime;
         mNumCollisions = mNumCollisions + 1;
         var _loc7_= new CombatResult();
         var _loc4_= new Attack();
         _loc4_.attackType = mProjectile.gmAttack.Id;
         _loc4_.weaponSlot = this.mWeaponSlot;
         _loc7_.attacker = mParentActorId;
         _loc7_.attack = _loc4_;
         _loc7_.attackee = param1.id;
         _loc7_.damage = 0;
         _loc7_.generation = (ASCompat.toInt(mDontTrackGenerations ? (0 : UInt) : mNumCollisions + mGeneration - 1) : UInt);
         if(param1.isBlocking && !mGMAttack.Unblockable)
         {
            if(CombatGameObject.blockCheck(param1.getHeadingAsVector(),param1.maximumDotForBlocking,param1.worldCenter,mProjectile.worldCenter))
            {
               _loc7_.blocked = (1 : UInt);
            }
            else
            {
               _loc7_.blocked = (0 : UInt);
            }
         }
         if(_loc7_.blocked == 1)
         {
            _loc7_.knockback = (0 : UInt);
            _loc7_.suffer = (0 : UInt);
         }
         else
         {
            _loc7_.knockback = (Std.int(mProjectile.gmAttack.Knockback) : UInt);
            if(_loc7_.knockback != 0)
            {
               _loc7_.suffer = (1 : UInt);
            }
            else
            {
               _loc7_.suffer = (Math.random() <= mProjectile.gmAttack.StunChance ? (1 : UInt) : (0 : UInt) : UInt);
            }
         }
         if(mCombatResultCallback != null)
         {
            mCombatResultCallback(_loc7_);
         }
         if(mHitsPerActor > (_loc2_ : UInt) && mNumCollisions < mMaxCollisions)
         {
            addRecurringHitDelayTask(param1,mHitRecurDelay);
         }
         if(mNumCollisions >= mMaxCollisions || param1.hasAbility((16777216 : UInt)) && mIsPierceProjectile)
         {
            mMarkedForDeletion = true;
         }
         return true;
      }
      
      function handleRecurringHitDelay(param1:ActorGameObject, param2:UInt) 
      {
         if(mRecurringHitDelayTasks == null)
         {
            Logger.error("Error in handleRecurringHitDelay.  mRecurringHitDelayTasks is not being cleaned up correctly.");
            return;
         }
         mRecurringHitDelayTasks.removeKey(param2);
         if(param1 != null && !param1.isDestroyed)
         {
            hitActor(param1);
         }
      }
      
      public function exitContact(param1:UInt) 
      {
         var _loc2_= ASCompat.dynamicAs(mRecurringHitDelayTasks.itemFor(param1), brain.workLoop.Task);
         if(_loc2_ != null)
         {
            _loc2_.destroy();
            mRecurringHitDelayTasks.removeKey(param1);
         }
      }
      
      function addRecurringHitDelayTask(param1:ActorGameObject, param2:Float) 
      {
         var actor= param1;
         var delayForNextHitInSeconds= param2;
         var recurringHitTask= ASCompat.dynamicAs(mRecurringHitDelayTasks.removeKey(actor.id), brain.workLoop.Task);
         if(recurringHitTask != null)
         {
            recurringHitTask.destroy();
         }
         if(delayForNextHitInSeconds > 0)
         {
            recurringHitTask = mLogicalWorkComponent.doLater(delayForNextHitInSeconds,function(param1:brain.clock.GameClock)
            {
               if(actor != null && !actor.isDestroyed)
               {
                  handleRecurringHitDelay(actor,actor.id);
               }
            });
            mRecurringHitDelayTasks.add(actor.id,recurringHitTask);
         }
         else
         {
            hitActor(actor);
         }
      }
      
      public function markedForDeletion() : Bool
      {
         return mMarkedForDeletion;
      }
   }


private class CollisionHelper
{
   
   public var hits:UInt = 0;
   
   public var actorId:UInt = 0;
   
   public var lastHitTime:Int = 0;
   
   public function new(param1:UInt)
   {
      
      hits = (0 : UInt);
      lastHitTime = 0;
      actorId = param1;
   }
}
