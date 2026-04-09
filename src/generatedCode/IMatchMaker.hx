package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IMatchMaker
   {
      
      function setNetworkComponentMatchMaker(param1:MatchMakerNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      function InfiniteDetails(param1:Vector<InfiniteMapNodeDetail>) : Void;
      
      function ClientRequestEntryResponce(param1:UInt, param2:UInt) : Void;
      
      function ClientExitComplete(param1:UInt) : Void;
      
      function ClientInformPartyComposition(param1:Vector<GameServerPartyMember>) : Void;
   }


