package distributedObjects
;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2BodyDef;
   import box2D.dynamics.B2FixtureDef;
   import box2D.dynamics.B2World;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import collision.ContactListener;
   import collision.DBBox2DVisualizer;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import dr_floor.DungeonModifierHelper;
   import dr_floor.FloorEndingGui;
   import gameMasterDictionary.GMMapNode;
   import generatedCode.DungeonModifier;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Vector3D;
   
    class Floor extends GameObject
   {
      
      public static inline final FLOOR_INTEREST_CLOSURE= "FLOOR_INTEREST_CLOSURE";
      
      public static inline final BOX2D_SCALE:Float = 50;
      
      static inline final POSITION_ITERATIONS= (3 : UInt);
      
      static inline final VELOCITY_ITERATIONS= (8 : UInt);
      
      var mParentArea:Area;
      
      var mB2World:B2World;
      
      var mFloorBody:B2Body;
      
      var mBox2DDebugSprite:Sprite;
      
      var mBox2DVisualizer:DBBox2DVisualizer;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mDBFacade:DBFacade;
      
      var mContactListener:ContactListener;
      
      public var pastInitialLoad:Bool = false;
      
      var mFloorEndingGui:FloorEndingGui;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mEventComponent:EventComponent;
      
      var mPhysicsUpdateTask:Task;
      
      var mActiveDungeonModifiers:Vector<DungeonModifierHelper>;
      
      var mIsADefeat:Bool = false;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         var floorBodyDef:B2BodyDef;
         var wantAllCollisions:Bool;
         var showCombatCollisions:Bool;
         var showNavCollisions:Bool;
         var showAStarVisuals:Bool;
         var dbFacade= param1;
         var remoteId= param2;
         super(dbFacade,remoteId);
         mActiveDungeonModifiers = new Vector<DungeonModifierHelper>();
         mDBFacade = dbFacade;
         pastInitialLoad = false;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"Floor");
         mB2World = new B2World(NavCollider.convertToB2Vec2(new Vector3D(0,0)),true);
         mContactListener = new ContactListener(mDBFacade);
         mB2World.SetContactListener(mContactListener);
         floorBodyDef = new B2BodyDef();
         floorBodyDef.type = B2Body.b2_staticBody;
         floorBodyDef.allowSleep = true;
         floorBodyDef.position = NavCollider.convertToB2Vec2(new Vector3D(0,0));
         mFloorBody = mB2World.CreateBody(floorBodyDef);
         mFloorBody.SetUserData(this.id);
         buildWalls();
         mPhysicsUpdateTask = mDBFacade.physicsWorkManager.doEveryFrame(update,"Floor");
         wantAllCollisions = mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_all_colliders",false);
         showCombatCollisions = mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_combat_colliders",false);
         showNavCollisions = mDBFacade.showCollisions || mDBFacade.dbConfigManager.getConfigBoolean("show_navigation_colliders",false);
         showAStarVisuals = mDBFacade.dbConfigManager.getConfigBoolean("show_astar_colliders",false);
         if(wantAllCollisions || showCombatCollisions || showNavCollisions || showAStarVisuals)
         {
            mBox2DVisualizer = new DBBox2DVisualizer(mDBFacade,mB2World,wantAllCollisions,showCombatCollisions,showNavCollisions,showAStarVisuals);
         }
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"Floor");
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener(HeroGameObjectOwner.HERO_OWNER_READY,function(param1:Event)
         {
            floorStart();
         });
         mSceneGraphComponent.fadeIn(1);
      }
      
      function buildFloorEndingGui() 
      {
         mFloorEndingGui = new FloorEndingGui(this,gmMapNode.NodeType,mDBFacade);
      }
      
      @:isVar public var activeGMDungeonModifiers(get,never):Vector<DungeonModifierHelper>;
public function  get_activeGMDungeonModifiers() : Vector<DungeonModifierHelper>
      {
         return mActiveDungeonModifiers;
      }
      
      @:isVar public var activeDungeonModifiers(never,set):Vector<DungeonModifier>;
public function  set_activeDungeonModifiers(param1:Vector<DungeonModifier>) :Vector<DungeonModifier>      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            mActiveDungeonModifiers.push(new DungeonModifierHelper(param1[_loc2_].id,param1[_loc2_].new_this_floor == 1,mDBFacade));
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
return param1;
      }
      
      public function getCurrentFloorNum() : UInt
      {
         return (0 : UInt);
      }
      
      public function getMaxFloorNum() : UInt
      {
         return (0 : UInt);
      }
      
      public function floorEnding(param1:UInt) 
      {
         mFloorEndingGui.floorEnding(param1);
      }
      
      public function floorFailing(param1:UInt) 
      {
         mFloorEndingGui.floorFailing(param1);
      }
      
      public function victory() 
      {
         mFloorEndingGui.dungeonVictory();
      }
      
      public function defeat() 
      {
         mIsADefeat = true;
         mFloorEndingGui.dungeonFailure();
      }
      
      public function floorStart() 
      {
         mFloorEndingGui.floorStart();
      }
      
      @:isVar public var debugVisualizer(get,never):DBBox2DVisualizer;
