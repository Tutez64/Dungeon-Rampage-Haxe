package dr_floor
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2FilterData;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import distributedObjects.DistributedDungeonFloor;
   import dungeon.NavCollider;
   import dungeon.Tile;
   import facade.DBFacade;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
    class FloorObject extends GameObject
   {
      
      var mPosition:Vector3D = new Vector3D();
      
      var mFloorView:FloorView;
      
      var mTile:Tile;
      
      var mArchwayAlpha:Bool = false;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mWantNavCollisions:Bool = true;
      
      var mNavCollisions:Vector<NavCollider>;
      
      var mLayer:Int = 0;
      
      var mDBFacade:DBFacade;
      
      var mFilter:B2FilterData;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
         mNavCollisions = new Vector<NavCollider>();
         mDBFacade = param1;
         buildView();
      }
      
      override public function init() 
      {
         super.init();
         mFloorView.init();
      }
      
      @:isVar public var wantNavCollision(get,never):Bool;
public function  get_wantNavCollision() : Bool
      {
         return mWantNavCollisions;
      }
      
      @:isVar public var archwayAlpha(get,never):Bool;
public function  get_archwayAlpha() : Bool
      {
         return mArchwayAlpha;
      }
      
            
      @:isVar public var distributedDungeonFloor(get,set):DistributedDungeonFloor;
public function  get_distributedDungeonFloor() : DistributedDungeonFloor
      {
         return mDistributedDungeonFloor;
      }
function  set_distributedDungeonFloor(param1:DistributedDungeonFloor) :DistributedDungeonFloor      {
         mDistributedDungeonFloor = param1;
         this.updateTile();
return param1;
      }
      
      function updateTile() 
      {
         if(mDistributedDungeonFloor != null)
         {
            this.tile = mDistributedDungeonFloor.tileGrid.getTileAtPosition(this.position);
         }
      }
      
      @:isVar public var navCollisions(get,never):Vector<NavCollider>;
public function  get_navCollisions() : Vector<NavCollider>
      {
         return mNavCollisions;
      }
      
      @:isVar public var worldCenter(get,never):Vector3D;
public function  get_worldCenter() : Vector3D
      {
         if(mNavCollisions == null || mNavCollisions.length == 0)
         {
            return mPosition;
         }
         if(mNavCollisions[0] == null)
         {
            Logger.warn("navCollision is null during get world center call on id: " + mId);
            return mPosition;
         }
         return mNavCollisions[0].worldCenter;
      }
      
      @:isVar public var worldCenterAsb2Vec2(get,never):B2Vec2;
public function  get_worldCenterAsb2Vec2() : B2Vec2
      {
         if(mNavCollisions.length == 0)
         {
            return NavCollider.convertToB2Vec2(mPosition);
         }
         return NavCollider.convertToB2Vec2(mNavCollisions[0].worldCenter);
      }
      
      public function addNavCollision(param1:NavCollider) 
      {
         if(!mWantNavCollisions)
         {
            Logger.warn("adding nav collision but wantNavCollision == false. Ignoring.");
            return;
         }
         mNavCollisions.push(param1);
      }
      
      public function removeNavColliders() 
      {
         var _loc1_:NavCollider;
         final __ax4_iter_190 = mNavCollisions;
         if (checkNullIteratee(__ax4_iter_190)) for (_tmp_ in __ax4_iter_190)
         {
            _loc1_ = _tmp_;
            _loc1_.destroy();
         }
         mNavCollisions = new Vector<NavCollider>();
      }
      
      @:isVar public var navCollidersActive(never,set):Bool;
public function  set_navCollidersActive(param1:Bool) :Bool      {
         var _loc2_:NavCollider;
         final __ax4_iter_191 = mNavCollisions;
         if (checkNullIteratee(__ax4_iter_191)) for (_tmp_ in __ax4_iter_191)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty(_loc2_, "active", param1);
         }
return param1;
      }
      
            
      @:isVar public var tile(get,set):Tile;
public function  set_tile(param1:Tile) :Tile      {
         if(param1 == mTile)
         {
            return param1;
         }
         if(mTile != null)
         {
            mTile.removeFloorObject(this);
         }
         mTile = param1;
         if(mTile != null)
         {
            mTile.addFloorObject(this);
         }
return param1;
      }
