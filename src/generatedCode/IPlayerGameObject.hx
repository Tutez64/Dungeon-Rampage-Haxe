package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IPlayerGameObject
   {
      
      function setNetworkComponentPlayerGameObject(param1:PlayerGameObjectNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var screenName(never,set):String;
      
      function Chat(param1:String) : Void;
      
      function ShowPlayerIsTyping(param1:UInt) : Void;
   }


