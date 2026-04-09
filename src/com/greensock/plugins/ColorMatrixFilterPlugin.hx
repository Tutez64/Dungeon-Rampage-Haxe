package com.greensock.plugins
;
   import com.greensock.*;
   import flash.filters.ColorMatrixFilter;
   
    class ColorMatrixFilterPlugin extends FilterPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _propNames:Array<ASAny> = [];
      
      static var _idMatrix:Array<ASAny> = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      static var _lumR:Float = 0.212671;
      
      static var _lumG:Float = 0.71516;
      
      static var _lumB:Float = 0.072169;
      
      var _matrix:Array<ASAny>;
      
      var _matrixTween:EndArrayPlugin;
      
      public function new()
      {
         super();
         this.propName = "colorMatrixFilter";
         this.overwriteProps = ["colorMatrixFilter"];
      }
      
      public static function setSaturation(param1:Array<ASAny>, param2:Float) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         var _loc3_= 1 - param2;
         var _loc4_= _loc3_ * _lumR;
         var _loc5_= _loc3_ * _lumG;
         var _loc6_= _loc3_ * _lumB;
         var _loc7_:Array<ASAny> = [_loc4_ + param2,_loc5_,_loc6_,0,0,_loc4_,_loc5_ + param2,_loc6_,0,0,_loc4_,_loc5_,_loc6_ + param2,0,0,0,0,0,1,0];
         return applyMatrix(_loc7_,param1);
      }
      
      public static function setHue(param1:Array<ASAny>, param2:Float) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         param2 *= Math.PI / 180;
         var _loc3_= Math.cos(param2);
         var _loc4_= Math.sin(param2);
         var _loc5_:Array<ASAny> = [_lumR + _loc3_ * (1 - _lumR) + _loc4_ * -_lumR,_lumG + _loc3_ * -_lumG + _loc4_ * -_lumG,_lumB + _loc3_ * -_lumB + _loc4_ * (1 - _lumB),0,0,_lumR + _loc3_ * -_lumR + _loc4_ * 0.143,_lumG + _loc3_ * (1 - _lumG) + _loc4_ * 0.14,_lumB + _loc3_ * -_lumB + _loc4_ * -0.283,0,0,_lumR + _loc3_ * -_lumR + _loc4_ * -(1 - _lumR),_lumG + _loc3_ * -_lumG + _loc4_ * _lumG,_lumB + _loc3_ * (1 - _lumB) + _loc4_ * _lumB,0,0,0,0,0,1,0,0,0,0,0,1];
         return applyMatrix(_loc5_,param1);
      }
      
      public static function setContrast(param1:Array<ASAny>, param2:Float) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         param2 += 0.01;
         var _loc3_:Array<ASAny> = [param2,0,0,0,128 * (1 - param2),0,param2,0,0,128 * (1 - param2),0,0,param2,0,128 * (1 - param2),0,0,0,1,0];
         return applyMatrix(_loc3_,param1);
      }
      
      public static function applyMatrix(param1:Array<ASAny>, param2:Array<ASAny>) : Array<ASAny>
      {
         var _loc6_= 0;
         var _loc7_= 0;
         if(!Std.isOfType(param1 , Array) || !Std.isOfType(param2 , Array))
         {
            return param2;
         }
         var _loc3_:Array<ASAny> = [];
         var _loc4_= 0;
         var _loc5_= 0;
         _loc6_ = 0;
         while(_loc6_ < 4)
         {
            _loc7_ = 0;
            while(_loc7_ < 5)
            {
               if(_loc7_ == 4)
               {
                  _loc5_ = ASCompat.toInt(param1[_loc4_ + 4]);
               }
               else
               {
                  _loc5_ = 0;
               }
               _loc3_[_loc4_ + _loc7_] = ASCompat.toNumber(param1[_loc4_]) * ASCompat.toNumber(param2[_loc7_]) + ASCompat.toNumber(param1[_loc4_ + 1]) * ASCompat.toNumber(param2[_loc7_ + 5]) + ASCompat.toNumber(param1[_loc4_ + 2]) * ASCompat.toNumber(param2[_loc7_ + 10]) + ASCompat.toNumber(param1[_loc4_ + 3]) * ASCompat.toNumber(param2[_loc7_ + 15]) + _loc5_;
               _loc7_ += 1;
            }
            _loc4_ += 5;
            _loc6_ += 1;
         }
         return _loc3_;
      }
      
      public static function setThreshold(param1:Array<ASAny>, param2:Float) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         var _loc3_:Array<ASAny> = [_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * param2,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * param2,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * param2,0,0,0,1,0];
         return applyMatrix(_loc3_,param1);
      }
      
      public static function colorize(param1:Array<ASAny>, param2:Float, param3:Float = 1) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         if(Math.isNaN(param3))
         {
            param3 = 1;
         }
         var _loc4_= (Std.int(param2) >> 16 & 0xFF) / 255;
         var _loc5_= (Std.int(param2) >> 8 & 0xFF) / 255;
         var _loc6_= (Std.int(param2) & 0xFF) / 255;
         var _loc7_= 1 - param3;
         var _loc8_:Array<ASAny> = [_loc7_ + param3 * _loc4_ * _lumR,param3 * _loc4_ * _lumG,param3 * _loc4_ * _lumB,0,0,param3 * _loc5_ * _lumR,_loc7_ + param3 * _loc5_ * _lumG,param3 * _loc5_ * _lumB,0,0,param3 * _loc6_ * _lumR,param3 * _loc6_ * _lumG,_loc7_ + param3 * _loc6_ * _lumB,0,0,0,0,0,1,0];
         return applyMatrix(_loc8_,param1);
      }
      
      public static function setBrightness(param1:Array<ASAny>, param2:Float) : Array<ASAny>
      {
         if(Math.isNaN(param2))
         {
            return param1;
         }
         param2 = param2 * 100 - 100;
         return applyMatrix([1,0,0,0,param2,0,1,0,0,param2,0,0,1,0,param2,0,0,0,1,0,0,0,0,0,1],param1);
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _type = ColorMatrixFilter;
         var _loc4_:ASObject = param2;
         initFilter({
            "remove":param2.remove,
            "index":param2.index,
            "addFilter":param2.addFilter
         },new ColorMatrixFilter(cast(_idMatrix.slice(0))),_propNames);
         _matrix = cast(_filter, ColorMatrixFilter).matrix;
         var _loc5_:Array<ASAny> = [];
         if(_loc4_.matrix != null && Std.isOfType(_loc4_.matrix , Array))
         {
            _loc5_ = ASCompat.dynamicAs(_loc4_.matrix, Array);
         }
         else
         {
            if(_loc4_.relative == true)
            {
               _loc5_ = _matrix.slice(0);
            }
            else
            {
               _loc5_ = _idMatrix.slice(0);
            }
            _loc5_ = setBrightness(_loc5_,ASCompat.toNumberField(_loc4_, "brightness"));
            _loc5_ = setContrast(_loc5_,ASCompat.toNumberField(_loc4_, "contrast"));
            _loc5_ = setHue(_loc5_,ASCompat.toNumberField(_loc4_, "hue"));
            _loc5_ = setSaturation(_loc5_,ASCompat.toNumberField(_loc4_, "saturation"));
            _loc5_ = setThreshold(_loc5_,ASCompat.toNumberField(_loc4_, "threshold"));
            if(!Math.isNaN(ASCompat.toNumberField(_loc4_, "colorize")))
            {
               _loc5_ = colorize(_loc5_,ASCompat.toNumberField(_loc4_, "colorize"),ASCompat.toNumberField(_loc4_, "amount"));
            }
         }
         _matrixTween = new EndArrayPlugin();
         _matrixTween.init(_matrix,_loc5_);
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         _matrixTween.changeFactor = param1;
         cast(_filter, ColorMatrixFilter).matrix = cast(_matrix);
         return super.changeFactor = param1;
      }
   }


