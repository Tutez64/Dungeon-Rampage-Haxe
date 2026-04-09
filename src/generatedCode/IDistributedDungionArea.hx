package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedDungionArea
   {
      
      function setNetworkComponentDistributedDungionArea(param1:DistributedDungionAreaNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      function tileLibrary(param1:Vector<Swrapper>) : Void;
      
      @:isVar var cacheNpc(never,set):Vector<UInt>;
      
      @:isVar var cacheSWC(never,set):Vector<Swrapper>;
      
      function floorReward(param1:UInt) : Void;
      
      function floorEnding(param1:UInt) : Void;
      
      function dungeonEnding(param1:UInt, param2:UInt) : Void;
      
      function floorfailing(param1:UInt) : Void;
      
      function tellClientInfiniteRewardData(param1:UInt, param2:UInt, param3:UInt, param4:Vector<InfiniteRewardData>) : Void;
   }


