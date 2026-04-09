package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedBuffGameObject
   {
      
      function setNetworkComponentDistributedBuffGameObject(param1:DistributedBuffGameObjectNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var type(never,set):UInt;
      
      @:isVar var effectedActor(never,set):UInt;
   }


