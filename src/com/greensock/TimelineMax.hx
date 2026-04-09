package com.greensock
;
   import com.greensock.core.*;
   import com.greensock.events.TweenEvent;
   import flash.events.*;
   
    class TimelineMax extends TimelineLite implements IEventDispatcher
   {
      
      public static inline final version:Float = 1.67;
      
      var _cyclesComplete:Int = 0;
      
      var _dispatcher:EventDispatcher;
      
      var _hasUpdateListener:Bool = false;
      
      public var yoyo:Bool = false;
      
      var _repeatDelay:Float = Math.NaN;
      
      var _repeat:Int = 0;
      
      public function new(param1:ASObject = null)
      {
         super(param1);
         _repeat = ASCompat.toBool(this.vars.repeat) ? Std.int(ASCompat.toNumber(this.vars.repeat)) : 0;
         _repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
         _cyclesComplete = 0;
         this.yoyo = this.vars.yoyo == true;
         this.cacheIsDirty = true;
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null || this.vars.onRepeatListener != null || this.vars.onReverseCompleteListener != null)
         {
            initDispatcher();
         }
      }
      
      static function easeNone(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param1 / param4;
      }
      
      static function onInitTweenTo(param1:TweenLite, param2:TimelineMax, param3:Float) 
      {
         param2.paused = true;
         if(!Math.isNaN(param3))
         {
            param2.currentTime = param3;
         }
         if(ASCompat.toNumberField(param1.vars, "currentTime") != param2.currentTime)
         {
            param1.duration = Math.abs(ASCompat.toNumber(param1.vars.currentTime) - param2.currentTime) / param2.cachedTimeScale;
         }
      }
      
      public function dispatchEvent(param1:Event) : Bool
      {
         return _dispatcher == null ? false : _dispatcher.dispatchEvent(param1);
      }
      
      @:isVar public var currentLabel(get,never):String;
