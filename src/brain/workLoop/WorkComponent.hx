package brain.workLoop
;
   import brain.clock.GameClock;
   import brain.component.Component;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   
    class WorkComponent extends Component
   {
      
      var mWorkLoopManager:WorkLoopManager;
      
      var mTasks:ASDictionary<ASAny,ASAny>;
      
      var mOwnerName:String;
      
      var mTasksLabel:String;
      
      public function new(param1:Facade, param2:WorkLoopManager, param3:String = null)
      {
         super(param1);
         mOwnerName = param3;
         mTasksLabel = "Dictionary - tasks in " + (if (ASCompat.stringAsBool(param3)) param3 else "WorkComponent") + "()";
         mTasks = new ASDictionary<ASAny,ASAny>(true);
         MemoryTracker.track(mTasks,mTasksLabel,"brain");
         mWorkLoopManager = param2;
      }
      
      @:isVar public var gameClock(get,never):GameClock;
public function  get_gameClock() : GameClock
      {
         return mWorkLoopManager.gameClock;
      }
      
      public function doEveryFrame(param1:ASFunction) : Task
      {
         var _loc2_= mWorkLoopManager.doEveryFrame(param1,mOwnerName);
         mTasks[_loc2_] = 1;
         return _loc2_;
      }
      
      public function doLater(param1:Float, param2:ASFunction) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doLater(param1,param2,false,mOwnerName);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function doEverySeconds(param1:Float, param2:ASFunction) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doEverySeconds(param1,param2,true,mOwnerName);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function clear() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_228 = mTasks;
         if (checkNullIteratee(__ax4_iter_228)) for(_tmp_ in __ax4_iter_228.keys())
         {
            _loc1_ = _tmp_;
            cast(_loc1_, Task).destroy();
         }
         mTasks = new ASDictionary<ASAny,ASAny>(true);
         MemoryTracker.track(mTasks,mTasksLabel,"brain");
      }
      
      override public function destroy() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_229 = mTasks;
         if (checkNullIteratee(__ax4_iter_229)) for(_tmp_ in __ax4_iter_229.keys())
         {
            _loc1_ = _tmp_;
            cast(_loc1_, Task).destroy();
         }
         mTasks = null;
         mWorkLoopManager = null;
         super.destroy();
      }
   }


