package com.greensock.plugins
;
   import com.greensock.*;
   import com.greensock.core.*;
   
    class TweenPlugin
   {
      
      public static inline final VERSION:Float = 1.4;
      
      public static inline final API:Float = 1;
      
      public var activeDisable:Bool = false;
      
      public var onInitAllProps:ASFunction;
      
      var _tweens:Array<ASAny> = [];
      
      public var onDisable:ASFunction;
      
      public var propName:String;
      
      public var onEnable:ASFunction;
      
      public var round:Bool = false;
      
      public var priority:Int = 0;
      
      public var overwriteProps:Array<ASAny>;
      
      public var onComplete:ASFunction;
      
      var _changeFactor:Float = 0;
      
      public function new()
      {
         
      }
      
      public static function activate(param1:Array<ASAny>) : Bool
      {
         var _loc3_:ASObject = null;
         TweenLite.onPluginEvent = TweenPlugin.onTweenEvent;
         var _loc2_= param1.length;
         while(_loc2_-- != 0)
         {
            if(param1[_loc2_].hasOwnProperty("API"))
            {
               _loc3_ = ASCompat.createInstance(((param1[_loc2_] : Dynamic) ), []);
               TweenLite.plugins[_loc3_.propName] = param1[_loc2_];
            }
         }
         return true;
      }
      
      static function onTweenEvent(param1:String, param2:TweenLite) : Bool
      {
         var _loc7_:Int;
         var _loc4_= false;
         var _loc5_:Array<ASAny> = null;
         var _loc6_= 0;
         var _loc3_= param2.cachedPT1;
         if(param1 == "onInitAllProps")
         {
            _loc5_ = [];
            _loc6_ = 0;
            while(_loc3_ != null)
            {
               _loc5_[ASCompat.toInt(_loc7_ = _loc6_++)] = _loc3_;
               _loc3_ = _loc3_.nextNode;
            }
            ASCompat.ASArray.sortOn(_loc5_, "priority",(ASCompat.ASArray.NUMERIC : Int) | (ASCompat.ASArray.DESCENDING : Int));
            while(--_loc6_ > -1)
            {
               cast(_loc5_[_loc6_], PropTween).nextNode = ASCompat.dynamicAs(_loc5_[_loc6_ + 1], com.greensock.core.PropTween);
               cast(_loc5_[_loc6_], PropTween).prevNode = ASCompat.dynamicAs(_loc5_[_loc6_ - 1], com.greensock.core.PropTween);
            }
            _loc3_ = param2.cachedPT1 = ASCompat.dynamicAs(_loc5_[0], com.greensock.core.PropTween);
         }
         while(_loc3_ != null)
         {
            if(_loc3_.isPlugin && ASCompat.toBool(_loc3_.target[param1]))
            {
               if(ASCompat.toBool(_loc3_.target.activeDisable))
               {
                  _loc4_ = true;
               }
               _loc3_.target[param1]();
            }
            _loc3_ = _loc3_.nextNode;
         }
         return _loc4_;
      }
      
            
      @:isVar public var changeFactor(get,set):Float;
public function  set_changeFactor(param1:Float) :Float      {
         updateTweens(param1);
         return _changeFactor = param1;
      }
      
      function updateTweens(param1:Float) 
      {
         var _loc3_:PropTween = null;
         var _loc4_= Math.NaN;
         var _loc2_= _tweens.length;
         if(this.round)
         {
            while(--_loc2_ > -1)
            {
               _loc3_ = ASCompat.dynamicAs(_tweens[_loc2_], com.greensock.core.PropTween);
               _loc4_ = _loc3_.start + _loc3_.change * param1;
               if(_loc4_ > 0)
               {
                  _loc3_.target[_loc3_.property] = Std.int(_loc4_ + 0.5) >> 0;
               }
               else
               {
                  _loc3_.target[_loc3_.property] = Std.int(_loc4_ - 0.5) >> 0;
               }
            }
         }
         else
         {
            while(--_loc2_ > -1)
            {
               _loc3_ = ASCompat.dynamicAs(_tweens[_loc2_], com.greensock.core.PropTween);
               _loc3_.target[_loc3_.property] = _loc3_.start + _loc3_.change * param1;
            }
         }
      }
      
      function addTween(param1:ASObject, param2:String, param3:Float, param4:ASAny, param5:String = null) 
      {
         var _loc6_= Math.NaN;
         if(param4 != null)
         {
            _loc6_ = ASCompat.typeof(param4) == "number" ? ASCompat.toNumber(param4) - param3 : ASCompat.toNumber(param4);
            if(_loc6_ != 0)
            {
               _tweens[_tweens.length] = new PropTween(param1,param2,param3,_loc6_,if (ASCompat.stringAsBool(param5)) param5 else param2,false);
            }
         }
      }
      
      public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         addTween(param1,this.propName,ASCompat.toNumber(param1[this.propName]),param2,this.propName);
         return true;
      }
function  get_changeFactor() : Float
      {
         return _changeFactor;
      }
      
      public function killProps(param1:ASObject) 
      {
         var _loc2_= this.overwriteProps.length;
         while(--_loc2_ > -1)
         {
            if(param1.hasOwnProperty(this.overwriteProps[_loc2_] ))
            {
               this.overwriteProps.splice(_loc2_,(1 : UInt));
            }
         }
         _loc2_ = _tweens.length;
         while(--_loc2_ > -1)
         {
            if(param1.hasOwnProperty(cast(_tweens[_loc2_], PropTween).name ))
            {
               _tweens.splice(_loc2_,(1 : UInt));
            }
         }
      }
   }


