package brain.workLoop
;
   import brain.clock.GameClock;
   import brain.utils.MemoryTracker;
   import flash.display.Sprite;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
    class WorkLoopManager extends Sprite
   {
      
      var mTasks:Set = new Set();
      
      var mCurrentGameClock:GameClock;
      
      var doLaterQueue:SimplePriorityQueue = new SimplePriorityQueue(1024);
      
      public function new(param1:GameClock)
      {
         super();
         mCurrentGameClock = param1;
         MemoryTracker.track(mTasks,"Set - frame tasks in WorkLoopManager()","brain");
         MemoryTracker.track(doLaterQueue,"SimplePriorityQueue - doLater queue in WorkLoopManager()","brain");
      }
      
      public function update(param1:GameClock) 
      {
         mCurrentGameClock = param1;
         advance();
      }
      
      @:isVar public var gameClock(get,never):GameClock;
public function  get_gameClock() : GameClock
      {
         return mCurrentGameClock;
      }
      
      public function doEveryFrame(param1:ASFunction) : Task
      {
         var _loc2_= new Task();
         _loc2_.callback = param1;
         mTasks.add(_loc2_);
         MemoryTracker.track(_loc2_,"Task - every frame task in WorkLoopManager.doEveryFrame()","brain");
         return _loc2_;
      }
      
      public function doEverySeconds(param1:Float, param2:ASFunction, param3:Bool = true) : DoLater
      {
         return doLater(param1,param2,param3);
      }
      
      public function CalculateCallbackTime(param1:Float) : UInt
      {
         return (Std.int(mCurrentGameClock.gameTime + param1 * 1000) : UInt);
      }
      
      public function doLater(param1:Float, param2:ASFunction, param3:Bool = true) : DoLater
      {
         var _loc4_= new DoLater(param3);
         _loc4_.delay = param1;
         _loc4_.dueTime = (Std.int(mCurrentGameClock.gameTime + _loc4_.delay * 1000) : UInt);
         _loc4_.callback = param2;
         doLaterQueue.enqueue(_loc4_);
         MemoryTracker.track(_loc4_,"DoLater - delay=" + param1 + "s repeat=" + param3 + " in WorkLoopManager.doLater()","brain");
         return _loc4_;
      }
      
      function removeDoLater(param1:DoLater) : Bool
      {
         param1.destroy();
         return doLaterQueue.remove(param1);
      }
      
      function removeTask(param1:Task) : Bool
      {
         param1.destroy();
         return mTasks.remove(param1);
      }
      
      function advance() 
      {
         processTasks();
         processDoLaters();
      }
      
      function processTasks() 
      {
         var _loc2_:Task = null;
         if(mTasks.size == 0)
         {
            return;
         }
         var _loc1_= ASCompat.reinterpretAs(mTasks.iterator() , ISetIterator);
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.workLoop.Task);
            if(_loc2_.isDestroyed())
            {
               _loc1_.remove();
               removeTask(_loc2_);
            }
            else if(_loc2_.callback != null)
            {
               _loc2_.callback(mCurrentGameClock);
            }
         }
      }
      
      function processDoLaters() 
      {
         var _loc1_:DoLater = null;
         if(doLaterQueue.size == 0)
         {
            return;
         }
         while(doLaterQueue.front != null && doLaterQueue.front.priority >= -mCurrentGameClock.gameTime)
         {
            _loc1_ = ASCompat.reinterpretAs(doLaterQueue.dequeue() , DoLater);
            if(_loc1_ != null && !_loc1_.isDestroyed())
            {
               if(_loc1_.callback != null)
               {
                  _loc1_.callback(mCurrentGameClock);
               }
               if(_loc1_.repeat)
               {
                  _loc1_.dueTime += (Std.int(_loc1_.delay * 1000) : UInt);
                  doLaterQueue.enqueue(_loc1_);
               }
            }
         }
      }
   }


