package dungeon;

import brain.render.RendererFactorySelector;
import brain.utils.MemoryTracker;
import collections.IIterator;
import collections.Set;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import dr_floor.FloorObject;
import generatedCode.DungeonTileUsage;
import flash.geom.Vector3D;

class DungeonFloorFactory {
	var mTileNetworkComponents:Vector<DungeonTileUsage>;

	var mTilesBuiltCallback:ASFunction;

	var mNumTilesCreated:UInt = (0 : UInt);

	var mTileGrid:TileGrid;

	var mTileFactory:TileFactory;

	var mDBFacade:DBFacade;

	var mDistributedDungeonFloor:DistributedDungeonFloor;

	public function new(distributedDungeonFloor:DistributedDungeonFloor, initGridCallback:ASFunction, facade:DBFacade, tileLibraryPath:String) {
		mDBFacade = facade;
		mDistributedDungeonFloor = distributedDungeonFloor;
		mTileFactory = new TileFactory(mDBFacade, mDBFacade.libraryJson, mDBFacade.getTileLibraryJson(tileLibraryPath));
		MemoryTracker.track(mTileFactory, "TileFactory - created in DungeonFloorFactory.constructor()");
		mTileGrid = new TileGrid();
		MemoryTracker.track(mTileGrid, "TileGrid - created in DungeonFloorFactory.constructor()");
		initGridCallback(mTileGrid);
	}

	public function destroy() {
		mTileNetworkComponents = null;
		mTilesBuiltCallback = null;
		mTileGrid.destroy();
		mTileGrid = null;
		mTileFactory.destroy();
		mTileFactory = null;
		mDistributedDungeonFloor = null;
		mDBFacade = null;
	}

	@:isVar public var tileFactory(get, never):TileFactory;

	public function get_tileFactory():TileFactory {
		return mTileFactory;
	}

	public function buildDungeonFloor(tileNetworkComponents:Vector<DungeonTileUsage>, tilesBuiltCallback:ASFunction, clearGroundLayer:Bool = true) {
		var _loc4_:RendererFactorySelector = null;
		if (clearGroundLayer) {
			_loc4_ = mDBFacade.rendererFactorySelector;
			if (_loc4_ != null) {
				_loc4_.clearLayer(5);
			} else if (mDBFacade.starlingLayerManager != null) {
				mDBFacade.starlingLayerManager.cleanLayers();
			}
		}
		mTileNetworkComponents = tileNetworkComponents;
		mTilesBuiltCallback = tilesBuiltCallback;
		mNumTilesCreated = (0 : UInt);
		buildGrid(tileNetworkComponents);
		AddFillerTiles();
	}

	function AddFillerTilesHelper(pos:Vector3D, x:Float, y:Float) {
		var _loc4_:DungeonTileUsage = null;
		pos.x += x * 900;
		pos.y += y * 900;
		if (mTileGrid.isPositionOpenForATile(pos)) {
			_loc4_ = new DungeonTileUsage();
			_loc4_.tileId = mTileFactory.mFillerTiles[0].id;
			_loc4_.x = ASCompat.floatToInt(pos.x);
			_loc4_.y = ASCompat.floatToInt(pos.y);
			mTileFactory.buildTile(_loc4_, addToGrid, tileInitialized, mDistributedDungeonFloor, true);
		}
	}

	function AddFillerTiles() {
		var _loc2_:Vector3D;
		var _loc1_:Vector<Vector3D> = /*undefined*/ null;
		if (mTileFactory.mFillerTiles.length > 0) {
			_loc1_ = mTileGrid.getNonFillTilePositions();
			if (checkNullIteratee(_loc1_))
				for (_tmp_ in _loc1_) {
					_loc2_ = _tmp_;
					AddFillerTilesHelper(_loc2_.clone(), 1, 0);
					AddFillerTilesHelper(_loc2_.clone(), 1, 1);
					AddFillerTilesHelper(_loc2_.clone(), 1, -1);
					AddFillerTilesHelper(_loc2_.clone(), 0, 1);
					AddFillerTilesHelper(_loc2_.clone(), 0, -1);
					AddFillerTilesHelper(_loc2_.clone(), -1, 1);
					AddFillerTilesHelper(_loc2_.clone(), -1, 0);
					AddFillerTilesHelper(_loc2_.clone(), -1, -1);
				}
		}
	}

	function buildGrid(tileNetworkComponents:Vector<DungeonTileUsage>) {
		var _loc2_ = (0 : UInt);
		_loc2_ = (0 : UInt);
		while (_loc2_ < (tileNetworkComponents.length:UInt)) {
			mTileFactory.buildTile(tileNetworkComponents[(_loc2_ : Int)], addToGrid, tileInitialized, mDistributedDungeonFloor);
			_loc2_++;
		}
	}

	function addToGrid(tile:Tile) {
		var _loc5_:Set = null;
		var _loc2_:IIterator = null;
		var _loc4_:FloorObject = null;
		var _loc3_ = mTileGrid.getTileAtPosition(tile.position);
		if (_loc3_ != null) {
			_loc5_ = _loc3_.floorObjects;
			_loc2_ = _loc5_.iterator();
			while (_loc2_.hasNext()) {
				_loc4_ = ASCompat.coerce(_loc2_.next(), dr_floor.FloorObject);
				if (!_loc3_.hasOwnedFloorObject(_loc4_)) {
					_loc4_.tile = tile;
				}
			}
			mTileGrid.removeTileAtPosition(tile.position);
		}
		mTileGrid.setTileAtPosition(tile.position, tile);
	}

	function tileInitialized(tile:Tile) {
		mTileGrid.setTileAtPosition(tile.position, tile);
		mNumTilesCreated = mNumTilesCreated + 1;
		if (mNumTilesCreated == (mTileNetworkComponents.length : UInt)) {
			mTilesBuiltCallback(mTileGrid);
		}
	}
}
