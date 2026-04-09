package com.greensock.plugins
;
   import com.greensock.*;
   import com.greensock.core.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.geom.Transform;
   
    class TintPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _props:Array<ASAny> = ["redMultiplier","greenMultiplier","blueMultiplier","alphaMultiplier","redOffset","greenOffset","blueOffset","alphaOffset"];
      
      var _ct:ColorTransform;
      
      var _transform:Transform;
      
      var _ignoreAlpha:Bool = false;
      
      public function new()
      {
         super();
         this.propName = "tint";
         this.overwriteProps = ["tint"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(!Std.isOfType(param1 , DisplayObject))
         {
            return false;
         }
         var _loc4_= new ColorTransform();
         if(param2 != null && param3.vars.removeTint != true)
         {
            _loc4_.color = (ASCompat.toInt(param2) : UInt);
         }
         _ignoreAlpha = true;
         _transform = cast(param1, DisplayObject).transform;
         init(_transform.colorTransform,_loc4_);
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         var _loc2_:ColorTransform = null;
         updateTweens(param1);
         if(_transform != null)
         {
            if(_ignoreAlpha)
            {
               _loc2_ = _transform.colorTransform;
               _ct.alphaMultiplier = _loc2_.alphaMultiplier;
               _ct.alphaOffset = _loc2_.alphaOffset;
            }
            _transform.colorTransform = _ct;
         }
return param1;
      }
      
      public function init(param1:ColorTransform, param2:ColorTransform) 
      {
         var _loc6_:Int;
         var _loc4_:String = null;
         _ct = param1;
         var _loc3_= _props.length;
         var _loc5_= _tweens.length;
         while(_loc3_-- != 0)
         {
            _loc4_ = _props[_loc3_];
            if((_ct : ASAny)[_loc4_] != (param2 : ASAny)[_loc4_])
            {
               _tweens[ASCompat.toInt(_loc6_ = _loc5_++)] = new PropTween(_ct,_loc4_,ASCompat.toNumber((_ct : ASAny)[_loc4_]),ASCompat.toNumber(ASCompat.toNumber((param2 : ASAny)[_loc4_]) - ASCompat.toNumber((_ct : ASAny)[_loc4_])),"tint",false);
            }
         }
      }
   }


