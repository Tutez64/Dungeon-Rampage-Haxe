package com.greensock.plugins
;
   import com.greensock.*;
   
    class HexColorsPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _colors:Array<ASAny>;
      
      public function new()
      {
         super();
         this.propName = "hexColors";
         this.overwriteProps = [];
         _colors = [];
      }
      
      override public function killProps(param1:ASObject) 
      {
         var _loc2_= _colors.length - 1;
         while(_loc2_ > -1)
         {
            if(ASCompat.hasProperty(param1, ASCompat.dynGetIndex(_colors[_loc2_], 1)))
            {
               _colors.splice(_loc2_,(1 : UInt));
            }
            _loc2_--;
         }
         super.killProps(param1);
      }
      
      public function initColor(param1:ASObject, param2:String, param3:UInt, param4:UInt) 
      {
         var _loc5_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         if(param3 != param4)
         {
            _loc5_ = (param3 : Int) >> 16;
            _loc6_ = (param3 : Int) >> 8 & 0xFF;
            _loc7_ = (param3 : Int) & 0xFF;
            _colors[_colors.length] = ([param1,param2,_loc5_,((param4 : Int) >> 16) - _loc5_,_loc6_,((param4 : Int) >> 8 & 0xFF) - _loc6_,_loc7_,((param4 : Int) & 0xFF) - _loc7_] : Array<ASAny>);
            this.overwriteProps[this.overwriteProps.length] = param2;
         }
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         var _loc3_:Array<ASAny> = null;
         var _loc2_= _colors.length;
         while(--_loc2_ > -1)
         {
            _loc3_ = ASCompat.dynamicAs(_colors[_loc2_], Array);
            _loc3_[0][_loc3_[1]] = ASCompat.toInt(_loc3_[2] + param1 * ASCompat.toNumber(_loc3_[3])) << 16 | ASCompat.toInt(_loc3_[4] + param1 * ASCompat.toNumber(_loc3_[5])) << 8 | ASCompat.toInt(_loc3_[6] + param1 * ASCompat.toNumber(_loc3_[7]));
         }
return param1;
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         var _loc4_:String = null;
         if (checkNullIteratee(param2)) for(_tmp_ in param2.___keys())
         {
            _loc4_  = _tmp_;
            initColor(param1,_loc4_,(ASCompat.toInt(param1[_loc4_]) : UInt),(ASCompat.toInt(param2[_loc4_]) : UInt));
         }
         return true;
      }
   }


