package projectile
;
   import actor.ActorGameObject;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Fixture;
   import brain.utils.MemoryTracker;
   import combat.CombatGameObject;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.DistributedDungeonFloor;
   import distributedObjects.NPCGameObject;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   
    class ChainProjectileGameObject extends ProjectileGameObject
   {
      
      static inline final DEFAULT_CHAIN_CHECK_DISTANCE:Float = 300;
      
      static inline final DEFAULT_NUM_BRANCHES= (1 : UInt);
      
      var mMaxBranches:UInt = (3 : UInt);
      
      var mNumBranches:UInt = (0 : UInt);
      
      var mMaxChain:UInt = (2 : UInt);
      
      var mNumChains:UInt = (0 : UInt);
      
      var mEnvironmentTargets:Vector<NPCGameObject>;
      
      var mEnemyTargets:Vector<NPCGameObject>;
      
      var mIgnoreList:Set;
      
      var mChainCheckDistance:Float = 0;
      
      var mActorJustHit:ActorGameObject;
      
      public function new(param1:DBFacade, param2:UInt, param3:UInt, param4:UInt, param5:WeaponGameObject, param6:DistributedDungeonFloor, param7:Vector3D, param8:Vector3D, param9:Vector3D, param10:Float = 0, param11:UInt = (0 : UInt), param12:Set = null, param13:ASObject = null, param14:ASFunction = null, param15:Bool = true, param16:Bool = false)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param13,param14,param15,param16,param11);
         mNumChains = param11;
         if(param12 == null)
         {
            mIgnoreList = new Set();
         }
         else
         {
            mIgnoreList = param12;
         }
         var _loc17_= (Std.int(param5 != null ? (Std.int(param5.chains()) : UInt) : (0 : UInt)) : UInt);
         mMaxChain = mGMProjectile.NumChains + _loc17_;
         mMaxBranches = (ASCompat.toInt(mGMProjectile.NumBranches > 0 ? mGMProjectile.NumBranches : (1 : UInt)) : UInt);
         mChainCheckDistance = mGMProjectile.ChainDist > 0 ? mGMProjectile.ChainDist : 300;
      }
      
      override function hitActor(param1:ActorGameObject) : Bool
      {
         var _loc2_:B2Transform = null;
         mActorJustHit = param1;
         if(mIgnoreList.has(param1.id))
         {
            return false;
         }
         if(super.hitActor(param1))
         {
            if(mNumChains < mMaxChain)
            {
               mIgnoreList.add(param1.id);
               _loc2_ = new B2Transform();
               _loc2_.position = NavCollider.convertToB2Vec2(this.position);
               mEnvironmentTargets = new Vector<NPCGameObject>();
               mEnemyTargets = new Vector<NPCGameObject>();
               this.mDistributedDungeonFloor.box2DWorld.QueryShape(collisionCallback,new B2CircleShape(mChainCheckDistance / 50),_loc2_);
               processTargets();
            }
         }
         if(mCollisionComponent.markedForDeletion())
         {
            this.destroy();
         }
         return true;
      }
      
      function collisionCallback(param1:B2Fixture) : Bool
      {
         var _loc3_= mDistributedDungeonFloor.getActor(mParentActorId);
         if(_loc3_ == null)
         {
            return false;
         }
         var _loc2_= ASCompat.asUint(param1.GetBody().GetUserData() );
         var _loc4_= ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(_loc2_) , NPCGameObject);
         if(_loc4_ != null && mActorJustHit.id != _loc4_.id && _loc4_.isAttackable && (!mIgnoreList.has(_loc4_.id) || mGMProjectile.CyclicChains))
         {
            if(mFlightComponent.isTargetableTeam((_loc4_.team : UInt)))
            {
               if(!CombatGameObject.didAttackGoThroughWall(mDBFacade,mB2Body.GetPosition(),_loc4_,NavCollider.convertToB2Vec2(_loc4_.worldCenter),mDistributedDungeonFloor))
               {
                  if(_loc4_.team == 1)
                  {
                     mEnvironmentTargets.push(_loc4_);
                  }
                  else
                  {
                     mEnemyTargets.push(_loc4_);
                  }
               }
            }
         }
         if(mNumBranches >= mMaxBranches)
         {
            return false;
         }
         return true;
      }
      
      function processTargets() 
      {
         ASCompat.ASVector.sort(mEnemyTargets, sortByDistance);
         processNewChains(mEnemyTargets);
         ASCompat.ASVector.sort(mEnvironmentTargets, sortByDistance);
         processNewChains(mEnvironmentTargets);
      }
      
      function sortByDistance(param1:NPCGameObject, param2:NPCGameObject) : Float
      {
         var _loc3_= new B2Vec2();
         _loc3_.x = mActorJustHit.worldCenterAsb2Vec2.x;
         _loc3_.y = mActorJustHit.worldCenterAsb2Vec2.y;
         _loc3_.Subtract(param1.worldCenterAsb2Vec2);
         var _loc4_= new B2Vec2();
         _loc4_.x = mActorJustHit.worldCenterAsb2Vec2.x;
         _loc4_.y = mActorJustHit.worldCenterAsb2Vec2.y;
         _loc4_.Subtract(param2.worldCenterAsb2Vec2);
         return _loc3_.LengthSquared() - _loc4_.LengthSquared();
      }
      
      function processNewChains(param1:Vector<NPCGameObject>) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if(mNumBranches >= mMaxBranches)
            {
               return;
            }
            shootNewChain(param1[_loc2_]);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function shootNewChain(param1:NPCGameObject) 
      {
         mNumBranches = mNumBranches + 1;
         var _loc3_= param1.view.position.subtract(this.position);
         _loc3_.normalize();
         var _loc2_= new ChainProjectileGameObject(mDBFacade,mParentActorId,mParentActorTeam,mAttackType,mWeaponGameObject,this.mDistributedDungeonFloor,mActorJustHit.position,_loc3_,new Vector3D(0,0),mRange,mNumChains + 1,mIgnoreList,mEffectObject,mCombatResultCallback,false);
         MemoryTracker.track(_loc2_,"ChainProjectileGameObject - created in ChainProjectileGameObject.shootNewChain()");
      }
   }


