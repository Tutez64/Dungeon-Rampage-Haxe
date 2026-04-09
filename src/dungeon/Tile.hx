package dungeon
;
   import actor.ActorGameObject;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import collision.LocalHeroProximitySensor;
   import distributedObjects.DistributedDungeonFloor;
   import distributedObjects.NPCGameObject;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import projectile.ChainProjectileGameObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   
    class Tile extends FloorObject
   {
      
      public static inline final TILE_WIDTH= (900 : UInt);
      
      public static inline final TILE_HEIGHT= (900 : UInt);
      
      var mNumberOfProps:UInt = 0;
      
      var mPropsAdded:UInt = (0 : UInt);
      
      var mFloorObjects:Set = new Set();
      
      var mOwnedFloorObjects:Set = new Set();
      
      var mActorGameObjects:Set = new Set();
      
      var mNPCGameObjects:Set = new Set();
      
      var mProjectileGameObjects:Set = new Set();
      
      var mBounds:Rectangle;
      
      var mBackground:Prop;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mOnStage:Bool = false;
      
      var mIsFiller:Bool = false;
      
      var mLocalHeroProximitySensors:Vector<LocalHeroProximitySensor>;
      
      public function new(param1:DBFacade, param2:UInt, param3:Bool)
      {
         super(param1);
         mIsFiller = param3;
         mBounds = new Rectangle(0,0,900,900);
         mSceneGraphComponent = new SceneGraphComponent(param1);
         mNumberOfProps = param2 + 1;
         mLocalHeroProximitySensors = new Vector<LocalHeroProximitySensor>();
         checkIfFinished();
         this.init();
      }
      
      public function isFiller() : Bool
      {
         return mIsFiller;
      }
      
      public function addOwnedFloorObject(param1:FloorObject) : Bool
      {
         return mOwnedFloorObjects.add(param1);
      }
      
      public function removeOwnedFloorObject(param1:FloorObject) : Bool
      {
         return mOwnedFloorObjects.remove(param1);
      }
      
      public function hasOwnedFloorObject(param1:FloorObject) : Bool
      {
         return mOwnedFloorObjects.has(param1);
      }
      
      override public function destroy() 
      {
         var _loc2_:FloorObject = null;
         var _loc1_= mOwnedFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
            _loc2_.destroy();
         }
         mOwnedFloorObjects.clear();
         mOwnedFloorObjects = null;
         _loc1_ = mProjectileGameObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
            _loc2_.destroy();
         }
         mProjectileGameObjects = null;
         mFloorObjects.clear();
         mFloorObjects = null;
         mActorGameObjects.clear();
         mActorGameObjects = null;
         mNPCGameObjects.clear();
         mNPCGameObjects = null;
         mBackground = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         super.destroy();
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         super.position = param1;
         mBounds.x = this.position.x;
         mBounds.y = this.position.y;
return param1;
      }
      
      @:isVar public var bounds(get,never):Rectangle;
public function  get_bounds() : Rectangle
      {
         return mBounds;
      }
      
      @:isVar public var isOnStage(get,never):Bool;
public function  get_isOnStage() : Bool
      {
         return mOnStage;
      }
      
      public function contains(param1:Float, param2:Float) : Bool
      {
         return mBounds.contains(param1,param2);
      }
      
      public function containsPoint(param1:Vector3D) : Bool
      {
         return mBounds.containsPoint(new Point(param1.x,param1.y));
      }
      
      @:isVar public var floorObjects(get,never):Set;
public function  get_floorObjects() : Set
      {
         return mFloorObjects;
      }
      
      @:isVar public var actorGameObjects(get,never):Set;
public function  get_actorGameObjects() : Set
      {
         return mActorGameObjects;
      }
      
      @:isVar public var NPCGameObjects(get,never):Set;
public function  get_NPCGameObjects() : Set
      {
         return mNPCGameObjects;
      }
      
      function checkIfFinished() 
      {
         if(mPropsAdded == mNumberOfProps)
         {
         }
      }
      
      public function expandBounds(param1:FloorObject) 
      {
         mBounds = mBounds.union(param1.view.root.getBounds(mFacade.sceneGraphManager.worldTransformNode));
      }
      
      public function addFloorObject(param1:FloorObject) 
      {
         mFloorObjects.add(param1);
         if(Std.isOfType(param1 , ActorGameObject))
         {
            mActorGameObjects.add(param1);
         }
         if(Std.isOfType(param1 , NPCGameObject))
         {
            mNPCGameObjects.add(param1);
         }
         if(Std.isOfType(param1 , ChainProjectileGameObject))
         {
            mProjectileGameObjects.add(param1);
         }
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
         if(mOnStage)
         {
            param1.view.addToStage();
         }
         else
         {
            param1.view.removeFromStage();
         }
      }
      
      public function removeFloorObject(param1:FloorObject) 
      {
         if(mFloorObjects != null)
         {
            mFloorObjects.remove(param1);
         }
         if(Std.isOfType(param1 , ActorGameObject) && mActorGameObjects != null)
         {
            mActorGameObjects.remove(param1);
         }
         if(Std.isOfType(param1 , NPCGameObject) && mNPCGameObjects != null)
         {
            mNPCGameObjects.remove(param1);
         }
         if(Std.isOfType(param1 , ChainProjectileGameObject) && mProjectileGameObjects != null)
         {
            mProjectileGameObjects.remove(param1);
         }
      }
      
      public function ignoredAProp() 
      {
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
      }
      
            
      @:isVar public var background(get,set):Prop;
public function  set_background(param1:Prop) :Prop      {
         mBackground = param1;
         if(mOnStage)
         {
            mSceneGraphComponent.addChildAt(mBackground.view.root,(5 : UInt),(0 : UInt));
         }
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
return param1;
      }
function  get_background() : Prop
      {
         return mBackground;
      }
      
      public function addToStage() 
      {
         var _loc2_:FloorObject = null;
         if(mOnStage)
         {
            return;
         }
         var _loc1_= mFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
            if(_loc2_.view == null)
            {
               Logger.warn("floorObject with null view attempted addToStage id: " + _loc2_.id);
            }
            else
            {
               _loc2_.view.addToStage();
            }
         }
         if(mBackground != null)
         {
            mBackground.view.root.parent.setChildIndex(mBackground.view.root,0);
         }
         mOnStage = true;
      }
      
      public function removeFromStage() 
      {
         var _loc2_:FloorObject = null;
         if(!mOnStage)
         {
            return;
         }
         var _loc1_= mFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
            if(_loc2_.view == null)
            {
               Logger.warn("floorObject with null view attempted removeFromStage id: " + _loc2_.id);
            }
            else
            {
               _loc2_.view.removeFromStage();
            }
         }
         mOnStage = false;
      }
      
      public function createLocalEventCollision(param1:DistributedDungeonFloor, param2:UInt, param3:UInt, param4:UInt, param5:Bool, param6:ASFunction) 
      {
         mLocalHeroProximitySensors.push(new LocalHeroProximitySensor(mDBFacade,param1,(Std.int(this.position.x + param2) : UInt),(Std.int(this.position.y + param3) : UInt),param4,param5,param6));
      }
   }


