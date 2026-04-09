package distributedObjects
;
   import actor.ActorGameObject;
   import actor.nPC.NPCView;
   import actor.stateMachine.ActorMacroStateMachine;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMPlayerScale;
   import generatedCode.DistributedNPCGameObjectNetworkComponent;
   import generatedCode.IDistributedNPCGameObject;
   
    class NPCGameObject extends ActorGameObject implements IDistributedNPCGameObject
   {
      
      var mNPCGameObjectNetworkComponent:DistributedNPCGameObjectNetworkComponent;
      
      var mGmNpc:GMNpc;
      
      var mNPCView:NPCView;
      
      var mMasterId:UInt = 0;
      
      var mMasterIsUser:Bool = false;
      
      var mTriggerState:Bool = true;
      
      var mOffNavCollisions:Vector<NavCollider>;
      
      public function new(param1:DBFacade, param2:UInt)
      {
         super(param1,param2);
         mOffNavCollisions = new Vector<NavCollider>();
      }
      
      override public function init() 
      {
         mGmNpc = ASCompat.dynamicAs(this.mDBFacade.gameMaster.npcById.itemFor(this.type), gameMasterDictionary.GMNpc);
         super.init();
         this.createOffNavCollisions(this.actorData.constant);
         this.triggerState = this.triggerState;
         tryRegisterPet();
         mArchwayAlpha = mGmNpc.ArchwayAlpha;
         initializeToFirstValidWeapon();
      }
      
      override public function  get_maxHitPoints() : Float
      {
         var _loc1_:Float = 1;
         if(this.distributedDungeonFloor != null)
         {
            _loc1_ = ASCompat.toNumber(GMPlayerScale.HPBoostByPlayers.itemFor(this.distributedDungeonFloor.numHeroes));
         }
         return super.maxHitPoints * _loc1_;
      }
      
      override public function  get_usePetUI() : Bool
      {
         return this.gmNpc.UsePetUI;
      }
      
      override public function  get_hasShowHealNumbers() : Bool
      {
         return this.gmNpc.ShowHealNumbers;
      }
      
      function tryRegisterPet() 
      {
         if(isPet && usePetUI && mMasterIsUser)
         {
            mDBFacade.hud.registerPet(this);
         }
      }
      
      @:isVar public var isUsingTeleportAI(get,never):Bool;
public function  get_isUsingTeleportAI() : Bool
      {
         return mGmNpc.UseTeleportAI;
      }
      
      @:isVar public var gmNpc(get,never):GMNpc;
public function  get_gmNpc() : GMNpc
      {
         return mGmNpc;
      }
      
      override public function  get_isAttackable() : Bool
      {
         return mGmNpc.IsAttackable && this.triggerState;
      }
      
      override public function  get_isNavigable() : Bool
      {
         return mGmNpc.IsNavigable;
      }
      
      public function setNetworkComponentDistributedNPCGameObject(param1:DistributedNPCGameObjectNetworkComponent) 
      {
         mNPCGameObjectNetworkComponent = param1;
      }
      
      override function buildView() 
      {
         var _loc1_= new NPCView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"NPCView - created in NPCGameObject.buildView()");
         view = _loc1_;
      }
      
      override function buildStateMachine() 
      {
         var _loc1_= new ActorMacroStateMachine(mDBFacade,this,this.mActorView);
         MemoryTracker.track(_loc1_,"ActorMacroStateMachine - created in NPCGameObject.buildStateMachine()");
         stateMachine = _loc1_;
      }
      
      override public function  set_view(param1:FloorView) :FloorView      {
         mNPCView = ASCompat.reinterpretAs(param1 , NPCView);
         return super.view = param1;
      }
      
      override public function destroy() 
      {
         mActorStateMachine.destroy();
         mActorStateMachine = null;
         var _loc1_:NavCollider;
         final __ax4_iter_195 = mOffNavCollisions;
         if (checkNullIteratee(__ax4_iter_195)) for (_tmp_ in __ax4_iter_195)
         {
            _loc1_ = _tmp_;
            _loc1_.destroy();
         }
         mOffNavCollisions = null;
         mNPCView = null;
         mGmNpc = null;
         mNPCGameObjectNetworkComponent = null;
         super.destroy();
      }
      
      public function weapon_down(param1:Int) 
      {
      }
      
      public function weapon_up(param1:Int) 
      {
      }
      
      override public function  get_navCollisions() : Vector<NavCollider>
      {
         if(mTriggerState)
         {
            return mNavCollisions;
         }
         return mOffNavCollisions;
      }
      
      function createOffNavCollisions(param1:String) 
      {
         var _loc2_= mDistributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.getNavCollisionTriggerOffJson(param1);
         if(_loc2_ != null)
         {
            this.processJsonNavCollisions(_loc2_,this.addOffNavCollision);
            this.offNavCollidersActive = false;
         }
      }
      
      public function addOffNavCollision(param1:NavCollider) 
      {
         if(!mWantNavCollisions)
         {
            Logger.warn("adding nav collision but wantNavCollision == false. Ignoring.");
            return;
         }
         mOffNavCollisions.push(param1);
      }
      
      public function removeOffNavColliders() 
      {
         var _loc1_:NavCollider;
         final __ax4_iter_196 = mOffNavCollisions;
         if (checkNullIteratee(__ax4_iter_196)) for (_tmp_ in __ax4_iter_196)
         {
            _loc1_ = _tmp_;
            _loc1_.destroy();
         }
         mOffNavCollisions = new Vector<NavCollider>();
      }
      
            
      @:isVar public var triggerState(get,set):Bool;
