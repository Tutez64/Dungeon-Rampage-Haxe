package com.greensock
;
   import com.greensock.core.*;
   
    class TimelineLite extends SimpleTimeline
   {
      
      public static inline final version:Float = 1.66;
      
      static var _overwriteMode:Int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init(2);
      
      var _endCaps:Array<ASAny>;
      
      var _labels:ASObject;
      
      public function new(param1:ASObject = null)
      {
         super(param1);
         _endCaps = [null,null];
         _labels = {};
         this.autoRemoveChildren = this.vars.autoRemoveChildren == true;
         _hasUpdate = ASCompat.typeof(this.vars.onUpdate) == "function";
         if(Std.isOfType(this.vars.tweens , Array))
         {
            this.insertMultiple(ASCompat.dynamicAs(this.vars.tweens, Array),0,this.vars.align != null ? this.vars.align : "normal",ASCompat.toBool(this.vars.stagger) ? ASCompat.toNumber(this.vars.stagger) : 0);
         }
      }
      
            
      @:isVar public var timeScale(get,set):Float;
public function  set_timeScale(param1:Float) :Float      {
         if(param1 == 0)
         {
            param1 = 0.0001;
         }
         var _loc2_= ASCompat.toBool(this.cachedPauseTime) || this.cachedPauseTime == 0 ? this.cachedPauseTime : this.timeline.cachedTotalTime;
         this.cachedStartTime = _loc2_ - (_loc2_ - this.cachedStartTime) * this.cachedTimeScale / param1;
         this.cachedTimeScale = param1;
         setDirtyCache(false);
return param1;
      }
      
      public function stop() 
      {
         this.paused = true;
      }
      
      override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false) 
      {
         var _loc8_:TweenCore = null;
         var _loc9_= false;
         var _loc10_= false;
         var _loc11_:TweenCore = null;
         var _loc12_= Math.NaN;
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
         var _loc6_= this.cachedStartTime;
         var _loc7_= this.cachedTimeScale;
         var _loc13_= this.cachedPaused;
         if(param1 >= _loc4_)
         {
            if(_rawPrevTime <= _loc4_ && _rawPrevTime != param1)
            {
               this.cachedTotalTime = this.cachedTime = _loc4_;
               forceChildrenToEnd(_loc4_,param2);
               _loc9_ = !this.hasPausedChild();
               _loc10_ = true;
               if(this.cachedDuration == 0 && _loc9_ && (param1 == 0 || _rawPrevTime < 0))
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
                  _loc9_ = true;
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
               _loc10_ = true;
               if(this.cachedReversed)
               {
                  _loc9_ = true;
               }
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = param1;
         }
         _rawPrevTime = param1;
         if(this.cachedTime == _loc5_ && !param3)
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(_loc5_ == 0 && ASCompat.toBool(this.vars.onStart) && this.cachedTime != 0 && !param2)
         {
            ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
         }
         if(!_loc10_)
         {
            if(this.cachedTime - _loc5_ > 0)
            {
               _loc8_ = _firstChild;
               while(_loc8_ != null)
               {
                  _loc11_ = _loc8_.nextNode;
                  if(this.cachedPaused && !_loc13_)
                  {
                     break;
                  }
                  if(_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= this.cachedTime && !_loc8_.gc)
                  {
                     if(!_loc8_.cachedReversed)
                     {
                        _loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,param2,false);
                     }
                     else
                     {
                        _loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
                        _loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,param2,false);
                     }
                  }
                  _loc8_ = _loc11_;
               }
            }
            else
            {
               _loc8_ = _lastChild;
               while(_loc8_ != null)
               {
                  _loc11_ = _loc8_.prevNode;
                  if(this.cachedPaused && !_loc13_)
                  {
                     break;
                  }
                  if(_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= _loc5_ && !_loc8_.gc)
                  {
                     if(!_loc8_.cachedReversed)
                     {
                        _loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,param2,false);
                     }
                     else
                     {
                        _loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
                        _loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,param2,false);
                     }
                  }
                  _loc8_ = _loc11_;
               }
            }
         }
         if(_hasUpdate && !param2)
         {
            ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
         }
         if(_loc9_ && (_loc6_ == this.cachedStartTime || _loc7_ != this.cachedTimeScale) && (_loc4_ >= this.totalDuration || this.cachedTime == 0))
         {
            complete(true,param2);
         }
      }
      
      override public function remove(param1:TweenCore, param2:Bool = false) 
      {
         if(param1.cachedOrphan)
         {
            return;
         }
         if(!param2)
         {
            param1.setEnabled(false,true);
         }
         var _loc3_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         var _loc4_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore) : _lastChild, com.greensock.core.TweenCore);
         if(param1.nextNode != null)
         {
            param1.nextNode.prevNode = param1.prevNode;
         }
         else if(_loc4_ == param1)
         {
            _loc4_ = param1.prevNode;
         }
         if(param1.prevNode != null)
         {
            param1.prevNode.nextNode = param1.nextNode;
         }
         else if(_loc3_ == param1)
         {
            _loc3_ = param1.nextNode;
         }
         if(this.gc)
         {
            _endCaps[0] = _loc3_;
            _endCaps[1] = _loc4_;
         }
         else
         {
            _firstChild = _loc3_;
            _lastChild = _loc4_;
         }
         param1.cachedOrphan = true;
         setDirtyCache(true);
      }
      
            
      @:isVar public var currentProgress(get,set):Float;
