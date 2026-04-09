package generatedCode
;
   import brain.gameObject.GameObject;
   
    interface IDistributedDungeonFloor
   {
      
      function setNetworkComponentDistributedDungeonFloor(param1:DistributedDungeonFloorNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var mapNodeId(never,set):UInt;
      
      @:isVar var coliseumTierConstant(never,set):String;
      
      function tileLibrary(param1:String) : Void;
      
      function tiles(param1:Vector<DungeonTileUsage>) : Void;
      
      @:isVar var baseLining(never,set):UInt;
      
      @:isVar var introMovieSwfFilePath(never,set):String;
      
      @:isVar var introMovieAssetClassName(never,set):String;
      
      @:isVar var currentFloorNum(never,set):UInt;
      
      @:isVar var activeDungeonModifiers(never,set):Vector<DungeonModifier>;
      
      function show_text(param1:String) : Void;
      
      function play_sound(param1:String) : Void;
      
      function trigger_camera_zoom(param1:Float) : Void;
      
      function trigger_camera_shake(param1:Float, param2:Float, param3:UInt) : Void;
   }


