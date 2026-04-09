package brain.utils
;
   import flash.filters.ColorMatrixFilter;
   
    class ColorMatrix
   {
      
      static inline final LUMA_R:Float = 0.212671;
      
      static inline final LUMA_G:Float = 0.71516;
      
      static inline final LUMA_B:Float = 0.072169;
      
      static inline final LUMA_R2:Float = 0.3086;
      
      static inline final LUMA_G2:Float = 0.6094;
      
      static inline final LUMA_B2:Float = 0.082;
      
      static inline final ONETHIRD:Float = 0.3333333333333333;
      
      static inline final RAD:Float = 0.017453292519943295;
      
      public static final COLOR_DEFICIENCY_TYPES:Array<ASAny> = ["Protanopia","Protanomaly","Deuteranopia","Deuteranomaly","Tritanopia","Tritanomaly","Achromatopsia","Achromatomaly"];
      
      static final IDENTITY:Array<ASAny> = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      public var matrix:Array<ASAny>;
      
      var preHue:ColorMatrix;
      
      var postHue:ColorMatrix;
      
      var hueInitialized:Bool = false;
      
      public function new(param1:ASObject = null)
      {
         
         if(Std.isOfType(param1 , ColorMatrix))
         {
            matrix = ASCompat.dynamicAs(ASCompat.dynConcat(param1.matrix), Array);
         }
         else if(Std.isOfType(param1 , Array))
         {
            matrix = ASCompat.dynamicAs(ASCompat.dynConcat(param1), Array);
         }
         else
         {
            reset();
         }
      }
      
      public function reset() 
      {
         matrix = IDENTITY.copy();
      }
      
      public function clone() : ColorMatrix
      {
         return new ColorMatrix(matrix);
      }
      
      public function invert() 
      {
         concat([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0]);
      }
      
      public function adjustSaturation(param1:Float) 
      {
         var _loc3_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         _loc3_ = 1 - param1;
         _loc2_ = _loc3_ * 0.212671;
         _loc4_ = _loc3_ * 0.71516;
         _loc5_ = _loc3_ * 0.072169;
         concat([_loc2_ + param1,_loc4_,_loc5_,0,0,_loc2_,_loc4_ + param1,_loc5_,0,0,_loc2_,_loc4_,_loc5_ + param1,0,0,0,0,0,1,0]);
      }
      
      public function adjustContrast(param1:Float, param2:Float = null, param3:Float = null) 
{
         if (param2 == null) param2 = Math.NaN;
         if (param3 == null) param3 = Math.NaN;
         if(Math.isNaN(param2))
         {
            param2 = param1;
         }
         if(Math.isNaN(param3))
         {
            param3 = param1;
         }
         param1 += 1;
         param2 += 1;
         param3 += 1;
         concat([param1,0,0,0,128 * (1 - param1),0,param2,0,0,128 * (1 - param2),0,0,param3,0,128 * (1 - param3),0,0,0,1,0]);
      }
      
      public function adjustBrightness(param1:Float, param2:Float = null, param3:Float = null) 
{
         if (param2 == null) param2 = Math.NaN;
         if (param3 == null) param3 = Math.NaN;
         if(Math.isNaN(param2))
         {
            param2 = param1;
         }
         if(Math.isNaN(param3))
         {
            param3 = param1;
         }
         concat([1,0,0,0,param1,0,1,0,0,param2,0,0,1,0,param3,0,0,0,1,0]);
      }
      
      public function adjustHue(param1:Float) 
      {
         param1 *= 0.017453292519943295;
         var _loc2_= Math.cos(param1);
         var _loc3_= Math.sin(param1);
         concat([0.212671 + _loc2_ * (1 - 0.212671) + _loc3_ * -0.212671,0.71516 + _loc2_ * -0.71516 + _loc3_ * -0.71516,0.072169 + _loc2_ * -0.072169 + _loc3_ * (1 - 0.072169),0,0,0.212671 + _loc2_ * -0.212671 + _loc3_ * 0.143,0.71516 + _loc2_ * (1 - 0.71516) + _loc3_ * 0.14,0.072169 + _loc2_ * -0.072169 + _loc3_ * -0.283,0,0,0.212671 + _loc2_ * -0.212671 + _loc3_ * -0.787329,0.71516 + _loc2_ * -0.71516 + _loc3_ * 0.71516,0.072169 + _loc2_ * (1 - 0.072169) + _loc3_ * 0.072169,0,0,0,0,0,1,0]);
      }
      
      public function rotateHue(param1:Float) 
      {
         initHue();
         concat(preHue.matrix);
         rotateBlue(param1);
         concat(postHue.matrix);
      }
      
      public function luminance2Alpha() 
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,0.212671,0.71516,0.072169,0,0]);
      }
      
      public function adjustAlphaContrast(param1:Float) 
      {
         param1 += 1;
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param1,128 * (1 - param1)]);
      }
      
      public function colorize(param1:Int, param2:Float = 1) 
      {
         var _loc3_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc6_= Math.NaN;
         _loc3_ = (param1 >> 16 & 0xFF) / 255;
         _loc5_ = (param1 >> 8 & 0xFF) / 255;
         _loc4_ = (param1 & 0xFF) / 255;
         _loc6_ = 1 - param2;
         concat([_loc6_ + param2 * _loc3_ * 0.212671,param2 * _loc3_ * 0.71516,param2 * _loc3_ * 0.072169,0,0,param2 * _loc5_ * 0.212671,_loc6_ + param2 * _loc5_ * 0.71516,param2 * _loc5_ * 0.072169,0,0,param2 * _loc4_ * 0.212671,param2 * _loc4_ * 0.71516,_loc6_ + param2 * _loc4_ * 0.072169,0,0,0,0,0,1,0]);
      }
      
     /* public function setChannels(param1:int = 1, param2:int = 2, param3:int = 4, param4:int = 8) : void
      {
         var _loc5_:Number = (((param1 & 1) == 1 ? 1 : (0 + ((param1 & 2) == 2) ? 1 : 0)) + ((param1 & 4) == 4) ? 1 : 0) + ((param1 & 8) == 8) ? 1 : 0;
         if(_loc5_ > 0)
         {
            _loc5_ = 1 / _loc5_;
         }
         var _loc8_:Number = (((param2 & 1) == 1 ? 1 : (0 + ((param2 & 2) == 2) ? 1 : 0)) + ((param2 & 4) == 4) ? 1 : 0) + ((param2 & 8) == 8) ? 1 : 0;
         if(_loc8_ > 0)
         {
            _loc8_ = 1 / _loc8_;
         }
         var _loc6_:Number = (((param3 & 1) == 1 ? 1 : (0 + ((param3 & 2) == 2) ? 1 : 0)) + ((param3 & 4) == 4) ? 1 : 0) + ((param3 & 8) == 8) ? 1 : 0;
         if(_loc6_ > 0)
         {
            _loc6_ = 1 / _loc6_;
         }
         var _loc7_:Number = (((param4 & 1) == 1 ? 1 : (0 + ((param4 & 2) == 2) ? 1 : 0)) + ((param4 & 4) == 4) ? 1 : 0) + ((param4 & 8) == 8) ? 1 : 0;
         if(_loc7_ > 0)
         {
            _loc7_ = 1 / _loc7_;
         }
         concat([(param1 & 1) == 1 ? _loc5_ : 0,(param1 & 2) == 2 ? _loc5_ : 0,(param1 & 4) == 4 ? _loc5_ : 0,(param1 & 8) == 8 ? _loc5_ : 0,0,(param2 & 1) == 1 ? _loc8_ : 0,(param2 & 2) == 2 ? _loc8_ : 0,(param2 & 4) == 4 ? _loc8_ : 0,(param2 & 8) == 8 ? _loc8_ : 0,0,(param3 & 1) == 1 ? _loc6_ : 0,(param3 & 2) == 2 ? _loc6_ : 0,(param3 & 4) == 4 ? _loc6_ : 0,(param3 & 8) == 8 ? _loc6_ : 0,0,(param4 & 1) == 1 ? _loc7_ : 0,(param4 & 2) == 2 ? _loc7_ : 0,(param4 & 4) == 4 ? _loc7_ : 0,(param4 & 8) == 8 ? _loc7_ : 0,0]);
      }*/
      
      public function blend(param1:ColorMatrix, param2:Float) 
      {
         var _loc4_= 1 - param2;
         var _loc3_= 0;
         while(_loc3_ < 20)
         {
            matrix[_loc3_] = _loc4_ * ASCompat.toNumber(matrix[_loc3_]) + param2 * ASCompat.toNumber(param1.matrix[_loc3_]);
            _loc3_++;
         }
      }
      
      public function average(param1:Float = 0.3333333333333333, param2:Float = 0.3333333333333333, param3:Float = 0.3333333333333333) 
      {
         concat([param1,param2,param3,0,0,param1,param2,param3,0,0,param1,param2,param3,0,0,0,0,0,1,0]);
      }
      
      public function threshold(param1:Float, param2:Float = 256) 
      {
         concat([0.212671 * param2,0.71516 * param2,0.072169 * param2,0,-param2 * param1,0.212671 * param2,0.71516 * param2,0.072169 * param2,0,-param2 * param1,0.212671 * param2,0.71516 * param2,0.072169 * param2,0,-param2 * param1,0,0,0,1,0]);
      }
      
      public function desaturate() 
      {
         concat([0.212671,0.71516,0.072169,0,0,0.212671,0.71516,0.072169,0,0,0.212671,0.71516,0.072169,0,0,0,0,0,1,0]);
      }
      
      public function randomize(param1:Float = 1) 
      {
         var _loc13_= 1 - param1;
         var _loc14_= _loc13_ + param1 * (Math.random() - Math.random());
         var _loc7_= param1 * (Math.random() - Math.random());
         var _loc10_= param1 * (Math.random() - Math.random());
         var _loc4_= param1 * 255 * (Math.random() - Math.random());
         var _loc2_= param1 * (Math.random() - Math.random());
         var _loc8_= _loc13_ + param1 * (Math.random() - Math.random());
         var _loc11_= param1 * (Math.random() - Math.random());
         var _loc5_= param1 * 255 * (Math.random() - Math.random());
         var _loc3_= param1 * (Math.random() - Math.random());
         var _loc9_= param1 * (Math.random() - Math.random());
         var _loc12_= _loc13_ + param1 * (Math.random() - Math.random());
         var _loc6_= param1 * 255 * (Math.random() - Math.random());
         concat([_loc14_,_loc7_,_loc10_,0,_loc4_,_loc2_,_loc8_,_loc11_,0,_loc5_,_loc3_,_loc9_,_loc12_,0,_loc6_,0,0,0,1,0]);
      }
      
      public function setMultiplicators(param1:Float = 1, param2:Float = 1, param3:Float = 1, param4:Float = 1) 
      {
         var _loc5_:Array<ASAny> = [param1,0,0,0,0,0,param2,0,0,0,0,0,param3,0,0,0,0,0,param4,0];
         concat(_loc5_);
      }
      
      public function clearChannels(param1:Bool = false, param2:Bool = false, param3:Bool = false, param4:Bool = false) 
      {
         if(param1)
         {
            matrix[0] = matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0;
         }
         if(param2)
         {
            matrix[5] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0;
         }
         if(param3)
         {
            matrix[10] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0;
         }
         if(param4)
         {
            matrix[15] = matrix[16] = matrix[17] = matrix[18] = matrix[19] = 0;
         }
      }
      
      public function thresholdAlpha(param1:Float, param2:Float = 256) 
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param2,-param2 * param1]);
      }
      
      public function averageRGB2Alpha() 
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,0.3333333333333333,0.3333333333333333,0.3333333333333333,0,0]);
      }
      
      public function invertAlpha() 
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,-1,255]);
      }
      
      public function rgb2Alpha(param1:Float, param2:Float, param3:Float) 
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,param1,param2,param3,0,0]);
      }
      
      public function setAlpha(param1:Float) 
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,param1,0]);
      }
      
      @:isVar public var filter(get,never):ColorMatrixFilter;