public function  get_currentProgress() : Float
      {
         return this.cachedTime / this.duration;
      }
      
      override public function  get_totalDuration() : Float
      {
         var _loc1_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc3_:TweenCore = null;
         var _loc4_= Math.NaN;
         var _loc5_:TweenCore = null;
         if(this.cacheIsDirty)
         {
            _loc1_ = 0;
            _loc3_ = ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
            _loc4_ = Math.NEGATIVE_INFINITY;
            while(_loc3_ != null)
            {
               _loc5_ = _loc3_.nextNode;
               if(_loc3_.cachedStartTime < _loc4_)
               {
                  this.insert(_loc3_,_loc3_.cachedStartTime - _loc3_.delay);
                  _loc4_ = _loc3_.prevNode.cachedStartTime;
               }
               else
               {
                  _loc4_ = _loc3_.cachedStartTime;
               }
               if(_loc3_.cachedStartTime < 0)
               {
                  _loc1_ -= _loc3_.cachedStartTime;
                  this.shiftChildren(-_loc3_.cachedStartTime,false,-9999999999);
               }
               _loc2_ = _loc3_.cachedStartTime + _loc3_.totalDuration / _loc3_.cachedTimeScale;
               if(_loc2_ > _loc1_)
               {
                  _loc1_ = _loc2_;
               }
               _loc3_ = _loc5_;
            }
            this.cachedDuration = this.cachedTotalDuration = _loc1_;
            this.cacheIsDirty = false;
         }
         return this.cachedTotalDuration;
      }
      
      public function gotoAndPlay(param1:ASAny, param2:Bool = true) 
      {
         setTotalTime(parseTimeOrLabel(param1),param2);
         play();
      }
      
      public function appendMultiple(param1:Array<ASAny>, param2:Float = 0, param3:String = "normal", param4:Float = 0) : Array<ASAny>
      {
         return insertMultiple(param1,this.duration + param2,param3,param4);
      }
function  set_currentProgress(param1:Float) :Float      {
         setTotalTime(this.duration * param1,false);
return param1;
      }
      
      public function clear(param1:Array<ASAny> = null) 
      {
         if(param1 == null)
         {
            param1 = getChildren(false,true,true);
         }
         var _loc2_= param1.length;
         while(--_loc2_ > -1)
         {
            cast(param1[_loc2_], TweenCore).setEnabled(false,false);
         }
      }
      
      public function prepend(param1:TweenCore, param2:Bool = false) : TweenCore
      {
         shiftChildren(param1.totalDuration / param1.cachedTimeScale + param1.delay,param2,0);
         return insert(param1,0);
      }
      
      public function removeLabel(param1:String) : Float
      {
         var _loc2_= ASCompat.toNumber(_labels[param1]);
         ASCompat.deleteProperty(_labels, param1);
         return _loc2_;
      }
      
      function parseTimeOrLabel(param1:ASAny) : Float
      {
         if(ASCompat.typeof(param1) == "string")
         {
            if(!_labels.hasOwnProperty(param1 ))
            {
               throw new Error("TimelineLite error: the " + Std.string(param1) + " label was not found.");
            }
            return getLabelTime(ASCompat.toString(param1));
         }
         return ASCompat.toNumber(param1);
      }
      
      public function addLabel(param1:String, param2:Float) 
      {
         _labels[param1] = param2;
      }
      
      public function hasPausedChild() : Bool
      {
         var _loc1_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         while(_loc1_ != null)
         {
            if(_loc1_.cachedPaused || Std.isOfType(_loc1_ , TimelineLite) && ASCompat.reinterpretAs(_loc1_ , TimelineLite).hasPausedChild())
            {
               return true;
            }
            _loc1_ = _loc1_.nextNode;
         }
         return false;
      }
      
      public function getTweensOf(param1:ASObject, param2:Bool = true) : Array<ASAny>
      {
         var _loc8_:Int;
         var _loc5_= 0;
         var _loc3_= getChildren(param2,true,false);
         var _loc4_:Array<ASAny> = [];
         var _loc6_= _loc3_.length;
         var _loc7_= 0;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            if(cast(_loc3_[_loc5_], TweenLite).target == param1)
            {
               _loc4_[ASCompat.toInt(_loc8_ = _loc7_++)] = _loc3_[_loc5_];
            }
            _loc5_ += 1;
         }
         return _loc4_;
      }
      
      public function gotoAndStop(param1:ASAny, param2:Bool = true) 
      {
         setTotalTime(parseTimeOrLabel(param1),param2);
         this.paused = true;
      }
      
      public function append(param1:TweenCore, param2:Float = 0) : TweenCore
      {
         return insert(param1,this.duration + param2);
      }
      
      override public function  get_duration() : Float
      {
         var _loc1_= Math.NaN;
         if(this.cacheIsDirty)
         {
            _loc1_ = this.totalDuration;
         }
         return this.cachedDuration;
      }
      
      @:isVar public var useFrames(get,never):Bool;
