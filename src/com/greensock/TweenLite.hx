package com.greensock
;
   import com.greensock.core.*;
   import com.greensock.plugins.*;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   
    class TweenLite extends TweenCore
   {
      
      public static var rootTimeline:SimpleTimeline;
      
      public static var onPluginEvent:ASFunction;
      
      public static var rootFramesTimeline:SimpleTimeline;
      
      public static var overwriteManager:ASObject;
      
      public static var rootFrame:Float = Math.NaN;
      
      public static inline final version:Float = 11.63;
      
      public static var plugins:ASObject = {};
      
      public static var fastEaseLookup:ASDictionary<ASAny,ASAny> = new ASDictionary(false);
      
      public static var killDelayedCallsTo:ASFunction = TweenLite.killTweensOf;
      
      public static var defaultEase:ASFunction = TweenLite.easeOut;
      
      public static var masterList:ASDictionary<ASAny,ASAny> = new ASDictionary(false);
      
      static var _shape:Shape = new Shape();
      
      static var _reservedProps:ASObject = {
         "ease":1,
         "delay":1,
         "overwrite":1,
         "onComplete":1,
         "onCompleteParams":1,
         "useFrames":1,
         "runBackwards":1,
         "startAt":1,
         "onUpdate":1,
         "onUpdateParams":1,
         "onStart":1,
         "onStartParams":1,
         "onInit":1,
         "onInitParams":1,
         "onReverseComplete":1,
         "onReverseCompleteParams":1,
         "onRepeat":1,
         "onRepeatParams":1,
         "proxiedEase":1,
         "easeParams":1,
         "yoyo":1,
         "onCompleteListener":1,
         "onUpdateListener":1,
         "onStartListener":1,
         "onReverseCompleteListener":1,
         "onRepeatListener":1,
         "orientToBezier":1,
         "timeScale":1,
         "immediateRender":1,
         "repeat":1,
         "repeatDelay":1,
         "timeline":1,
         "data":1,
         "paused":1
      };
      
      var _hasPlugins:Bool = false;
      
      public var propTweenLookup:ASObject;
      
      public var cachedPT1:PropTween;
      
      var _overwrite:Int = 0;
      
      var _ease:ASFunction;
      
      public var target:ASObject;
      
      public var ratio:Float = 0;
      
      var _overwrittenProps:ASObject;
      
      var _notifyPluginsOfEnabled:Bool = false;
      
      public function new(param1:ASObject, param2:Float, param3:ASObject)
      {
         var _loc5_:TweenLite = null;
         super(param2,param3);
         if(param1 == null)
         {
            throw new Error("Cannot tween a null object.");
         }
         this.target = param1;
         if(Std.isOfType(this.target , TweenCore) && ASCompat.toBool(this.vars.timeScale))
         {
            this.cachedTimeScale = 1;
         }
         propTweenLookup = {};
         _ease = defaultEase;
         _overwrite = ASCompat.toNumber(param3.overwrite) <= -1 || !ASCompat.toBool(overwriteManager.enabled) && ASCompat.toNumberField(param3, "overwrite") > 1 ? ASCompat.toInt(overwriteManager.mode) : ASCompat.toInt(param3.overwrite);
         var _loc4_:Array<ASAny> = ASCompat.dynamicAs(masterList[param1], Array);
         if(_loc4_ == null)
         {
            masterList[param1] = [this];
         }
         else if(_overwrite == 1)
         {
            if (checkNullIteratee(_loc4_)) for (_tmp_ in _loc4_)
            {
               _loc5_  = ASCompat.dynamicAs(_tmp_, TweenLite);
               if(!_loc5_.gc)
               {
                  _loc5_.setEnabled(false,false);
               }
            }
            masterList[param1] = [this];
         }
         else
         {
            _loc4_[_loc4_.length] = this;
         }
         if(this.active || ASCompat.toBool(this.vars.immediateRender))
         {
            renderTime(0,false,true);
         }
      }
      
      public static function initClass() 
      {
         rootFrame = 0;
         rootTimeline = new SimpleTimeline(null);
         rootFramesTimeline = new SimpleTimeline(null);
         rootTimeline.cachedStartTime = flash.Lib.getTimer() * 0.001;
         rootFramesTimeline.cachedStartTime = rootFrame;
         rootTimeline.autoRemoveChildren = true;
         rootFramesTimeline.autoRemoveChildren = true;
         _shape.addEventListener(Event.ENTER_FRAME,updateAll,false,0,true);
         if(overwriteManager == null)
         {
            overwriteManager = {
               "mode":1,
               "enabled":false
            };
         }
      }
      
      public static function killTweensOf(param1:ASObject, param2:Bool = false, param3:ASObject = null) 
      {
         var _loc4_:Array<ASAny> = null;
         var _loc5_= 0;
         var _loc6_:TweenLite = null;
         if(masterList.exists(param1 ))
         {
            _loc4_ = ASCompat.dynamicAs(masterList[param1], Array);
            _loc5_ = _loc4_.length;
            while(--_loc5_ > -1)
            {
               _loc6_ = ASCompat.dynamicAs(_loc4_[_loc5_], TweenLite);
               if(!_loc6_.gc)
               {
                  if(param2)
                  {
                     _loc6_.complete(false,false);
                  }
                  if(param3 != null)
                  {
                     _loc6_.killVars(param3);
                  }
                  if(param3 == null || _loc6_.cachedPT1 == null && _loc6_.initted)
                  {
                     _loc6_.setEnabled(false,false);
                  }
               }
            }
            if(param3 == null)
            {
               masterList.remove(param1);
            }
         }
      }
      
      public static function from(param1:ASObject, param2:Float, param3:ASObject) : TweenLite
      {
         if(ASCompat.toBool(param3.isGSVars))
         {
            param3 = param3.vars;
         }
         ASCompat.setProperty(param3, "runBackwards", true);
         if(!param3.hasOwnProperty("immediateRender" ))
         {
            ASCompat.setProperty(param3, "immediateRender", true);
         }
         return new TweenLite(param1,param2,param3);
      }
      
      static function easeOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return 1 - (param1 = 1 - param1 / param4) * param1;
      }
      
      public static function delayedCall(param1:Float, param2:ASFunction, param3:Array<ASAny> = null, param4:Bool = false) : TweenLite
      {
         return new TweenLite(param2,0,{
            "delay":param1,
            "onComplete":param2,
            "onCompleteParams":param3,
            "immediateRender":false,
            "useFrames":param4,
            "overwrite":0
         });
      }
      
      static function updateAll(param1:Event = null) 
      {
         var _loc2_:ASDictionary<ASAny,ASAny> = null;
         var _loc3_:ASObject = null;
         var _loc4_:Array<ASAny> = null;
         var _loc5_= 0;
         rootTimeline.renderTime((flash.Lib.getTimer() * 0.001 - rootTimeline.cachedStartTime) * rootTimeline.cachedTimeScale,false,false);
         rootFrame += 1;
         rootFramesTimeline.renderTime((rootFrame - rootFramesTimeline.cachedStartTime) * rootFramesTimeline.cachedTimeScale,false,false);
         if(!ASCompat.floatAsBool(rootFrame % 60))
         {
            _loc2_ = masterList;
            if (checkNullIteratee(_loc2_)) for(_tmp_ in _loc2_.keys())
            {
               _loc3_  = _tmp_;
               _loc4_ = ASCompat.dynamicAs(_loc2_[_loc3_], Array);
               _loc5_ = _loc4_.length;
               while(--_loc5_ > -1)
               {
                  if(cast(_loc4_[_loc5_], TweenLite).gc)
                  {
                     _loc4_.splice(_loc5_,(1 : UInt));
                  }
               }
               if(_loc4_.length == 0)
               {
                  _loc2_.remove(_loc3_);
               }
            }
         }
      }
      
      public static function to(param1:ASObject, param2:Float, param3:ASObject) : TweenLite
      {
         return new TweenLite(param1,param2,param3);
      }
      
      function easeProxy(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         var arguments:Array<ASAny> = [param1, param2, param3, param4];
         return ASCompat.toNumber(ASCompatMacro.applyClosure(this.vars.proxiedEase, arguments.concat(this.vars.easeParams)));
      }
      
      override public function renderTime(param1:Float, param2:Bool = false, param3:Bool = false) 
      {
         var _loc4_= false;
         var _loc5_= this.cachedTime;
         if(param1 >= this.cachedDuration)
         {
            this.cachedTotalTime = this.cachedTime = this.cachedDuration;
            this.ratio = 1;
            _loc4_ = true;
            if(this.cachedDuration == 0)
            {
               if((param1 == 0 || _rawPrevTime < 0) && _rawPrevTime != param1)
               {
                  param3 = true;
               }
               _rawPrevTime = param1;
            }
         }
         else if(param1 <= 0)
         {
            this.cachedTotalTime = this.cachedTime = this.ratio = 0;
            if(param1 < 0)
            {
               this.active = false;
               if(this.cachedDuration == 0)
               {
                  if(_rawPrevTime >= 0)
                  {
                     param3 = true;
                     _loc4_ = true;
                  }
                  _rawPrevTime = param1;
               }
            }
            if(this.cachedReversed && _loc5_ != 0)
            {
               _loc4_ = true;
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = param1;
            this.ratio = ASCompat.toNumber(_ease(param1,0,1,this.cachedDuration));
         }
         if(this.cachedTime == _loc5_ && !param3)
         {
            return;
         }
         if(!this.initted)
         {
            init();
            if(!_loc4_ && ASCompat.toBool(this.cachedTime))
            {
               this.ratio = ASCompat.toNumber(_ease(this.cachedTime,0,1,this.cachedDuration));
            }
         }
         if(!this.active && !this.cachedPaused)
         {
            this.active = true;
         }
         if(_loc5_ == 0 && ASCompat.toBool(this.vars.onStart) && (this.cachedTime != 0 || this.cachedDuration == 0) && !param2)
         {
            ASCompatMacro.applyClosure(this.vars.onStart, this.vars.onStartParams);
         }
         var _loc6_= this.cachedPT1;
         while(_loc6_ != null)
         {
            _loc6_.target[_loc6_.property] = _loc6_.start + this.ratio * _loc6_.change;
            _loc6_ = _loc6_.nextNode;
         }
         if(_hasUpdate && !param2)
         {
            ASCompatMacro.applyClosure(this.vars.onUpdate, this.vars.onUpdateParams);
         }
         if(_loc4_ && !this.gc)
         {
            if(_hasPlugins && ASCompat.toBool(this.cachedPT1))
            {
               onPluginEvent("onComplete",this);
            }
            complete(true,param2);
         }
      }
      
      override public function setEnabled(param1:Bool, param2:Bool = false) : Bool
      {
         var _loc3_:Array<ASAny> = null;
         if(param1)
         {
            _loc3_ = ASCompat.dynamicAs(TweenLite.masterList[this.target], Array);
            if(_loc3_ == null)
            {
               TweenLite.masterList[this.target] = [this];
            }
            else
            {
               _loc3_[_loc3_.length] = this;
            }
         }
         super.setEnabled(param1,param2);
         if(_notifyPluginsOfEnabled && ASCompat.toBool(this.cachedPT1))
         {
            return ASCompat.toBool(onPluginEvent(param1 ? "onEnable" : "onDisable",this));
         }
         return false;
      }
      
      function init() 
      {
         var _loc1_:String = null;
         var _loc2_= 0;
         var _loc3_:ASObject = /*undefined*/null;
         var _loc4_= false;
         var _loc5_:Array<ASAny> = null;
         var _loc6_:PropTween = null;
         if(ASCompat.toBool(this.vars.onInit))
         {
            ASCompatMacro.applyClosure(this.vars.onInit, this.vars.onInitParams);
         }
         if(ASCompat.typeof(this.vars.ease) == "function")
         {
            _ease = ASCompat.asFunction(this.vars.ease);
         }
         if(ASCompat.toBool(this.vars.easeParams))
         {
            ASCompat.setProperty(this.vars, "proxiedEase", _ease);
            _ease = easeProxy;
         }
         this.cachedPT1 = null;
         this.propTweenLookup = {};
         final __ax4_iter_151:ASObject = this.vars;
         if (checkNullIteratee(__ax4_iter_151)) for(_tmp_ in __ax4_iter_151.___keys())
         {
            _loc1_  = _tmp_;
            if(!(_reservedProps.hasOwnProperty(_loc1_ ) && !(_loc1_ == "timeScale" && Std.isOfType(this.target , TweenCore))))
            {
               if(plugins.hasOwnProperty(_loc1_ ) && ASCompat.toBool((_loc3_ = ASCompat.createInstance(((plugins[_loc1_] : Dynamic) ), [])).onInitTween(this.target,this.vars[_loc1_],this)))
               {
                  this.cachedPT1 = new PropTween(_loc3_,"changeFactor",0,1,ASCompat.toNumberField(_loc3_.overwriteProps, "length") == 1 ? _loc3_.overwriteProps[0] : "_MULTIPLE_",true,this.cachedPT1);
                  if(this.cachedPT1.name == "_MULTIPLE_")
                  {
                     _loc2_ = ASCompat.toInt(_loc3_.overwriteProps.length);
                     while(--_loc2_ > -1)
                     {
                        this.propTweenLookup[_loc3_.overwriteProps[_loc2_]] = this.cachedPT1;
                     }
                  }
                  else
                  {
                     this.propTweenLookup[this.cachedPT1.name] = this.cachedPT1;
                  }
                  if(ASCompat.toBool(_loc3_.priority))
                  {
                     this.cachedPT1.priority = ASCompat.toInt(_loc3_.priority);
                     _loc4_ = true;
                  }
                  if(ASCompat.toBool(_loc3_.onDisable) || ASCompat.toBool(_loc3_.onEnable))
                  {
                     _notifyPluginsOfEnabled = true;
                  }
                  _hasPlugins = true;
               }
               else
               {
                  this.cachedPT1 = new PropTween(this.target,_loc1_,ASCompat.toNumber(this.target[_loc1_]),ASCompat.toNumber(ASCompat.typeof(this.vars[_loc1_]) == "number" ? ASCompat.toNumber(ASCompat.toNumber(this.vars[_loc1_]) - ASCompat.toNumber(this.target[_loc1_])) : ASCompat.toNumber(this.vars[_loc1_])),_loc1_,false,this.cachedPT1);
                  this.propTweenLookup[_loc1_] = this.cachedPT1;
               }
            }
         }
         if(_loc4_)
         {
            onPluginEvent("onInitAllProps",this);
         }
         if(ASCompat.toBool(this.vars.runBackwards))
         {
            _loc6_ = this.cachedPT1;
            while(_loc6_ != null)
            {
               _loc6_.start += _loc6_.change;
               _loc6_.change = -_loc6_.change;
               _loc6_ = _loc6_.nextNode;
            }
         }
         _hasUpdate = this.vars.onUpdate != null;
         if(ASCompat.toBool(_overwrittenProps))
         {
            killVars(_overwrittenProps);
            if(this.cachedPT1 == null)
            {
               this.setEnabled(false,false);
            }
         }
         if(_overwrite > 1 && this.cachedPT1 != null && ((_loc5_ = ASCompat.dynamicAs(masterList[this.target], Array)) != null) && _loc5_.length > 1)
         {
            if(ASCompat.toBool(overwriteManager.manageOverwrites(this,this.propTweenLookup,_loc5_,_overwrite)))
            {
               init();
            }
         }
         this.initted = true;
      }
      
      public function killVars(param1:ASObject, param2:Bool = true) : Bool
      {
         var _loc3_:String = null;
         var _loc4_:PropTween = null;
         var _loc5_= false;
         if(_overwrittenProps == null)
         {
            _overwrittenProps = {};
         }
         if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
         {
            _loc3_  = _tmp_;
            if(propTweenLookup.hasOwnProperty(_loc3_ ))
            {
               _loc4_ = ASCompat.dynamicAs(propTweenLookup[_loc3_], com.greensock.core.PropTween);
               if(_loc4_.isPlugin && _loc4_.name == "_MULTIPLE_")
               {
                  _loc4_.target.killProps(param1);
                  if(ASCompat.toNumberField(_loc4_.target.overwriteProps, "length") == 0)
                  {
                     _loc4_.name = "";
                  }
                  if(_loc3_ != _loc4_.target.propName || _loc4_.name == "")
                  {
                     ASCompat.deleteProperty(propTweenLookup, _loc3_);
                  }
               }
               if(_loc4_.name != "_MULTIPLE_")
               {
                  if(_loc4_.nextNode != null)
                  {
                     _loc4_.nextNode.prevNode = _loc4_.prevNode;
                  }
                  if(_loc4_.prevNode != null)
                  {
                     _loc4_.prevNode.nextNode = _loc4_.nextNode;
                  }
                  else if(this.cachedPT1 == _loc4_)
                  {
                     this.cachedPT1 = _loc4_.nextNode;
                  }
                  if(_loc4_.isPlugin && ASCompat.toBool(_loc4_.target.onDisable))
                  {
                     _loc4_.target.onDisable();
                     if(ASCompat.toBool(_loc4_.target.activeDisable))
                     {
                        _loc5_ = true;
                     }
                  }
                  ASCompat.deleteProperty(propTweenLookup, _loc3_);
               }
            }
            if(param2 && param1 != _overwrittenProps)
            {
               _overwrittenProps[_loc3_] = 1;
            }
         }
         return _loc5_;
      }
      
      override public function invalidate() 
      {
         if(_notifyPluginsOfEnabled && ASCompat.toBool(this.cachedPT1))
         {
            onPluginEvent("onDisable",this);
         }
         this.cachedPT1 = null;
         _overwrittenProps = null;
         _hasUpdate = this.initted = this.active = _notifyPluginsOfEnabled = false;
         this.propTweenLookup = {};
      }
   }


