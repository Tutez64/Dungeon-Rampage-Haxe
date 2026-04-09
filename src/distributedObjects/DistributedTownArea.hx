package distributedObjects
;
   import brain.facade.Facade;
   import brain.gameObject.GameObject;
   import generatedCode.DistributedTownAreaNetworkComponent;
   import generatedCode.IDistributedTownArea;
   
    class DistributedTownArea extends GameObject implements IDistributedTownArea
   {
      
      public function new(param1:Facade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
      }
      
      public function setNetworkComponentDistributedTownArea(param1:DistributedTownAreaNetworkComponent) 
      {
      }
      
      public function postGenerate() 
      {
      }
      
      public function tileLibrary(param1:String) 
      {
      }
   }


