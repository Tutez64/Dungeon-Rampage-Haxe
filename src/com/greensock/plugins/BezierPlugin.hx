package com.greensock.plugins
;
   import com.greensock.*;
   
    class BezierPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      static final _RAD2DEG:Float = 180 / Math.PI;
      
      var _future:ASObject = {};
      
      var _orient:Bool = false;
      
      var _orientData:Array<ASAny>;
      
      var _target:ASObject;
      
      var _beziers:ASObject;
      
      public function new()
      {
         super();
         this.propName = "bezier";
         this.overwriteProps = [];
      }
      
      public static function parseBeziers(param1:ASObject, param2:Bool = false) : ASObject
      {
         var _loc3_= 0;
         var _loc4_:Array<ASAny> = null;
         var _loc5_:ASObject = null;
         var _loc6_:String = null;
         var _loc7_:ASObject = {};
         if(param2)
         {
            if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
            {
               _loc6_  = _tmp_;
               _loc4_ = ASCompat.dynamicAs(param1[_loc6_], Array);
               _loc7_[_loc6_] = _loc5_ = [];
               if(_loc4_.length > 2)
               {
                  _loc5_[_loc5_.length] = [_loc4_[0],ASCompat.toNumber(_loc4_[1]) - ASCompat.toNumber(ASCompat.toNumber(_loc4_[2]) - ASCompat.toNumber(_loc4_[0])) / 4,_loc4_[1]];
                  _loc3_ = 1;
                  while(_loc3_ < _loc4_.length - 1)
                  {
                     _loc5_[_loc5_.length] = [_loc4_[_loc3_],_loc4_[_loc3_] + (ASCompat.toNumber(_loc4_[_loc3_]) - ASCompat.toNumber(ASCompat.dynGetIndex(_loc5_[Std.string(_loc3_ - 1)], 1))),_loc4_[_loc3_ + 1]];
                     _loc3_ += 1;
                  }
               }
               else
               {
                  _loc5_[_loc5_.length] = ([_loc4_[0],ASCompat.toNumber(_loc4_[0] + _loc4_[1]) / 2,_loc4_[1]] : Array<ASAny>);
               }
            }
         }
         else
         {
            if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
            {
               _loc6_  = _tmp_;
               _loc4_ = ASCompat.dynamicAs(param1[_loc6_], Array);
               _loc7_[_loc6_] = _loc5_ = [];
               if(_loc4_.length > 3)
               {
                  _loc5_[_loc5_.length] = ([_loc4_[0],_loc4_[1],ASCompat.toNumber(_loc4_[1] + _loc4_[2]) / 2] : Array<ASAny>);
                  _loc3_ = 2;
                  while(_loc3_ < _loc4_.length - 2)
                  {
                     _loc5_[_loc5_.length] = ([ASCompat.dynGetIndex(_loc5_[Std.string(_loc3_ - 2)], 2),_loc4_[_loc3_],ASCompat.toNumber(_loc4_[_loc3_] + _loc4_[_loc3_ + 1]) / 2] : Array<ASAny>);
                     _loc3_ += 1;
                  }
                  _loc5_[_loc5_.length] = [ASCompat.dynGetIndex(_loc5_[ASCompat.toNumberField(_loc5_, "length") - 1], 2),_loc4_[_loc4_.length - 2],_loc4_[_loc4_.length - 1]];
               }
               else if(_loc4_.length == 3)
               {
                  _loc5_[_loc5_.length] = [_loc4_[0],_loc4_[1],_loc4_[2]];
               }
               else if(_loc4_.length == 2)
               {
                  _loc5_[_loc5_.length] = ([_loc4_[0],ASCompat.toNumber(_loc4_[0] + _loc4_[1]) / 2,_loc4_[1]] : Array<ASAny>);
               }
            }
         }
         return _loc7_;
      }
      
      override public function killProps(param1:ASObject) 
      {
         var _loc2_:String = null;
         final __ax4_iter_26:ASObject = _beziers;
         if (checkNullIteratee(__ax4_iter_26)) for(_tmp_ in __ax4_iter_26.___keys())
         {
            _loc2_  = _tmp_;
            if(param1.hasOwnProperty(_loc2_ ))
            {
               ASCompat.deleteProperty(_beziers, _loc2_);
            }
         }
         super.killProps(param1);
      }
      
      function init(param1:TweenLite, param2:Array<ASAny>, param3:Bool) 
      {
         var __ax4_iter_27:ASAny;
         var _loc6_= 0;
         var _loc7_:String = null;
         var _loc8_:ASObject = null;
         _target = param1.target;
         var _loc4_:ASObject = param1.vars.isTV == true ? param1.vars.exposedVars : param1.vars;
         if(_loc4_.orientToBezier == true)
         {
            _orientData = [(["x","y","rotation",0,0.01] : Array<ASAny>)];
            _orient = true;
         }
         else if(Std.isOfType(_loc4_.orientToBezier , Array))
         {
            _orientData = ASCompat.dynamicAs(_loc4_.orientToBezier, Array);
            _orient = true;
         }
         var _loc5_:ASObject = {};
         _loc6_ = 0;
         while(_loc6_ < param2.length)
         {
            __ax4_iter_27 = param2[_loc6_];
            if (checkNullIteratee(__ax4_iter_27)) for(_tmp_ in __ax4_iter_27.___keys())
            {
               _loc7_  = _tmp_;
               if(!ASCompat.hasProperty(_loc5_, _loc7_))
               {
                  _loc5_[_loc7_] = [param1.target[_loc7_]];
               }
               if(ASCompat.typeof(param2[_loc6_][_loc7_]) == "number")
               {
                  ASCompat.dynPush(_loc5_[_loc7_], param2[_loc6_][_loc7_]);
               }
               else
               {
                  ASCompat.dynPush(_loc5_[_loc7_], param1.target[_loc7_] + ASCompat.toNumber(param2[_loc6_][_loc7_]));
               }
            }
            _loc6_ += 1;
         }
         if (checkNullIteratee(_loc5_)) for(_tmp_ in _loc5_.___keys())
         {
            _loc7_  = _tmp_;
            this.overwriteProps[this.overwriteProps.length] = _loc7_;
            if(ASCompat.hasProperty(_loc4_, _loc7_))
            {
               if(ASCompat.typeof(_loc4_[_loc7_]) == "number")
               {
                  ASCompat.dynPush(_loc5_[_loc7_], _loc4_[_loc7_]);
               }
               else
               {
                  ASCompat.dynPush(_loc5_[_loc7_], param1.target[_loc7_] + ASCompat.toNumber(_loc4_[_loc7_]));
               }
               _loc8_ = {};
               _loc8_[_loc7_] = true;
               param1.killVars(_loc8_,false);
               ASCompat.deleteProperty(_loc4_, _loc7_);
            }
         }
         _beziers = parseBeziers(_loc5_,param3);
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(!Std.isOfType(param2 , Array))
         {
            return false;
         }
         init(param3,ASCompat.dynamicAs(param2 , Array),false);
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         var __ax4_iter_28:ASObject;
         var __ax4_iter_29:ASObject;
         var _loc2_:Float = 0;
         var _loc3_:String = null;
         var _loc4_:ASObject = null;
         var _loc5_= Math.NaN;
         var _loc6_= 0;
         var _loc7_= Math.NaN;
         var _loc8_:ASObject = null;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_:Array<ASAny> = null;
         var _loc12_= Math.NaN;
         var _loc13_:ASObject = null;
         var _loc14_= false;
         _changeFactor = param1;
         if(param1 == 1)
         {
            __ax4_iter_28 = _beziers;
            if (checkNullIteratee(__ax4_iter_28)) for(_tmp_ in __ax4_iter_28.___keys())
            {
               _loc3_  = _tmp_;
               _loc2_ = ASCompat.toNumberField(_beziers[_loc3_], "length") - 1;
               _target[_loc3_] = ASCompat.dynGetIndex(ASCompat.dynGetIndex(_beziers[_loc3_], _loc2_), 2);
            }
         }
         else
         {
            __ax4_iter_29 = _beziers;
            if (checkNullIteratee(__ax4_iter_29)) for(_tmp_ in __ax4_iter_29.___keys())
            {
               _loc3_  = _tmp_;
               _loc6_ = ASCompat.toInt(_beziers[_loc3_].length);
               if(param1 < 0)
               {
                  _loc2_ = 0;
               }
               else if(param1 >= 1)
               {
                  _loc2_ = _loc6_ - 1;
               }
               else
               {
                  _loc2_ = Std.int(_loc6_ * param1) >> 0;
               }
               _loc5_ = ASCompat.toNumber(ASCompat.toNumber(param1 - ASCompat.toNumber(_loc2_ * (1 / _loc6_))) * _loc6_);
               _loc4_ = ASCompat.dynGetIndex(_beziers[_loc3_], _loc2_);
               if(this.round)
               {
                  _loc7_ = ASCompat.toNumber(_loc4_[Std.string(0)] + _loc5_ * ASCompat.toNumber(2 * (1 - _loc5_) * ASCompat.toNumber(ASCompat.toNumber(_loc4_[Std.string(1)]) - ASCompat.toNumber(_loc4_[Std.string(0)])) + _loc5_ * ASCompat.toNumber(ASCompat.toNumber(_loc4_[Std.string(2)]) - ASCompat.toNumber(_loc4_[Std.string(0)]))));
                  if(_loc7_ > 0)
                  {
                     _target[_loc3_] = Std.int(_loc7_ + 0.5) >> 0;
                  }
                  else
                  {
                     _target[_loc3_] = Std.int(_loc7_ - 0.5) >> 0;
                  }
               }
               else
               {
                  _target[_loc3_] = _loc4_[Std.string(0)] + _loc5_ * ASCompat.toNumber(2 * (1 - _loc5_) * ASCompat.toNumber(ASCompat.toNumber(_loc4_[Std.string(1)]) - ASCompat.toNumber(_loc4_[Std.string(0)])) + _loc5_ * ASCompat.toNumber(ASCompat.toNumber(_loc4_[Std.string(2)]) - ASCompat.toNumber(_loc4_[Std.string(0)])));
               }
            }
         }
         if(_orient)
         {
            _loc2_ = _orientData.length;
            _loc8_ = {};
            while(ASCompat.toBool(_loc2_--))
            {
               _loc11_ = ASCompat.dynamicAs(_orientData[Std.int(_loc2_)], Array);
               _loc8_[_loc11_[0]] = _target[_loc11_[0]];
               _loc8_[_loc11_[1]] = _target[_loc11_[1]];
            }
            _loc13_ = _target;
            _loc14_ = this.round;
            _target = _future;
            this.round = false;
            _orient = false;
            _loc2_ = _orientData.length;
            while(ASCompat.toBool(_loc2_--))
            {
               _loc11_ = ASCompat.dynamicAs(_orientData[Std.int(_loc2_)], Array);
               this.changeFactor = ASCompat.toNumber(param1 + (if (ASCompat.toBool(_loc11_[4])) _loc11_[4] else 0.01));
               _loc12_ = ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(_loc11_[3]) , 0));
               _loc9_ = ASCompat.toNumber(ASCompat.toNumber(_future[_loc11_[0]]) - ASCompat.toNumber(_loc8_[_loc11_[0]]));
               _loc10_ = ASCompat.toNumber(ASCompat.toNumber(_future[_loc11_[1]]) - ASCompat.toNumber(_loc8_[_loc11_[1]]));
               _loc13_[_loc11_[2]] = Math.atan2(_loc10_,_loc9_) * _RAD2DEG + _loc12_;
            }
            _target = _loc13_;
            this.round = _loc14_;
            _orient = true;
         }
return param1;
      }
   }


