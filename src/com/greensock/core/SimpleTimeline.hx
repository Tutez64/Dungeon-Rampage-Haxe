package com.greensock.core
;
    class SimpleTimeline extends TweenCore
   {
      
      public var autoRemoveChildren:Bool = false;
      
      var _lastChild:TweenCore;
      
      var _firstChild:TweenCore;
      
      public function new(param1:ASObject = null)
      {
         super(0,param1);
      }
      
      @:isVar public var rawTime(get,never):Float;
public function  get_rawTime() : Float
      {
         return this.cachedTotalTime;
      }
      
      public function insert(param1:TweenCore, param2:ASAny = 0) : TweenCore
      {
         if(!param1.cachedOrphan && ASCompat.toBool(param1.timeline))
         {
            param1.timeline.remove(param1,true);
         }
         param1.timeline = this;
         param1.cachedStartTime = ASCompat.toNumber(param2) + param1.delay;
         if(param1.gc)
         {
            param1.setEnabled(true,true);
         }
         if(param1.cachedPaused)
         {
            param1.cachedPauseTime = param1.cachedStartTime + (this.rawTime - param1.cachedStartTime) / param1.cachedTimeScale;
         }
         if(_lastChild != null)
         {
            _lastChild.nextNode = param1;
         }
         else
         {
            _firstChild = param1;
         }
         param1.prevNode = _lastChild;
         _lastChild = param1;
         param1.nextNode = null;
         param1.cachedOrphan = false;
         return param1;
      }
      
      override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false) 
      {
         var _loc5_= Math.NaN;
         var _loc6_:TweenCore = null;
         var _loc4_= _firstChild;
         this.cachedTotalTime = param1;
         this.cachedTime = param1;
         while(_loc4_ != null)
         {
            _loc6_ = _loc4_.nextNode;
            if(_loc4_.active || param1 >= _loc4_.cachedStartTime && !_loc4_.cachedPaused && !_loc4_.gc)
            {
               if(!_loc4_.cachedReversed)
               {
                  _loc4_.renderTime((param1 - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale,param2,false);
               }
               else
               {
                  _loc5_ = _loc4_.cacheIsDirty ? _loc4_.totalDuration : _loc4_.cachedTotalDuration;
                  _loc4_.renderTime(_loc5_ - (param1 - _loc4_.cachedStartTime) * _loc4_.cachedTimeScale,param2,false);
               }
            }
            _loc4_ = _loc6_;
         }
      }
      
      public function remove(param1:TweenCore, param2:Bool = false) 
      {
         if(param1.cachedOrphan)
         {
            return;
         }
         if(!param2)
         {
            param1.setEnabled(false,true);
         }
         if(param1.nextNode != null)
         {
            param1.nextNode.prevNode = param1.prevNode;
         }
         else if(_lastChild == param1)
         {
            _lastChild = param1.prevNode;
         }
         if(param1.prevNode != null)
         {
            param1.prevNode.nextNode = param1.nextNode;
         }
         else if(_firstChild == param1)
         {
            _firstChild = param1.nextNode;
         }
         param1.cachedOrphan = true;
      }
   }


