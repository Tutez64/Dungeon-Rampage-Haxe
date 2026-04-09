package distributedObjects
;
   import brain.facade.Facade;
   import brain.gameObject.GameObject;
   import generatedCode.DistributedTownFloorNetworkComponent;
   import generatedCode.DungeonTileUsage;
   import generatedCode.IDistributedTownFloor;
   
    class DistributedTownFloor extends GameObject implements IDistributedTownFloor
   {
      
      public function new(param1:Facade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
      }
      
      public function setNetworkComponentDistributedTownFloor(param1:DistributedTownFloorNetworkComponent) 
      {
      }
      
      public function postGenerate() 
      {
      }
      
      public function tileLibrary(param1:String) 
      {
      }
      
      public function tiles(param1:Vector<DungeonTileUsage>) 
      {
      }
   }


