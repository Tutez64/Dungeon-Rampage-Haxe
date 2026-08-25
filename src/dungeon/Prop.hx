package dungeon;

import brain.sceneGraph.SceneGraphManager;
import brain.utils.MemoryTracker;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import dr_floor.FloorObject;
import gameMasterDictionary.GMProp;
import flash.display.MovieClip;
import flash.geom.Vector3D;

class Prop extends FloorObject {
	var mPropView:PropView;

	var mAssetClassName:String;

	var mConstant:String;

	public function new(dbFacade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(dbFacade, remoteId);
		this.init();
	}

	public static function validatePropConstant(propJsonObj:ASObject, dbFacade:DBFacade):Bool {
		if (propJsonObj.constant == null) {
			return false;
		}
		var _loc3_ = ASCompat.dynamicAs(dbFacade.gameMaster.propByConstant.itemFor(propJsonObj.constant), gameMasterDictionary.GMProp);
		return _loc3_ != null;
	}

	public static function parseFromTileJson(propJsonObj:ASObject, tile:Tile, dbFacade:DBFacade):Prop {
		var _loc6_ = ASCompat.toNumber(tile.position.x + (propJsonObj.x != null ? propJsonObj.x : 0));
		var _loc7_ = ASCompat.toNumber(tile.position.y + (propJsonObj.y != null ? propJsonObj.y : 0));
		var _loc8_ = new Vector3D(_loc6_, _loc7_);
		var _loc5_ = new Prop(dbFacade);
		_loc5_.tile = tile;
		tile.addOwnedFloorObject(_loc5_);
		_loc5_.constant = propJsonObj.constant;
		var _loc4_ = ASCompat.dynamicAs(dbFacade.gameMaster.propByConstant.itemFor(_loc5_.constant), gameMasterDictionary.GMProp);
		_loc5_.assetClassName = _loc4_.AssetClassName;
		_loc5_.position = _loc8_;
		_loc5_.mArchwayAlpha = _loc4_.ArchwayAlpha;
		if (ASCompat.toBool(propJsonObj.scale)) {
			_loc5_.view.root.scaleX = _loc5_.view.root.scaleY = ASCompat.toNumberField(propJsonObj, "scale");
		}
		if (ASCompat.toBool(propJsonObj.flip)) {
			_loc5_.view.root.scaleX = -_loc5_.view.root.scaleX;
		}
		if (ASCompat.toBool(propJsonObj.rotation)) {
			_loc5_.view.root.rotation = ASCompat.toNumberField(propJsonObj, "rotation");
		}
		var _loc9_:String = propJsonObj.layer != null ? propJsonObj.layer : "sorted";
		_loc5_.layer = SceneGraphManager.getLayerFromName(_loc9_);
		return _loc5_;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		this.mPropView.position = mPosition;
		return pos;
	}

	@:isVar public var constant(get, set):String;

	public function set_constant(value:String):String {
		return mConstant = value;
	}

	function get_constant():String {
		return mConstant;
	}

	@:isVar public var assetClassName(never, set):String;

	public function set_assetClassName(value:String):String {
		return mAssetClassName = value;
	}

	override public function set_distributedDungeonFloor(value:DistributedDungeonFloor):DistributedDungeonFloor {
		super.distributedDungeonFloor = value;
		this.distributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.createProp(this.constant, assetLoaded);
		return value;
	}

	override function updateTile() {}

	function assetLoaded(propMovieClip:MovieClip) {
		mPropView.body = propMovieClip;
		mPropView.root.name = "PropView_" + this.constant + "_" + this.id;
		if (propMovieClip.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom")) {
			mPropView.root.cacheAsBitmap = true;
		}
		if (!mTile.isOnStage) {
			this.view.addToStage();
		}
		mTile.expandBounds(this);
		if (!mTile.isOnStage) {
			this.view.removeFromStage();
		}
		this.createNavCollisions(this.constant);
	}

	override function buildView() {
		mPropView = new PropView(mDBFacade, this);
		MemoryTracker.track(mPropView, "PropView - created in Prop.buildView()");
		view = mPropView;
	}

	override public function destroy() {
		mPropView = null;
		super.destroy();
	}
}