public function  get_triggerState() : Bool
      {
         return mTriggerState;
      }
      
      @:isVar public var offNavCollidersActive(never,set):Bool;
public function  set_offNavCollidersActive(param1:Bool) :Bool      {
         var _loc2_:NavCollider;
         final __ax4_iter_197 = mOffNavCollisions;
         if (checkNullIteratee(__ax4_iter_197)) for (_tmp_ in __ax4_iter_197)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty(_loc2_, "active", param1);
         }
return param1;
      }
function  set_triggerState(param1:Bool) :Bool      {
         mNPCView.triggerState = param1;
         mTriggerState = param1;
         if(mTriggerState)
         {
            this.navCollidersActive = true;
            this.offNavCollidersActive = false;
         }
         else
         {
            this.navCollidersActive = false;
            this.offNavCollidersActive = true;
         }
return param1;
      }
      
      @:isVar public var remoteTriggerState(never,set):UInt;
public function  set_remoteTriggerState(param1:UInt) :UInt      {
         triggerState = param1 > 0;
return param1;
      }
      
      override public function  get_isBlocking() : Bool
      {
         return super.isBlocking || mGmNpc.blocksNatively();
      }
      
      override public function  get_maximumDotForBlocking() : Float
      {
         return mGmNpc.BlockingDotProduct > super.maximumDotForBlocking ? mGmNpc.BlockingDotProduct : super.maximumDotForBlocking;
      }
      
            
      @:isVar public var masterId(get,set):UInt;
public function  set_masterId(param1:UInt) :UInt      {
         mMasterId = param1;
         checkIfMasterIsUser(mMasterId);
         if(this.isInitialized)
         {
            tryRegisterPet();
         }
return param1;
      }
      
      function checkIfMasterIsUser(param1:UInt) 
      {
         var _loc4_:ActorGameObject = null;
         var _loc2_= false;
         var _loc3_= mDBFacade.gameObjectManager.getReferenceFromId(param1);
         if(_loc3_ != null)
         {
            _loc4_ = ASCompat.reinterpretAs(_loc3_ , ActorGameObject);
            if(_loc4_ != null)
            {
               if(_loc4_.isOwner)
               {
                  _loc2_ = true;
               }
            }
         }
         mMasterIsUser = _loc2_;
      }
      
      public function masterIsUser() : Bool
      {
         return mMasterIsUser;
      }
function  get_masterId() : UInt
      {
         return mMasterId;
      }
   }