public function  get_filter() : ColorMatrixFilter
      {
         return new ColorMatrixFilter(cast(matrix));
      }
      
      public function concat(param1:Array<ASAny>) 
      {
         var _loc5_= 0;
         var _loc3_= 0;
         var _loc2_:Array<ASAny> = [];
         var _loc4_= 0;
         _loc5_ = 0;
         while(_loc5_ < 4)
         {
            _loc3_ = 0;
            while(_loc3_ < 5)
            {
               _loc2_[_loc4_ + _loc3_] = ASCompat.toNumber(param1[_loc4_]) * ASCompat.toNumber(matrix[_loc3_]) + ASCompat.toNumber(param1[_loc4_ + 1]) * ASCompat.toNumber(matrix[_loc3_ + 5]) + ASCompat.toNumber(param1[_loc4_ + 2]) * ASCompat.toNumber(matrix[_loc3_ + 10]) + ASCompat.toNumber(param1[_loc4_ + 3]) * ASCompat.toNumber(matrix[_loc3_ + 15]) + (_loc3_ == 4 ? ASCompat.toNumber(param1[_loc4_ + 4]) : 0);
               _loc3_++;
            }
            _loc4_ += 5;
            _loc5_++;
         }
         matrix = _loc2_;
      }
      
      public function rotateRed(param1:Float) 
      {
         rotateColor(param1,2,1);
      }
      
      public function rotateGreen(param1:Float) 
      {
         rotateColor(param1,0,2);
      }
      
      public function rotateBlue(param1:Float) 
      {
         rotateColor(param1,1,0);
      }
      
      function rotateColor(param1:Float, param2:Int, param3:Int) 
      {
         param1 *= 0.017453292519943295;
         var _loc4_= IDENTITY.copy();
         _loc4_[param2 + param2 * 5] = _loc4_[param3 + param3 * 5] = Math.cos(param1);
         _loc4_[param3 + param2 * 5] = Math.sin(param1);
         _loc4_[param2 + param3 * 5] = -Math.sin(param1);
         concat(_loc4_);
      }
      
      public function shearRed(param1:Float, param2:Float) 
      {
         shearColor(0,1,param1,2,param2);
      }
      
      public function shearGreen(param1:Float, param2:Float) 
      {
         shearColor(1,0,param1,2,param2);
      }
      
      public function shearBlue(param1:Float, param2:Float) 
      {
         shearColor(2,0,param1,1,param2);
      }
      
      function shearColor(param1:Int, param2:Int, param3:Float, param4:Int, param5:Float) 
      {
         var _loc6_= IDENTITY.copy();
         _loc6_[param2 + param1 * 5] = param3;
         _loc6_[param4 + param1 * 5] = param5;
         concat(_loc6_);
      }
      
      public function applyColorDeficiency(param1:String) 
      {
         switch(param1)
         {
            case "Protanopia":
               concat([0.567,0.433,0,0,0,0.558,0.442,0,0,0,0,0.242,0.758,0,0,0,0,0,1,0]);
               
            case "Protanomaly":
               concat([0.817,0.183,0,0,0,0.333,0.667,0,0,0,0,0.125,0.875,0,0,0,0,0,1,0]);
               
            case "Deuteranopia":
               concat([0.625,0.375,0,0,0,0.7,0.3,0,0,0,0,0.3,0.7,0,0,0,0,0,1,0]);
               
            case "Deuteranomaly":
               concat([0.8,0.2,0,0,0,0.258,0.742,0,0,0,0,0.142,0.858,0,0,0,0,0,1,0]);
               
            case "Tritanopia":
               concat([0.95,0.05,0,0,0,0,0.433,0.567,0,0,0,0.475,0.525,0,0,0,0,0,1,0]);
               
            case "Tritanomaly":
               concat([0.967,0.033,0,0,0,0,0.733,0.267,0,0,0,0.183,0.817,0,0,0,0,0,1,0]);
               
            case "Achromatopsia":
               concat([0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0,0,0,1,0]);
               
            case "Achromatomaly":
               concat([0.618,0.32,0.062,0,0,0.163,0.775,0.062,0,0,0.163,0.32,0.516,0,0,0,0,0,1,0]);
         }
      }
      
      public function applyMatrix(param1:UInt) : UInt
      {
         var _loc4_:Float = (param1 : Int) >>> 24 & 0xFF;
         var _loc6_:Float = (param1 : Int) >>> 16 & 0xFF;
         var _loc8_:Float = (param1 : Int) >>> 8 & 0xFF;
         var _loc7_:Float = (param1 : Int) & 0xFF;
         var _loc2_= ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[0]) + _loc8_ * ASCompat.toNumber(matrix[1]) + _loc7_ * ASCompat.toNumber(matrix[2]) + _loc4_ * ASCompat.toNumber(matrix[3]) + matrix[4]);
         var _loc9_= ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[5]) + _loc8_ * ASCompat.toNumber(matrix[6]) + _loc7_ * ASCompat.toNumber(matrix[7]) + _loc4_ * ASCompat.toNumber(matrix[8]) + matrix[9]);
         var _loc3_= ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[10]) + _loc8_ * ASCompat.toNumber(matrix[11]) + _loc7_ * ASCompat.toNumber(matrix[12]) + _loc4_ * ASCompat.toNumber(matrix[13]) + matrix[14]);
         var _loc5_= ASCompat.toInt(0.5 + _loc6_ * ASCompat.toNumber(matrix[15]) + _loc8_ * ASCompat.toNumber(matrix[16]) + _loc7_ * ASCompat.toNumber(matrix[17]) + _loc4_ * ASCompat.toNumber(matrix[18]) + matrix[19]);
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         if(_loc5_ > 255)
         {
            _loc5_ = 255;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         if(_loc2_ > 255)
         {
            _loc2_ = 255;
         }
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         if(_loc9_ > 255)
         {
            _loc9_ = 255;
         }
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ > 255)
         {
            _loc3_ = 255;
         }
         return (_loc5_ << 24 | _loc2_ << 16 | _loc9_ << 8 | _loc3_ : UInt);
      }
      
      public function transformVector(param1:Array<ASAny>) 
      {
         if(param1.length != 4)
         {
            return;
         }
         var _loc3_= ASCompat.toNumber(ASCompat.toNumber(param1[0]) * ASCompat.toNumber(matrix[0]) + ASCompat.toNumber(param1[1]) * ASCompat.toNumber(matrix[1]) + ASCompat.toNumber(param1[2]) * ASCompat.toNumber(matrix[2]) + ASCompat.toNumber(param1[3]) * ASCompat.toNumber(matrix[3]) + matrix[4]);
         var _loc5_= ASCompat.toNumber(ASCompat.toNumber(param1[0]) * ASCompat.toNumber(matrix[5]) + ASCompat.toNumber(param1[1]) * ASCompat.toNumber(matrix[6]) + ASCompat.toNumber(param1[2]) * ASCompat.toNumber(matrix[7]) + ASCompat.toNumber(param1[3]) * ASCompat.toNumber(matrix[8]) + matrix[9]);
         var _loc4_= ASCompat.toNumber(ASCompat.toNumber(param1[0]) * ASCompat.toNumber(matrix[10]) + ASCompat.toNumber(param1[1]) * ASCompat.toNumber(matrix[11]) + ASCompat.toNumber(param1[2]) * ASCompat.toNumber(matrix[12]) + ASCompat.toNumber(param1[3]) * ASCompat.toNumber(matrix[13]) + matrix[14]);
         var _loc2_= ASCompat.toNumber(ASCompat.toNumber(param1[0]) * ASCompat.toNumber(matrix[15]) + ASCompat.toNumber(param1[1]) * ASCompat.toNumber(matrix[16]) + ASCompat.toNumber(param1[2]) * ASCompat.toNumber(matrix[17]) + ASCompat.toNumber(param1[3]) * ASCompat.toNumber(matrix[18]) + matrix[19]);
         param1[0] = _loc3_;
         param1[1] = _loc5_;
         param1[2] = _loc4_;
         param1[3] = _loc2_;
      }
      
      function initHue() 
      {
         var _loc4_:Array<ASAny> = null;
         var _loc1_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc2_:Float = 39.182655;
         if(!hueInitialized)
         {
            hueInitialized = true;
            preHue = new ColorMatrix();
            preHue.rotateRed(45);
            preHue.rotateGreen(-_loc2_);
            _loc4_ = [0.3086,0.6094,0.082,1];
            preHue.transformVector(_loc4_);
            _loc1_ = ASCompat.toNumber(_loc4_[0]) / ASCompat.toNumber(_loc4_[2]);
            _loc3_ = ASCompat.toNumber(_loc4_[1]) / ASCompat.toNumber(_loc4_[2]);
            preHue.shearBlue(_loc1_,_loc3_);
            postHue = new ColorMatrix();
            postHue.shearBlue(-_loc1_,-_loc3_);
            postHue.rotateGreen(_loc2_);
            postHue.rotateRed(-45);
         }
      }
   }


