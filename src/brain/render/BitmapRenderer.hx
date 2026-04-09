package brain.render
;
   import brain.clock.GameClock;
   import brain.utils.MemoryTracker;
   import brain.workLoop.Task;
   import brain.workLoop.WorkComponent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
    class BitmapRenderer
   {
      
      var mWorkComponent:WorkComponent;
      
      var mOnFrameTask:Task;
      
      var mBitmap:Bitmap = new Bitmap();
      
      var mSmoothing:Bool = false;
      
      var mCenter:Point = new Point(0.5,0.5);
      
      public function new(param1:WorkComponent)
      {
         
         mBitmap.smoothing = mSmoothing;
         mBitmap.pixelSnapping = "auto";
         mWorkComponent = param1;
         mBitmap.addEventListener("addedToStage",onAdd);
         mBitmap.addEventListener("removedFromStage",onRemove);
         MemoryTracker.track(this,"BitmapRenderer - created in BitmapRenderer()","brain");
      }
      
      public function destroy() 
      {
         mBitmap.removeEventListener("addedToStage",onAdd);
         mBitmap.removeEventListener("removedFromStage",onRemove);
         onRemove();
         mWorkComponent.destroy();
         mWorkComponent = null;
         mBitmap = null;
      }
      
      function onAdd(param1:Event = null) 
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
         }
         mOnFrameTask = mWorkComponent.doEveryFrame(onFrame);
      }
      
      function onRemove(param1:Event = null) 
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
      }
      
            
      @:isVar public var center(get,set):Point;
public function  set_center(param1:Point) :Point      {
         mCenter = param1;
         mBitmap.x = -mCenter.x;
         mBitmap.y = -mCenter.y;
return param1;
      }
function  get_center() : Point
      {
         return mCenter;
      }
      
            
      @:isVar public var smoothing(get,set):Bool;
public function  set_smoothing(param1:Bool) :Bool      {
         mSmoothing = param1;
         mBitmap.smoothing = mSmoothing;
return param1;
      }
function  get_smoothing() : Bool
      {
         return mSmoothing;
      }
      
      @:isVar public var displayObject(get,never):DisplayObject;
public function  get_displayObject() : DisplayObject
      {
         return mBitmap;
      }
      
            
      @:isVar public var bitmapData(get,set):BitmapData;
public function  set_bitmapData(param1:BitmapData) :BitmapData      {
         if(param1 == mBitmap.bitmapData)
         {
            return param1;
         }
         mBitmap.bitmapData = param1;
         mBitmap.smoothing = mSmoothing;
         mBitmap.x = -mCenter.x;
         mBitmap.y = -mCenter.y;
return param1;
      }
      
      function onFrame(param1:GameClock) 
      {
      }
function  get_bitmapData() : BitmapData
      {
         return mBitmap.bitmapData;
      }
   }


