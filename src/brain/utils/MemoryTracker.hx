package brain.utils
;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.sampler.*;
   
    class MemoryTracker
   {
      
      static var m_count:Int = 0;
      
      static var m_stage:Stage = null;
      
      static var m_generation:Int = 0;
      
      static var m_checkpointGeneration:Int = 0;
      
      static var m_currentFilter:ASObject = null;
      
      static var m_tracking:ASDictionary<ASAny,ASAny> = new ASDictionary(true);
      
      public function new()
      {
         
      }
      
      @:isVar public static var stage(never,set):Stage;
static public function  set_stage(param1:Stage) :Stage      {
         return m_stage = param1;
      }
      
      public static function track(param1:ASAny, param2:String, param3:String = "default") 
      {
      }
      
      public static function nextGeneration() 
      {
      }
      
      static function parseFilter(param1:String) : ASObject
      {
         var _loc2_:String = null;
         if(!ASCompat.stringAsBool(param1) || param1.length == 0)
         {
            return null;
         }
         var _loc6_:Array<ASAny> = [];
         var _loc3_:Array<ASAny> = [];
         var _loc5_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
         var _loc4_:ASAny;
         if (checkNullIteratee(_loc5_)) for (_tmp_ in _loc5_)
         {
            _loc4_ = _tmp_;
            if(ASCompat.toNumberField(_loc4_, "length") != 0)
            {
               if(Std.string(_loc4_).charAt(0) == "!")
               {
                  _loc2_ = Std.string(_loc4_).substring(1);
                  if(_loc2_.length > 0)
                  {
                     _loc3_.push(_loc2_);
                  }
               }
               else
               {
                  _loc6_.push(_loc4_);
               }
            }
         }
         if(_loc6_.length == 0 && _loc3_.length == 0)
         {
            return null;
         }
         return {
            "incl":_loc6_,
            "excl":_loc3_
         };
      }
      
      static function passesCategoryFilter(param1:String, param2:ASObject) : Bool
      {
         if(!ASCompat.toBool(param2))
         {
            return true;
         }
         if(ASCompat.toNumberField(param2.excl, "length") > 0)
         {
            if(ASCompat.toNumber(param2.excl.indexOf(param1)) >= 0)
            {
               return false;
            }
         }
         if(ASCompat.toNumberField(param2.incl, "length") > 0)
         {
            if(ASCompat.toNumber(param2.incl.indexOf(param1)) < 0)
            {
               return false;
            }
         }
         return true;
      }
      
      static function getFilterDescription(param1:ASObject) : String
      {
         if(!ASCompat.toBool(param1))
         {
            return "";
         }
         var _loc2_:Array<ASAny> = [];
         if(ASCompat.toNumberField(param1.incl, "length") > 0)
         {
            _loc2_.push("include: " + Std.string(ASCompat.dynJoin(param1.incl, ", ")));
         }
         if(ASCompat.toNumberField(param1.excl, "length") > 0)
         {
            _loc2_.push("exclude: " + Std.string(ASCompat.dynJoin(param1.excl, ", ")));
         }
         return " (" + _loc2_.join("; ") + ")";
      }
      
      @:isVar public static var generation(get,never):Int;
static public function  get_generation() : Int
      {
         return m_generation;
      }
      
      public static function memoryReport(param1:String = null) 
      {
      }
      
      @:isVar public static var trackedCount(get,never):Int;
static public function  get_trackedCount() : Int
      {
         var _loc1_= 0;
         var _loc2_:ASAny;
         final __ax4_iter_57 = m_tracking;
         if (checkNullIteratee(__ax4_iter_57)) for(_tmp_ in __ax4_iter_57.keys())
         {
            _loc2_ = _tmp_;
            _loc1_++;
         }
         return _loc1_;
      }
      
      @:isVar public static var trackedCountSinceCheckpoint(get,never):Int;
static public function  get_trackedCountSinceCheckpoint() : Int
      {
         var _loc3_:ASObject = null;
         var _loc1_= 0;
         var _loc2_:ASAny;
         final __ax4_iter_58 = m_tracking;
         if (checkNullIteratee(__ax4_iter_58)) for(_tmp_ in __ax4_iter_58.keys())
         {
            _loc2_ = _tmp_;
            _loc3_ = m_tracking[_loc2_];
            if(ASCompat.toNumberField(_loc3_, "generation") >= m_checkpointGeneration)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      static function _gc(param1:Event) 
      {
      }
      
      static function _doLastGC() 
      {
      }
   }


