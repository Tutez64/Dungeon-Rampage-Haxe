package dungeon
;
   import brain.utils.MemoryTracker;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import generatedCode.DungeonTileUsage;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IIterator;
   
    class DungeonFloorFactory
   {
      
      var mTileNetworkComponents:Vector<DungeonTileUsage>;
      
      var mTilesBuiltCallback:ASFunction;
      
      var mNumTilesCreated:UInt = (0 : UInt);
      
      var mTileGrid:TileGrid;
      
      var mTileFactory:TileFactory;
      
      var mDBFacade:DBFacade;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      public function new(param1:DistributedDungeonFloor, param2:ASFunction, param3:DBFacade, param4:String)
      {
         
         mDBFacade = param3;
         mDistributedDungeonFloor = param1;
         mTileFactory = new TileFactory(mDBFacade,mDBFacade.libraryJson,mDBFacade.getTileLibraryJson(param4));
         MemoryTracker.track(mTileFactory,"TileFactory - created in DungeonFloorFactory.constructor()");
         mTileGrid = new TileGrid();
         MemoryTracker.track(mTileGrid,"TileGrid - created in DungeonFloorFactory.constructor()");
         param2(mTileGrid);
      }
      
      public function destroy() 
      {
         mTileNetworkComponents = null;
         mTilesBuiltCallback = null;
         mTileGrid.destroy();
         mTileGrid = null;
         mTileFactory.destroy();
         mTileFactory = null;
         mDistributedDungeonFloor = null;
         mDBFacade = null;
      }
      
      @:isVar public var tileFactory(get,never):TileFactory;
public function  get_tileFactory() : TileFactory
      {
         return mTileFactory;
      }
      
      public function buildDungeonFloor(param1:Vector<DungeonTileUsage>, param2:ASFunction) 
      {
         mTileNetworkComponents = param1;
         mTilesBuiltCallback = param2;
         buildGrid(param1);
         AddFillerTiles();
      }
      
      function AddFillerTilesHelper(param1:Vector3D, param2:Float, param3:Float) 
      {
         var _loc4_:DungeonTileUsage = null;
         param1.x += param2 * 900;
         param1.y += param3 * 900;
         if(mTileGrid.isPositionOpenForATile(param1))
         {
            _loc4_ = new DungeonTileUsage();
            _loc4_.tileId = mTileFactory.mFillerTiles[0].id;
            _loc4_.x = Std.int(param1.x);
            _loc4_.y = Std.int(param1.y);
            mTileFactory.buildTile(_loc4_,addToGrid,tileInitialized,mDistributedDungeonFloor);
         }
      }
      
      function AddFillerTiles() 
      {
         var _loc2_:Vector3D;
         var _loc1_:Vector<Vector3D> = /*undefined*/null;
         if(mTileFactory.mFillerTiles.length > 0)
         {
            _loc1_ = mTileGrid.getNonFillTilePositions();
            if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
            {
               _loc2_ = _tmp_;
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),1,0);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),1,1);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),1,-1);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),0,1);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),0,-1);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),-1,1);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),-1,0);
               AddFillerTilesHelper(ASCompat.dynamicAs(_loc2_.clone(), flash.geom.Vector3D),-1,-1);
            }
         }
      }
      
      function buildGrid(param1:Vector<DungeonTileUsage>) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            mTileFactory.buildTile(param1[_loc2_],addToGrid,tileInitialized,mDistributedDungeonFloor);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function addToGrid(param1:Tile) 
      {
         var _loc5_:Set = null;
         var _loc2_:IIterator = null;
         var _loc4_:FloorObject = null;
         var _loc3_= mTileGrid.getTileAtPosition(param1.position);
         if(_loc3_ != null)
         {
            _loc5_ = _loc3_.floorObjects;
            _loc2_ = _loc5_.iterator();
            while(_loc2_.hasNext())
            {
               _loc4_ = ASCompat.dynamicAs(_loc2_.next(), dr_floor.FloorObject);
               if(!_loc3_.hasOwnedFloorObject(_loc4_))
               {
                  _loc4_.tile = param1;
               }
            }
            mTileGrid.removeTileAtPosition(param1.position);
         }
         mTileGrid.setTileAtPosition(param1.position,param1);
      }
      
      function tileInitialized(param1:Tile) 
      {
         mTileGrid.setTileAtPosition(param1.position,param1);
         mDistributedDungeonFloor.astarGrids.InitTileAstarGrids((Std.int(param1.position.x / 900 + 1) : UInt),(Std.int(param1.position.y / 900 + 1) : UInt));
         mNumTilesCreated = mNumTilesCreated + 1;
         if(mNumTilesCreated == (mTileNetworkComponents.length : UInt))
         {
            mTilesBuiltCallback(mTileGrid);
         }
      }
   }


