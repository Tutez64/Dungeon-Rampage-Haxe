package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IPresenceManager
   {
      
      function setNetworkComponentPresenceManager(param1:PresenceManagerNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      function friendState(param1:UInt, param2:UInt, param3:UInt) : Void;
   }


