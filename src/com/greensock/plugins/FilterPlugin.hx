package com.greensock.plugins
;
   import com.greensock.core.*;
   import flash.filters.*;
   
    class FilterPlugin extends TweenPlugin
   {
      
      public static inline final VERSION:Float = 2.03;
      
      public static inline final API:Float = 1;
      
      var _remove:Bool = false;
      
      var _target:ASObject;
      
      var _index:Int = 0;
      
      var _filter:BitmapFilter;
      
      var _type:Dynamic;
      
      public function new()
      {
         super();
      }
      
      public function onCompleteTween() 
      {
         var _loc1_:Array<ASAny> = null;
         var _loc2_= 0;
         if(_remove)
         {
            _loc1_ = ASCompat.dynamicAs(_target.filters, Array);
            if(!Std.isOfType(_loc1_[_index] , _type))
            {
               _loc2_ = _loc1_.length;
               while(_loc2_-- != 0)
               {
                  if(Std.isOfType(_loc1_[_loc2_] , _type))
                  {
                     _loc1_.splice(_loc2_,(1 : UInt));
                     break;
                  }
               }
            }
            else
            {
               _loc1_.splice(_index,(1 : UInt));
            }
            ASCompat.setProperty(_target, "filters", _loc1_);
         }
      }
      
      function initFilter(param1:ASObject, param2:BitmapFilter, param3:Array<ASAny>) 
      {
         var _loc5_:String = null;
         var _loc6_= 0;
         var _loc7_:HexColorsPlugin = null;
         var _loc4_:Array<ASAny> = ASCompat.dynamicAs(_target.filters, Array);
         var _loc8_:ASObject = Std.isOfType(param1 , BitmapFilter) ? {} : param1;
         _index = -1;
         if(_loc8_.index != null)
         {
            _index = ASCompat.toInt(_loc8_.index);
         }
         else
         {
            _loc6_ = _loc4_.length;
            while(_loc6_-- != 0)
            {
               if(Std.isOfType(_loc4_[_loc6_] , _type))
               {
                  _index = _loc6_;
                  break;
               }
            }
         }
         if(_index == -1 || _loc4_[_index] == null || _loc8_.addFilter == true)
         {
            _index = _loc8_.index != null ? ASCompat.toInt(_loc8_.index) : _loc4_.length;
            _loc4_[_index] = param2;
            ASCompat.setProperty(_target, "filters", _loc4_);
         }
         _filter = ASCompat.dynamicAs(_loc4_[_index], flash.filters.BitmapFilter);
         if(_loc8_.remove == true)
         {
            _remove = true;
            this.onComplete = onCompleteTween;
         }
         _loc6_ = param3.length;
         while(_loc6_-- != 0)
         {
            _loc5_ = param3[_loc6_];
            if(param1.hasOwnProperty(_loc5_ ) && (_filter : ASAny)[_loc5_] != param1[_loc5_])
            {
               if(_loc5_ == "color" || _loc5_ == "highlightColor" || _loc5_ == "shadowColor")
               {
                  _loc7_ = new HexColorsPlugin();
                  _loc7_.initColor(_filter,_loc5_,(ASCompat.toInt((_filter : ASAny)[_loc5_]) : UInt),(ASCompat.toInt(param1[_loc5_]) : UInt));
                  _tweens[_tweens.length] = new PropTween(_loc7_,"changeFactor",0,1,_loc5_,false);
               }
               else if(_loc5_ == "quality" || _loc5_ == "inner" || _loc5_ == "knockout" || _loc5_ == "hideObject")
               {
                  (_filter : ASAny)[_loc5_] = param1[_loc5_];
               }
               else
               {
                  addTween(_filter,_loc5_,ASCompat.toNumber((_filter : ASAny)[_loc5_]),param1[_loc5_],_loc5_);
               }
            }
         }
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         var _loc3_:PropTween = null;
         var _loc2_= _tweens.length;
         var _loc4_:Array<ASAny> = ASCompat.dynamicAs(_target.filters, Array);
         while(_loc2_-- != 0)
         {
            _loc3_ = ASCompat.dynamicAs(_tweens[_loc2_], com.greensock.core.PropTween);
            _loc3_.target[_loc3_.property] = _loc3_.start + _loc3_.change * param1;
         }
         if(!Std.isOfType(_loc4_[_index] , _type))
         {
            _loc2_ = _index = _loc4_.length;
            while(_loc2_-- != 0)
            {
               if(Std.isOfType(_loc4_[_loc2_] , _type))
               {
                  _index = _loc2_;
                  break;
               }
            }
         }
         _loc4_[_index] = _filter;
         ASCompat.setProperty(_target, "filters", _loc4_);
return param1;
      }
   }