function  get_tile() : Tile
      {
         return mTile;
      }
      
            
      @:isVar public var position(get,set):Vector3D;
public function  get_position() : Vector3D
      {
         if(mPosition != null)
         {
            return mPosition.clone();
         }
         return null;
      }
function  set_position(param1:Vector3D) :Vector3D      {
         mPosition = param1;
         this.updateTile();
return param1;
      }
      
            
      @:isVar public var layer(get,set):Int;
public function  set_layer(param1:Int) :Int      {
         mLayer = param1;
         mFloorView.layer = mLayer;
return param1;
      }
function  get_layer() : Int
      {
         return mLayer;
      }
      
            
      @:isVar public var view(get,set):FloorView;
public function  set_view(param1:FloorView) :FloorView      {
         return mFloorView = param1;
      }
function  get_view() : FloorView
      {
         return mFloorView;
      }
      
      function buildView() 
      {
         var _loc1_= new FloorView(mDBFacade,this);
         MemoryTracker.track(_loc1_,"FloorView - created in FloorObject.buildView()");
         view = _loc1_;
      }
      
      function createNavCollisions(param1:String) 
      {
         var _loc2_= mDistributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.getNavCollisionJson(param1);
         this.processJsonNavCollisions(_loc2_,this.addNavCollision);
      }
      
      function processJsonNavCollisions(param1:Array<ASAny>, param2:ASFunction) 
      {
         var _loc7_:ASAny = null;
         var _loc3_:Vector3D = null;
         var _loc9_:Vector3D = null;
         var _loc8_:Vector3D = null;
         var _loc5_:NavCollider = null;
         var _loc4_:Vector<Vector3D> = /*undefined*/null;
         var _loc6_= new Matrix3D();
         var _loc10_= new Matrix3D();
         _loc10_.identity();
         _loc10_.appendScale(this.view.root.scaleX,this.view.root.scaleY,1);
         _loc10_.appendRotation(this.view.root.rotation,Vector3D.Z_AXIS);
         mFilter = buildFilter();
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc7_  = _tmp_;
            _loc6_.identity();
            if(ASCompat.toBool(_loc7_.rotation))
            {
               _loc6_.appendRotation(ASCompat.toNumberField(_loc7_, "rotation"),Vector3D.Z_AXIS);
            }
            _loc6_.appendTranslation(ASCompat.toNumberField(_loc7_, "x"),ASCompat.toNumberField(_loc7_, "y"),0);
            _loc6_.append(_loc10_);
            _loc4_ = _loc6_.decompose();
            _loc3_ = ASCompat.dynamicAs(_loc4_[0], flash.geom.Vector3D);
            _loc9_ = ASCompat.dynamicAs(_loc4_[1], flash.geom.Vector3D);
            _loc8_ = ASCompat.dynamicAs(_loc4_[2], flash.geom.Vector3D);
            _loc5_ = NavCollider.buildNavColliderFromJson(mDBFacade,_loc7_,this,_loc3_,_loc9_.z,_loc8_,this.mDistributedDungeonFloor.box2DWorld,mFilter);
            if(_loc5_ != null)
            {
               _loc5_.position = this.position;
               param2(_loc5_);
            }
         }
      }
      
      function buildFilter() : B2FilterData
      {
         var _loc1_= new B2FilterData();
         _loc1_.categoryBits = (1 : UInt);
         return _loc1_;
      }
      
      override public function destroy() 
      {
         if(mTile != null)
         {
            mTile.removeFloorObject(this);
         }
         mTile = null;
         mDistributedDungeonFloor = null;
         var _loc1_:NavCollider;
         final __ax4_iter_192 = mNavCollisions;
         if (checkNullIteratee(__ax4_iter_192)) for (_tmp_ in __ax4_iter_192)
         {
            _loc1_ = _tmp_;
            _loc1_.destroy();
         }
         mNavCollisions.length = 0;
         mNavCollisions = null;
         if(mFloorView != null)
         {
            mFloorView.destroy();
            mFloorView = null;
         }
         mDBFacade = null;
         super.destroy();
      }
   }