public function  get_currentLabel() : String
      {
         return getLabelBefore(this.cachedTime + 1e-8);
      }
      
      override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false) 
      {
         var _loc9_:TweenCore = null;
         var _loc10_= false;
         var _loc11_= false;
         var _loc12_= false;
         var _loc13_:TweenCore = null;
         var _loc14_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= 0;
         var _loc18_= false;
         var _loc19_= false;
         var _loc20_= false;
         if(this.gc)
         {
            this.setEnabled(true,false);
         }
         else if(!this.active && !this.cachedPaused)
         {
            this.active = true;
         }
         var _loc4_= this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
         var _loc5_= this.cachedTime;
         var _loc6_= this.cachedTotalTime;
         var _loc7_= this.cachedStartTime;
         var _loc8_= this.cachedTimeScale;
         var _loc15_= this.cachedPaused;
         if(param1 >= _loc4_)
         {
            if(_rawPrevTime <= _loc4_ && _rawPrevTime != param1)
            {
               this.cachedTotalTime = _loc4_;
               if(!this.cachedReversed && this.yoyo && _repeat % 2 != 0)
               {
                  this.cachedTime = 0;
                  forceChildrenToBeginning(0,param2);
               }
               else
               {
                  this.cachedTime = this.cachedDuration;
                  forceChildrenToEnd(this.cachedDuration,param2);
               }
               _loc10_ = !this.hasPausedChild();
               _loc11_ = true;
               if(this.cachedDuration == 0 && _loc10_ && (param1 == 0 || _rawPrevTime < 0))
               {
                  param3 = true;
               }
            }
         }
         else if(param1 <= 0)
         {
            if(param1 < 0)
            {
               this.active = false;
               if(this.cachedDuration == 0 && _rawPrevTime >= 0)
               {
                  param3 = true;
                  _loc10_ = true;
               }
            }
            else if(param1 == 0 && !this.initted)
            {
               param3 = true;
            }
            if(_rawPrevTime >= 0 && _rawPrevTime != param1)
            {
               this.cachedTotalTime = 0;
               this.cachedTime = 0;
               forceChildrenToBeginning(0,param2);
               _loc11_ = true;
               if(this.cachedReversed)
               {
                  _loc10_ = true;
               }
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = param1;
         }
         _rawPrevTime = param1;
         if(_repeat != 0)
         {
            _loc16_ = this.cachedDuration + _repeatDelay;
            _loc17_ = _cyclesComplete;
            _cyclesComplete = Std.int(this.cachedTotalTime / _loc16_) >> 0;
            if(_cyclesComplete == this.cachedTotalTime / _loc16_)
            {
               --_cyclesComplete;
            }
            if(_loc17_ != _cyclesComplete)
            {
               _loc12_ = true;
            }
            if(_loc10_)
            {
               if(this.yoyo && ASCompat.toBool(_repeat % 2))
               {
                  this.cachedTime = 0;
               }
            }
            else if(param1 > 0)
            {
               this.cachedTime = (this.cachedTotalTime / _loc16_ - _cyclesComplete) * _loc16_;
               if(this.yoyo && ASCompat.toBool(_cyclesComplete % 2))
               {
                  this.cachedTime = this.cachedDuration - this.cachedTime;
               }
               else if(this.cachedTime >= this.cachedDuration)
               {
                  this.cachedTime = this.cachedDuration;
               }
               if(this.cachedTime < 0)
               {
                  this.cachedTime = 0;
               }
            }
            else
            {
               _cyclesComplete = 0;
            }
            if(_loc12_ && !_loc10_ && (this.cachedTime != _loc5_ || param3))
            {
               _loc18_ = !this.yoyo || _cyclesComplete % 2 == 0;
               _loc19_ = !this.yoyo || _loc17_ % 2 == 0;
               _loc20_ = _loc18_ == _loc19_;
               if(_loc17_ > _cyclesComplete)
               {
                  _loc19_ = !_loc19_;
               }
               if(_loc19_)
               {
                  _loc5_ = forceChildrenToEnd(this.cachedDuration,param2);
                  if(_loc20_)
                  {
                     _loc5_ = forceChildrenToBeginning(0,true);
                  }
               }
               else
               {
                  _loc5_ = forceChildrenToBeginning(0,param2);
                  if(_loc20_)
                  {
                     _loc5_ = forceChildrenToEnd(this.cachedDuration,true);
                  }
               }
               _loc11_ = false;
            }
         }
         if(this.cachedTotalTime == _loc6_ && !param3)
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(_loc6_ == 0 && this.cachedTotalTime != 0 && !param2)
         {
            if(ASCompat.toBool(this.vars.onStart))
            {
               ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
            }
            if(_dispatcher != null)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
            }
         }
         if(!_loc11_)
         {
            if(this.cachedTime - _loc5_ > 0)
            {
               _loc9_ = _firstChild;
               while(_loc9_ != null)
               {
                  _loc13_ = _loc9_.nextNode;
                  if(this.cachedPaused && !_loc15_)
                  {
                     break;
                  }
                  if(_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= this.cachedTime && !_loc9_.gc)
                  {
                     if(!_loc9_.cachedReversed)
                     {
                        _loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,param2,false);
                     }
                     else
                     {
                        _loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
                        _loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,param2,false);
                     }
                  }
                  _loc9_ = _loc13_;
               }
            }
            else
            {
               _loc9_ = _lastChild;
               while(_loc9_ != null)
               {
                  _loc13_ = _loc9_.prevNode;
                  if(this.cachedPaused && !_loc15_)
                  {
                     break;
                  }
                  if(_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= _loc5_ && !_loc9_.gc)
                  {
                     if(!_loc9_.cachedReversed)
                     {
                        _loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,param2,false);
                     }
                     else
                     {
                        _loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
                        _loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,param2,false);
                     }
                  }
                  _loc9_ = _loc13_;
               }
            }
         }
         if(_hasUpdate && !param2)
         {
            ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
         }
         if(_hasUpdateListener && !param2)
         {
            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         }
         if(_loc12_ && !param2)
         {
            if(ASCompat.toBool(this.vars.onRepeat))
            {
               ASCompatMacro.applyClosure(this.vars.onRepeat, this.vars.onRepeatParams);
            }
            if(_dispatcher != null)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
            }
         }
         if(_loc10_ && (_loc7_ == this.cachedStartTime || _loc8_ != this.cachedTimeScale) && (_loc4_ >= this.totalDuration || this.cachedTime == 0))
         {
            complete(true,param2);
         }
      }
      
      public function addCallback(param1:ASFunction, param2:ASAny, param3:Array<ASAny> = null) : TweenLite
      {
         var _loc4_= new TweenLite(param1,0,{
            "onComplete":param1,
            "onCompleteParams":param3,
            "overwrite":0,
            "immediateRender":false
         });
         insert(_loc4_,param2);
         return _loc4_;
      }
      
      public function tweenFromTo(param1:ASAny, param2:ASAny, param3:ASObject = null) : TweenLite
      {
         var _loc4_= tweenTo(param2,param3);
         _loc4_.vars.onInitParams[2] = parseTimeOrLabel(param1);
         _loc4_.duration = Math.abs(ASCompat.toNumber(ASCompat.toNumber(_loc4_.vars.currentTime) - ASCompat.toNumber(_loc4_.vars.onInitParams[2]))) / this.cachedTimeScale;
         return _loc4_;
      }
      
      public function removeEventListener(param1:String, param2:ASFunction, param3:Bool = false) 
      {
         if(_dispatcher != null)
         {
            _dispatcher.removeEventListener(param1,param2,param3);
         }
      }
      
      override public function  set_currentTime(param1:Float) :Float      {
         if(_cyclesComplete == 0)
         {
            setTotalTime(param1,false);
         }
         else if(this.yoyo && _cyclesComplete % 2 == 1)
         {
            setTotalTime(this.duration - param1 + _cyclesComplete * (this.cachedDuration + _repeatDelay),false);
         }
         else
         {
            setTotalTime(param1 + _cyclesComplete * (this.duration + _repeatDelay),false);
         }
return param1;
      }
      
      public function addEventListener(param1:String, param2:ASFunction, param3:Bool = false, param4:Int = 0, param5:Bool = false) 
      {
         if(_dispatcher == null)
         {
            initDispatcher();
         }
         if(param1 == TweenEvent.UPDATE)
         {
            _hasUpdateListener = true;
         }
         _dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function tweenTo(param1:ASAny, param2:ASObject = null) : TweenLite
      {
         var _loc4_:String = null;
         var _loc5_:TweenLite = null;
         var _loc3_:ASObject = {
            "ease":easeNone,
            "overwrite":2,
            "useFrames":this.useFrames,
            "immediateRender":false
         };
         if (checkNullIteratee(param2)) for(_tmp_ in param2.___keys())
         {
            _loc4_  = _tmp_;
            _loc3_[_loc4_] = param2[_loc4_];
         }
         ASCompat.setProperty(_loc3_, "onInit", onInitTweenTo);
         ASCompat.setProperty(_loc3_, "onInitParams", ([null,this,Math.NaN] : Array<ASAny>));
         ASCompat.setProperty(_loc3_, "currentTime", parseTimeOrLabel(param1));
         _loc5_ = new TweenLite(this,ASCompat.thisOrDefault(Math.abs(ASCompat.toNumber(_loc3_.currentTime) - this.cachedTime) / this.cachedTimeScale , 0.001),_loc3_);
         _loc5_.vars.onInitParams[0] = _loc5_;
         return _loc5_;
      }
      
      public function hasEventListener(param1:String) : Bool
      {
         return _dispatcher == null ? false : _dispatcher.hasEventListener(param1);
      }
      
      function initDispatcher() 
      {
         if(_dispatcher == null)
         {
            _dispatcher = new EventDispatcher(this);
         }
         if(Reflect.isFunction(this.vars.onStartListener ))
         {
            _dispatcher.addEventListener(TweenEvent.START,ASCompat.asFunction(this.vars.onStartListener),false,0,true);
         }
         if(Reflect.isFunction(this.vars.onUpdateListener ))
         {
            _dispatcher.addEventListener(TweenEvent.UPDATE,ASCompat.asFunction(this.vars.onUpdateListener),false,0,true);
            _hasUpdateListener = true;
         }
         if(Reflect.isFunction(this.vars.onCompleteListener ))
         {
            _dispatcher.addEventListener(TweenEvent.COMPLETE,ASCompat.asFunction(this.vars.onCompleteListener),false,0,true);
         }
         if(Reflect.isFunction(this.vars.onRepeatListener ))
         {
            _dispatcher.addEventListener(TweenEvent.REPEAT,ASCompat.asFunction(this.vars.onRepeatListener),false,0,true);
         }
         if(Reflect.isFunction(this.vars.onReverseCompleteListener ))
         {
            _dispatcher.addEventListener(TweenEvent.REVERSE_COMPLETE,ASCompat.asFunction(this.vars.onReverseCompleteListener),false,0,true);
         }
      }
      
            
      @:isVar public var repeat(get,set):Int;
public function  get_repeat() : Int
      {
         return _repeat;
      }
      
      public function getLabelBefore(param1:Float = null) : String
{
         if (param1 == null) param1 = Math.NaN;
         if(!ASCompat.floatAsBool(param1) && param1 != 0)
         {
            param1 = this.cachedTime;
         }
         var _loc2_= getLabelsArray();
         var _loc3_= _loc2_.length;
         while(--_loc3_ > -1)
         {
            if(ASCompat.toNumberField(_loc2_[_loc3_], "time") < param1)
            {
               return _loc2_[_loc3_].name;
            }
         }
         return null;
      }
      
      public function willTrigger(param1:String) : Bool
      {
         return _dispatcher == null ? false : _dispatcher.willTrigger(param1);
      }
      
            
      @:isVar public var totalProgress(get,set):Float;
public function  get_totalProgress() : Float
      {
         return this.cachedTotalTime / this.totalDuration;
      }
function  set_totalProgress(param1:Float) :Float      {
         setTotalTime(this.totalDuration * param1,false);
return param1;
      }
      
      function getLabelsArray() : Array<ASAny>
      {
         var _loc2_:String = null;
         var _loc1_:Array<ASAny> = [];
         final __ax4_iter_136:ASObject = _labels;
         if (checkNullIteratee(__ax4_iter_136)) for(_tmp_ in __ax4_iter_136.___keys())
         {
            _loc2_  = _tmp_;
            _loc1_[_loc1_.length] = {
               "time":_labels[_loc2_],
               "name":_loc2_
            };
         }
         ASCompat.ASArray.sortOn(_loc1_, "time",ASCompat.ASArray.NUMERIC);
         return _loc1_;
      }
      
      public function removeCallback(param1:ASFunction, param2:ASAny = null) : Bool
      {
         var _loc3_:Array<ASAny> = null;
         var _loc4_= false;
         var _loc5_= 0;
         if(param2 == null)
         {
            return killTweensOf(param1,false);
         }
         if(ASCompat.typeof(param2) == "string")
         {
            if(!_labels.hasOwnProperty(param2 ))
            {
               return false;
            }
            param2 = _labels[param2];
         }
         _loc3_ = getTweensOf(param1,false);
         _loc5_ = _loc3_.length;
         while(--_loc5_ > -1)
         {
            if(_loc3_[_loc5_].cachedStartTime == param2)
            {
               remove(ASCompat.dynamicAs(_loc3_[_loc5_] , TweenCore));
               _loc4_ = true;
            }
         }
         return _loc4_;
      }
      
            
      @:isVar public var repeatDelay(get,set):Float;
public function  get_repeatDelay() : Float
      {
         return _repeatDelay;
      }
function  set_repeatDelay(param1:Float) :Float      {
         _repeatDelay = param1;
         setDirtyCache(true);
return param1;
      }
function  set_repeat(param1:Int) :Int      {
         _repeat = param1;
         setDirtyCache(true);
return param1;
      }
      
      override public function  get_totalDuration() : Float
      {
         var _loc1_= Math.NaN;
         if(this.cacheIsDirty)
         {
            _loc1_ = super.totalDuration;
            this.cachedTotalDuration = _repeat == -1 ? 999999999999 : this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat;
         }
         return this.cachedTotalDuration;
      }
      
      override public function complete(param1:Bool = false, param2:Bool = false) 
      {
         super.complete(param1,param2);
         if(ASCompat.toBool(_dispatcher) && !param2)
         {
            if(this.cachedReversed && this.cachedTotalTime == 0 && this.cachedDuration != 0)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
            }
            else
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
            }
         }
      }
      
      override public function invalidate() 
      {
         _repeat = ASCompat.toBool(this.vars.repeat) ? Std.int(ASCompat.toNumber(this.vars.repeat)) : 0;
         _repeatDelay = ASCompat.toBool(this.vars.repeatDelay) ? ASCompat.toNumber(this.vars.repeatDelay) : 0;
         this.yoyo = this.vars.yoyo == true;
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null || this.vars.onRepeatListener != null || this.vars.onReverseCompleteListener != null)
         {
            initDispatcher();
         }
         setDirtyCache(true);
         super.invalidate();
      }
      
      public function getActive(param1:Bool = true, param2:Bool = true, param3:Bool = false) : Array<ASAny>
      {
         var _loc10_:Int;
         var _loc6_= 0;
         var _loc7_:TweenCore = null;
         var _loc4_:Array<ASAny> = [];
         var _loc5_= getChildren(param1,param2,param3);
         var _loc8_= _loc5_.length;
         var _loc9_= 0;
         _loc6_ = 0;
         while(_loc6_ < _loc8_)
         {
            _loc7_ = ASCompat.dynamicAs(_loc5_[_loc6_], com.greensock.core.TweenCore);
            if(!_loc7_.cachedPaused && _loc7_.timeline.cachedTotalTime >= _loc7_.cachedStartTime && _loc7_.timeline.cachedTotalTime < _loc7_.cachedStartTime + _loc7_.cachedTotalDuration / _loc7_.cachedTimeScale && !OverwriteManager.getGlobalPaused(_loc7_.timeline))
            {
               _loc4_[ASCompat.toInt(_loc10_ = _loc9_++)] = _loc5_[_loc6_];
            }
            _loc6_ += 1;
         }
         return _loc4_;
      }
      
      public function getLabelAfter(param1:Float = null) : String
{
         if (param1 == null) param1 = Math.NaN;
         if(!ASCompat.floatAsBool(param1) && param1 != 0)
         {
            param1 = this.cachedTime;
         }
         var _loc2_= getLabelsArray();
         var _loc3_= _loc2_.length;
         var _loc4_= 0;
         while(_loc4_ < _loc3_)
         {
            if(ASCompat.toNumberField(_loc2_[_loc4_], "time") > param1)
            {
               return _loc2_[_loc4_].name;
            }
            _loc4_ += 1;
         }
         return null;
      }
   }


