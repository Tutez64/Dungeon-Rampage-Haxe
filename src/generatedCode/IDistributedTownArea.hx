package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedTownArea
   {
      
      function setNetworkComponentDistributedTownArea(param1:DistributedTownAreaNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      function tileLibrary(param1:String) : Void;
   }


