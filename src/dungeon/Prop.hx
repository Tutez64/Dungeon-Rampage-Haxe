package dungeon
;
   import brain.sceneGraph.SceneGraphManager;
   import brain.utils.MemoryTracker;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import gameMasterDictionary.GMProp;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   
    class Prop extends FloorObject
   {
      
      var mPropView:PropView;
      
      var mAssetClassName:String;
      
      var mConstant:String;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
         this.init();
      }
      
      public static function validatePropConstant(param1:ASObject, param2:DBFacade) : Bool
      {
         if(param1.constant == null)
         {
            return false;
         }
         var _loc3_= ASCompat.dynamicAs(param2.gameMaster.propByConstant.itemFor(param1.constant), gameMasterDictionary.GMProp);
         return _loc3_ != null;
      }
      
      public static function parseFromTileJson(param1:ASObject, param2:Tile, param3:DBFacade) : Prop
      {
         var _loc6_= ASCompat.toNumber(param2.position.x + (param1.x != null ? param1.x : 0));
         var _loc7_= ASCompat.toNumber(param2.position.y + (param1.y != null ? param1.y : 0));
         var _loc8_= new Vector3D(_loc6_,_loc7_);
         var _loc5_= new Prop(param3);
         _loc5_.tile = param2;
         param2.addOwnedFloorObject(_loc5_);
         _loc5_.constant = param1.constant;
         var _loc4_= ASCompat.dynamicAs(param3.gameMaster.propByConstant.itemFor(_loc5_.constant), gameMasterDictionary.GMProp);
         _loc5_.assetClassName = _loc4_.AssetClassName;
         _loc5_.position = _loc8_;
         _loc5_.mArchwayAlpha = _loc4_.ArchwayAlpha;
         if(ASCompat.toBool(param1.scale))
         {
            _loc5_.view.root.scaleX = _loc5_.view.root.scaleY = ASCompat.toNumberField(param1, "scale");
         }
         if(ASCompat.toBool(param1.flip))
         {
            _loc5_.view.root.scaleX = -_loc5_.view.root.scaleX;
         }
         if(ASCompat.toBool(param1.rotation))
         {
            _loc5_.view.root.rotation = ASCompat.toNumberField(param1, "rotation");
         }
         var _loc9_:String = param1.layer != null ? param1.layer : "sorted";
         _loc5_.layer = SceneGraphManager.getLayerFromName(_loc9_);
         return _loc5_;
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         super.position = param1;
         this.mPropView.position = mPosition;
return param1;
      }
      
            
      @:isVar public var constant(get,set):String;
public function  set_constant(param1:String) :String      {
         return mConstant = param1;
      }
function  get_constant() : String
      {
         return mConstant;
      }
      
      @:isVar public var assetClassName(never,set):String;
public function  set_assetClassName(param1:String) :String      {
         return mAssetClassName = param1;
      }
      
      override public function  set_distributedDungeonFloor(param1:DistributedDungeonFloor) :DistributedDungeonFloor      {
         super.distributedDungeonFloor = param1;
         this.distributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.createProp(this.constant,assetLoaded);
return param1;
      }
      
      override function updateTile() 
      {
      }
      
      function assetLoaded(param1:MovieClip) 
      {
         mPropView.body = param1;
         mPropView.root.name = "PropView_" + this.constant + "_" + this.id;
         if(param1.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mPropView.root.cacheAsBitmap = true;
         }
         if(!mTile.isOnStage)
         {
            this.view.addToStage();
         }
         mTile.expandBounds(this);
         if(!mTile.isOnStage)
         {
            this.view.removeFromStage();
         }
         this.createNavCollisions(this.constant);
      }
      
      override function buildView() 
      {
         mPropView = new PropView(mDBFacade,this);
         MemoryTracker.track(mPropView,"PropView - created in Prop.buildView()");
         view = mPropView;
      }
      
      override public function destroy() 
      {
         mPropView = null;
         super.destroy();
      }
   }


