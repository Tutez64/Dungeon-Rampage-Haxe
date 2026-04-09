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
      
      public function new(param1:Facade, param2:WorkLoopManager)
      {
         super(param1);
         mTasks = new ASDictionary<ASAny,ASAny>(true);
         MemoryTracker.track(mTasks,"Dictionary - tasks in WorkComponent()","brain");
         mWorkLoopManager = param2;
      }
      
      @:isVar public var gameClock(get,never):GameClock;
public function  get_gameClock() : GameClock
      {
         return mWorkLoopManager.gameClock;
      }
      
      public function doEveryFrame(param1:ASFunction) : Task
      {
         var _loc2_= mWorkLoopManager.doEveryFrame(param1);
         mTasks[_loc2_] = 1;
         return _loc2_;
      }
      
      public function doLater(param1:Float, param2:ASFunction) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doLater(param1,param2,false);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function doEverySeconds(param1:Float, param2:ASFunction) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doEverySeconds(param1,param2,true);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function clear() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_206 = mTasks;
         if (checkNullIteratee(__ax4_iter_206)) for(_tmp_ in __ax4_iter_206.keys())
         {
            _loc1_ = _tmp_;
            cast(_loc1_, Task).destroy();
         }
         mTasks = new ASDictionary<ASAny,ASAny>(true);
      }
      
      override public function destroy() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_207 = mTasks;
         if (checkNullIteratee(__ax4_iter_207)) for(_tmp_ in __ax4_iter_207.keys())
         {
            _loc1_ = _tmp_;
            cast(_loc1_, Task).destroy();
         }
         mTasks = null;
         mWorkLoopManager = null;
         super.destroy();
      }
   }