public function  get_useFrames() : Bool
      {
         var _loc1_= this.timeline;
         while(_loc1_.timeline != null)
         {
            _loc1_ = _loc1_.timeline;
         }
         return _loc1_ == TweenLite.rootFramesTimeline;
      }
      
      public function shiftChildren(param1:Float, param2:Bool = false, param3:Float = 0) 
      {
         var __ax4_iter_137:ASObject;
         var _loc5_:String = null;
         var _loc4_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         while(_loc4_ != null)
         {
            if(_loc4_.cachedStartTime >= param3)
            {
               _loc4_.cachedStartTime += param1;
            }
            _loc4_ = _loc4_.nextNode;
         }
         if(param2)
         {
            __ax4_iter_137 = _labels;
            if (checkNullIteratee(__ax4_iter_137)) for(_tmp_ in __ax4_iter_137.___keys())
            {
               _loc5_  = _tmp_;
               if(ASCompat.toNumber(_labels[_loc5_]) >= param3)
               {
                  _labels[_loc5_] += param1;
               }
            }
         }
         this.setDirtyCache(true);
      }
      
      public function _goto(param1:ASAny, param2:Bool = true) 
      {
         setTotalTime(parseTimeOrLabel(param1),param2);
      }
      
      public function killTweensOf(param1:ASObject, param2:Bool = true, param3:ASObject = null) : Bool
      {
         var _loc6_:TweenLite = null;
         var _loc4_= getTweensOf(param1,param2);
         var _loc5_= _loc4_.length;
         while(--_loc5_ > -1)
         {
            _loc6_ = ASCompat.dynamicAs(_loc4_[_loc5_], com.greensock.TweenLite);
            if(param3 != null)
            {
               _loc6_.killVars(param3);
            }
            if(param3 == null || _loc6_.cachedPT1 == null && _loc6_.initted)
            {
               _loc6_.setEnabled(false,false);
            }
         }
         return _loc4_.length > 0;
      }
      
      override public function  set_duration(param1:Float) :Float      {
         if(this.duration != 0 && param1 != 0)
         {
            this.timeScale = this.duration / param1;
         }
return param1;
      }
      
      public function insertMultiple(param1:Array<ASAny>, param2:ASAny = 0, param3:String = "normal", param4:Float = 0) : Array<ASAny>
      {
         var _loc5_= 0;
         var _loc6_:TweenCore = null;
         var _loc7_= ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(param2) , 0));
         var _loc8_= param1.length;
         if(ASCompat.typeof(param2) == "string")
         {
            if(!_labels.hasOwnProperty(param2 ))
            {
               addLabel(param2,this.duration);
            }
            _loc7_ = ASCompat.toNumber(_labels[param2]);
         }
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc6_ = ASCompat.dynamicAs(param1[_loc5_] , TweenCore);
            insert(_loc6_,_loc7_);
            if(param3 == "sequence")
            {
               _loc7_ = _loc6_.cachedStartTime + _loc6_.totalDuration / _loc6_.cachedTimeScale;
            }
            else if(param3 == "start")
            {
               _loc6_.cachedStartTime -= _loc6_.delay;
            }
            _loc7_ += param4;
            _loc5_ += 1;
         }
         return param1;
      }
      
      public function getLabelTime(param1:String) : Float
      {
         return _labels.hasOwnProperty(param1 ) ? ASCompat.toNumber(_labels[param1]) : -1;
      }
      
      override public function  get_rawTime() : Float
      {
         if(this.cachedTotalTime != 0 && this.cachedTotalTime != this.cachedTotalDuration)
         {
            return this.cachedTotalTime;
         }
         return (this.timeline.rawTime - this.cachedStartTime) * this.cachedTimeScale;
      }
      
      override public function  set_totalDuration(param1:Float) :Float      {
         if(this.totalDuration != 0 && param1 != 0)
         {
            this.timeScale = this.totalDuration / param1;
         }
return param1;
      }
      
      public function getChildren(param1:Bool = true, param2:Bool = true, param3:Bool = true, param4:Float = -9999999999) : Array<ASAny>
      {
         var _loc8_:Int;
         var _loc5_:Array<ASAny> = [];
         var _loc6_= 0;
         var _loc7_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         while(_loc7_ != null)
         {
            if(_loc7_.cachedStartTime >= param4)
            {
               if(Std.isOfType(_loc7_ , TweenLite))
               {
                  if(param2)
                  {
                     _loc5_[ASCompat.toInt(_loc8_ = _loc6_++)] = _loc7_;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _loc5_[ASCompat.toInt(_loc8_ = _loc6_++)] = _loc7_;
                  }
                  if(param1)
                  {
                     _loc5_ = _loc5_.concat(cast(_loc7_, TimelineLite).getChildren(true,param2,param3));
                     _loc6_ = _loc5_.length;
                  }
               }
            }
            _loc7_ = _loc7_.nextNode;
         }
         return _loc5_;
      }
      
      function forceChildrenToEnd(param1:Float, param2:Bool = false) : Float
      {
         var _loc4_:TweenCore = null;
         var _loc5_= Math.NaN;
         var _loc3_= _firstChild;
         var _loc6_= this.cachedPaused;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.nextNode;
            if(this.cachedPaused && !_loc6_)
            {
               break;
            }
            if(_loc3_.active || !_loc3_.cachedPaused && !_loc3_.gc && (_loc3_.cachedTotalTime != _loc3_.cachedTotalDuration || _loc3_.cachedDuration == 0))
            {
               if(param1 == this.cachedDuration && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == this.cachedDuration))
               {
                  _loc3_.renderTime(_loc3_.cachedReversed ? 0 : _loc3_.cachedTotalDuration,param2,false);
               }
               else if(!_loc3_.cachedReversed)
               {
                  _loc3_.renderTime((param1 - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,param2,false);
               }
               else
               {
                  _loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
                  _loc3_.renderTime(_loc5_ - (param1 - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,param2,false);
               }
            }
            _loc3_ = _loc4_;
         }
         return param1;
      }
      
      function forceChildrenToBeginning(param1:Float, param2:Bool = false) : Float
      {
         var _loc4_:TweenCore = null;
         var _loc5_= Math.NaN;
         var _loc3_= _lastChild;
         var _loc6_= this.cachedPaused;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.prevNode;
            if(this.cachedPaused && !_loc6_)
            {
               break;
            }
            if(_loc3_.active || !_loc3_.cachedPaused && !_loc3_.gc && (_loc3_.cachedTotalTime != 0 || _loc3_.cachedDuration == 0))
            {
               if(param1 == 0 && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == 0))
               {
                  _loc3_.renderTime(_loc3_.cachedReversed ? _loc3_.cachedTotalDuration : 0,param2,false);
               }
               else if(!_loc3_.cachedReversed)
               {
                  _loc3_.renderTime((param1 - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,param2,false);
               }
               else
               {
                  _loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
                  _loc3_.renderTime(_loc5_ - (param1 - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,param2,false);
               }
            }
            _loc3_ = _loc4_;
         }
         return param1;
      }
      
      override public function insert(param1:TweenCore, param2:ASAny = 0) : TweenCore
      {
         var _loc5_:TweenCore = null;
         var _loc6_= Math.NaN;
         var _loc7_:SimpleTimeline = null;
         if(ASCompat.typeof(param2) == "string")
         {
            if(!_labels.hasOwnProperty(param2 ))
            {
               addLabel(param2,this.duration);
            }
            param2 = ASCompat.toNumber(_labels[param2]);
         }
         if(!param1.cachedOrphan && ASCompat.toBool(param1.timeline))
         {
            param1.timeline.remove(param1,true);
         }
         param1.timeline = this;
         param1.cachedStartTime = ASCompat.toNumber(param2) + param1.delay;
         if(param1.cachedPaused)
         {
            param1.cachedPauseTime = param1.cachedStartTime + (this.rawTime - param1.cachedStartTime) / param1.cachedTimeScale;
         }
         if(param1.gc)
         {
            param1.setEnabled(true,true);
         }
         setDirtyCache(true);
         var _loc3_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         var _loc4_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore) : _lastChild, com.greensock.core.TweenCore);
         if(_loc4_ == null)
         {
            _loc3_ = _loc4_ = param1;
            param1.nextNode = param1.prevNode = null;
         }
         else
         {
            _loc5_ = _loc4_;
            _loc6_ = param1.cachedStartTime;
            while(_loc5_ != null && _loc6_ < _loc5_.cachedStartTime)
            {
               _loc5_ = _loc5_.prevNode;
            }
            if(_loc5_ == null)
            {
               _loc3_.prevNode = param1;
               param1.nextNode = _loc3_;
               param1.prevNode = null;
               _loc3_ = param1;
            }
            else
            {
               if(_loc5_.nextNode != null)
               {
                  _loc5_.nextNode.prevNode = param1;
               }
               else if(_loc5_ == _loc4_)
               {
                  _loc4_ = param1;
               }
               param1.prevNode = _loc5_;
               param1.nextNode = _loc5_.nextNode;
               _loc5_.nextNode = param1;
            }
         }
         param1.cachedOrphan = false;
         if(this.gc)
         {
            _endCaps[0] = _loc3_;
            _endCaps[1] = _loc4_;
         }
         else
         {
            _firstChild = _loc3_;
            _lastChild = _loc4_;
         }
         if(this.gc && !this.cachedPaused && this.cachedStartTime + (param1.cachedStartTime + param1.cachedTotalDuration / param1.cachedTimeScale) / this.cachedTimeScale > this.timeline.cachedTime)
         {
            if(this.timeline == TweenLite.rootTimeline || this.timeline == TweenLite.rootFramesTimeline)
            {
               this.setTotalTime(this.cachedTotalTime,true);
            }
            this.setEnabled(true,false);
            _loc7_ = this.timeline;
            while(_loc7_.gc && ASCompat.toBool(_loc7_.timeline))
            {
               if(_loc7_.cachedStartTime + _loc7_.totalDuration / _loc7_.cachedTimeScale > _loc7_.timeline.cachedTime)
               {
                  _loc7_.setEnabled(true,false);
               }
               _loc7_ = _loc7_.timeline;
            }
         }
         return param1;
      }
      
      override public function invalidate() 
      {
         var _loc1_= ASCompat.dynamicAs(this.gc ? ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore) : _firstChild, com.greensock.core.TweenCore);
         while(_loc1_ != null)
         {
            _loc1_.invalidate();
            _loc1_ = _loc1_.nextNode;
         }
      }
