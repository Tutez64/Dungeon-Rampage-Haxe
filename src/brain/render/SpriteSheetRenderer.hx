package brain.render
;
   import brain.assetRepository.SpriteSheetAsset;
   import brain.clock.GameClock;
   import brain.utils.MemoryTracker;
   import brain.workLoop.WorkComponent;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
    class SpriteSheetRenderer extends BitmapRenderer
   {
      
      var mSpriteSheet:SpriteSheetAsset;
      
      var mXIndex:UInt = (0 : UInt);
      
      var mYIndex:UInt = (0 : UInt);
      
      public function new(param1:WorkComponent, param2:SpriteSheetAsset)
      {
         super(param1);
         mSpriteSheet = param2;
         MemoryTracker.track(this,"SpriteSheetRenderer - created in SpriteSheetRenderer()","brain");
      }
      
      override public function destroy() 
      {
         mSpriteSheet = null;
         super.destroy();
      }
      
      @:isVar public var spriteSheet(never,set):SpriteSheetAsset;
public function  set_spriteSheet(param1:SpriteSheetAsset) :SpriteSheetAsset      {
         return mSpriteSheet = param1;
      }
      
      public function setFrameIndexes(param1:UInt, param2:UInt) 
      {
         mXIndex = param1;
         mYIndex = param2;
      }
      
      function getCurrentFrame() : BitmapData
      {
         return mSpriteSheet.getFrame(mXIndex,mYIndex);
      }
      
      function getCurrentCenter() : Point
      {
         return mSpriteSheet.getCenter(mXIndex,mYIndex);
      }
      
      public function updateToCurrentFrame() 
      {
         this.center = getCurrentCenter();
         this.bitmapData = getCurrentFrame();
      }
      
      override function onFrame(param1:GameClock) 
      {
         super.onFrame(param1);
         this.updateToCurrentFrame();
      }
      
      public function play(param1:UInt = (0 : UInt), param2:Bool = true, param3:ASFunction = null) 
      {
         setFrame(param1);
      }
      
      public function stop() 
      {
      }
      
      @:isVar public var currentFrame(get,never):UInt;
public function  get_currentFrame() : UInt
      {
         return mXIndex;
      }
      
      @:isVar public var heading(get,set):Float;
public function  set_heading(param1:Float) :Float      {
return param1;
      }
      
      @:isVar public var loop(get,never):Bool;
public function  get_loop() : Bool
      {
         return false;
      }
      
      public function setFrame(param1:UInt) 
      {
         this.mXIndex = param1;
      }
function get_heading():Float{
	return 0;
}   }


