package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedTownFloor
   {
      
      function setNetworkComponentDistributedTownFloor(param1:DistributedTownFloorNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      function tileLibrary(param1:String) : Void;
      
      function tiles(param1:Vector<DungeonTileUsage>) : Void;
   }