function  get_timeScale() : Float
      {
         return this.cachedTimeScale;
      }
      
      public function prependMultiple(param1:Array<ASAny>, param2:String = "normal", param3:Float = 0, param4:Bool = false) : Array<ASAny>
      {
         var _loc5_= new TimelineLite({
            "tweens":param1,
            "align":param2,
            "stagger":param3
         });
         shiftChildren(_loc5_.duration,param4,0);
         insertMultiple(param1,0,param2,param3);
         _loc5_.kill();
         return param1;
      }
      
      override public function setEnabled(param1:Bool, param2:Bool = false) : Bool
      {
         var _loc3_:TweenCore = null;
         if(param1 == this.gc)
         {
            if(param1)
            {
               _firstChild = _loc3_ = ASCompat.dynamicAs(_endCaps[0], com.greensock.core.TweenCore);
               _lastChild = ASCompat.dynamicAs(_endCaps[1], com.greensock.core.TweenCore);
               _endCaps = [null,null];
            }
            else
            {
               _loc3_ = _firstChild;
               _endCaps = [_firstChild,_lastChild];
               _firstChild = _lastChild = null;
            }
            while(_loc3_ != null)
            {
               _loc3_.setEnabled(param1,true);
               _loc3_ = _loc3_.nextNode;
            }
         }
         return super.setEnabled(param1,param2);
      }
   }


