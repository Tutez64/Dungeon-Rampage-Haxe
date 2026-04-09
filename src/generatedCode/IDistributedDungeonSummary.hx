package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedDungeonSummary
   {
      
      function setNetworkComponentDistributedDungeonSummary(param1:DistributedDungeonSummaryNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var map_node_id(never,set):UInt;
      
      @:isVar var report(never,set):Vector<DungeonReport>;
      
      @:isVar var dungeon_name(never,set):String;
      
      @:isVar var dungeonSuccess(never,set):UInt;
      
      @:isVar var dungeonMod1(never,set):UInt;
      
      @:isVar var dungeonMod2(never,set):UInt;
      
      @:isVar var dungeonMod3(never,set):UInt;
      
      @:isVar var dungeonMod4(never,set):UInt;
      
      function TransactionResponse(param1:UInt, param2:UInt, param3:UInt, param4:UInt) : Void;
   }