public function  get_debugVisualizer() : DBBox2DVisualizer
      {
         return mBox2DVisualizer;
      }
      
      @:isVar public var box2DWorld(get,never):B2World;
public function  get_box2DWorld() : B2World
      {
         return mB2World;
      }
      
      @:isVar public var isADefeat(get,never):Bool;
public function  get_isADefeat() : Bool
      {
         return mIsADefeat;
      }
      
      function update(param1:GameClock) 
      {
         mB2World.Step(param1.tickLength,8,3);
         mContactListener.processCollisions();
      }
      
      function buildWalls() 
      {
         var _loc7_= new B2FixtureDef();
         var _loc8_= new B2PolygonShape();
         _loc8_.SetAsEdge(NavCollider.convertToB2Vec2(new Vector3D(0,0)),NavCollider.convertToB2Vec2(new Vector3D(12 * 900,0)));
         _loc7_.shape = _loc8_;
         var _loc2_= new B2FixtureDef();
         var _loc1_= new B2PolygonShape();
         _loc1_.SetAsEdge(NavCollider.convertToB2Vec2(new Vector3D(0,12 * 900)),NavCollider.convertToB2Vec2(new Vector3D(12 * 900,12 * 900)));
         _loc2_.shape = _loc1_;
         var _loc6_= new B2FixtureDef();
         var _loc3_= new B2PolygonShape();
         _loc3_.SetAsEdge(NavCollider.convertToB2Vec2(new Vector3D(0,0)),NavCollider.convertToB2Vec2(new Vector3D(0,12 * 900)));
         _loc6_.shape = _loc3_;
         var _loc4_= new B2FixtureDef();
         var _loc5_= new B2PolygonShape();
         _loc5_.SetAsEdge(NavCollider.convertToB2Vec2(new Vector3D(12 * 900,0)),NavCollider.convertToB2Vec2(new Vector3D(12 * 900,12 * 900)));
         _loc4_.shape = _loc5_;
         mFloorBody.CreateFixture(_loc7_);
         mFloorBody.CreateFixture(_loc2_);
         mFloorBody.CreateFixture(_loc6_);
         mFloorBody.CreateFixture(_loc4_);
      }
      
      public function SetParentArea(param1:Area) 
      {
         mParentArea = param1;
      }
      
      @:isVar public var parentArea(get,never):Area;
public function  get_parentArea() : Area
      {
         return mParentArea;
      }
      
      override public function destroy() 
      {
         if(mParentArea != null)
         {
            mParentArea.FloorIsLeaving(this);
            mParentArea = null;
         }
         if(mBox2DVisualizer != null)
         {
            mBox2DVisualizer.destroy();
            mBox2DVisualizer = null;
         }
         mFloorEndingGui.destroy();
         mFloorEndingGui = null;
         mDBFacade.hud.hide();
         mEventComponent.destroy();
         mEventComponent = null;
         if(mPhysicsUpdateTask != null)
         {
            mPhysicsUpdateTask.destroy();
            mPhysicsUpdateTask = null;
         }
         mFloorBody.SetUserData(null);
         mB2World.DestroyBody(mFloorBody);
         mFloorBody = null;
         mB2World = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSceneGraphComponent.cleanBackgroundLayer();
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mDBFacade = null;
         super.destroy();
      }
      
      public function addCollectedTreasure(param1:UInt) 
      {
         mParentArea.addCollectedTreasure(param1);
      }
      
      @:isVar public var treasureCollected(get,never):Vector<UInt>;
public function  get_treasureCollected() : Vector<UInt>
      {
         return mParentArea.treasureCollected;
      }
      
      public function addCollectedExp(param1:UInt) 
      {
         mParentArea.addCollectedExp(param1);
      }
      
      @:isVar public var expCollected(get,never):UInt;
public function  get_expCollected() : UInt
      {
         return mParentArea.expCollected;
      }
      
      @:isVar public var gmMapNode(get,never):GMMapNode;
public function  get_gmMapNode() : GMMapNode
      {
         Logger.error("Should call overriden function");
         return null;
      }
      
      override public function InterestClosure() 
      {
         pastInitialLoad = true;
         mEventComponent.dispatchEvent(new Event("FLOOR_INTEREST_CLOSURE"));
      }
      
      @:isVar public var isInfiniteDungeon(get,never):Bool;
public function  get_isInfiniteDungeon() : Bool
      {
         return false;
      }
   }


