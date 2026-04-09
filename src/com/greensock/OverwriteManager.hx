package com.greensock
;
   import com.greensock.core.*;
   
    final class OverwriteManager
   {
      
      public static var enabled:Bool = false;
      
      public static var mode:Int = 0;
      
      public static inline final version:Float = 6.1;
      
      public static inline final NONE= 0;
      
      public static inline final ALL_IMMEDIATE= 1;
      
      public static inline final AUTO= 2;
      
      public static inline final CONCURRENT= 3;
      
      public static inline final ALL_ONSTART= 4;
      
      public static inline final PREEXISTING= 5;
      
      public function new()
      {
         
      }
      
      public static function getGlobalPaused(param1:TweenCore) : Bool
      {
         var _loc2_= false;
         while(param1 != null)
         {
            if(param1.cachedPaused)
            {
               _loc2_ = true;
               break;
            }
            param1 = param1.timeline;
         }
         return _loc2_;
      }
      
      public static function init(param1:Int = 2) : Int
      {
         if(TweenLite.version < 11.6)
         {
            throw new Error("Warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files). Please download and install the latest version from http://www.tweenlite.com.");
         }
         TweenLite.overwriteManager = OverwriteManager;
         mode = param1;
         enabled = true;
         return mode;
      }
      
      public static function manageOverwrites(param1:TweenLite, param2:ASObject, param3:Array<ASAny>, param4:Int) : Bool
      {
         var _loc19_:Int;
         var _loc5_= 0;
         var _loc6_= false;
         var _loc7_:TweenLite = null;
         var _loc13_= 0;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_:TweenCore = null;
         var _loc17_= Math.NaN;
         var _loc18_:SimpleTimeline = null;
         if(param4 >= 4)
         {
            _loc13_ = param3.length;
            _loc5_ = 0;
            while(_loc5_ < _loc13_)
            {
               _loc7_ = ASCompat.dynamicAs(param3[_loc5_], com.greensock.TweenLite);
               if(_loc7_ != param1)
               {
                  if(_loc7_.setEnabled(false,false))
                  {
                     _loc6_ = true;
                  }
               }
               else if(param4 == 5)
               {
                  break;
               }
               _loc5_++;
            }
            return _loc6_;
         }
         var _loc8_= param1.cachedStartTime + 1e-10;
         var _loc9_:Array<ASAny> = [];
         var _loc10_:Array<ASAny> = [];
         var _loc11_= 0;
         var _loc12_= 0;
         _loc5_ = param3.length;
         while(--_loc5_ > -1)
         {
            _loc7_ = ASCompat.dynamicAs(param3[_loc5_], com.greensock.TweenLite);
            if(!(_loc7_ == param1 || _loc7_.gc || !_loc7_.initted && _loc8_ - _loc7_.cachedStartTime <= 2e-10))
            {
               if(_loc7_.timeline != param1.timeline)
               {
                  if(!getGlobalPaused(_loc7_))
                  {
                     _loc10_[ASCompat.toInt(_loc19_ = _loc11_++)] = _loc7_;
                  }
               }
               else if(_loc7_.cachedStartTime <= _loc8_ && _loc7_.cachedStartTime + _loc7_.totalDuration + 1e-10 > _loc8_ && !_loc7_.cachedPaused && !(param1.cachedDuration == 0 && _loc8_ - _loc7_.cachedStartTime <= 2e-10))
               {
                  _loc9_[ASCompat.toInt(_loc19_ = _loc12_++)] = _loc7_;
               }
            }
         }
         if(_loc11_ != 0)
         {
            _loc14_ = param1.cachedTimeScale;
            _loc15_ = _loc8_;
            _loc18_ = param1.timeline;
            while(_loc18_ != null)
            {
               _loc14_ *= _loc18_.cachedTimeScale;
               _loc15_ += _loc18_.cachedStartTime;
               _loc18_ = _loc18_.timeline;
            }
            _loc8_ = _loc14_ * _loc15_;
            _loc5_ = _loc11_;
            while(--_loc5_ > -1)
            {
               _loc16_ = ASCompat.dynamicAs(_loc10_[_loc5_], com.greensock.core.TweenCore);
               _loc14_ = _loc16_.cachedTimeScale;
               _loc15_ = _loc16_.cachedStartTime;
               _loc18_ = _loc16_.timeline;
               while(_loc18_ != null)
               {
                  _loc14_ *= _loc18_.cachedTimeScale;
                  _loc15_ += _loc18_.cachedStartTime;
                  _loc18_ = _loc18_.timeline;
               }
               _loc17_ = _loc14_ * _loc15_;
               if(_loc17_ <= _loc8_ && (_loc17_ + _loc16_.totalDuration * _loc14_ + 1e-10 > _loc8_ || _loc16_.cachedDuration == 0))
               {
                  _loc9_[ASCompat.toInt(_loc19_ = _loc12_++)] = _loc16_;
               }
            }
         }
         if(_loc12_ == 0)
         {
            return _loc6_;
         }
         _loc5_ = _loc12_;
         if(param4 == 2)
         {
            while(--_loc5_ > -1)
            {
               _loc7_ = ASCompat.dynamicAs(_loc9_[_loc5_], com.greensock.TweenLite);
               if(_loc7_.killVars(param2))
               {
                  _loc6_ = true;
               }
               if(_loc7_.cachedPT1 == null && _loc7_.initted)
               {
                  _loc7_.setEnabled(false,false);
               }
            }
         }
         else
         {
            while(--_loc5_ > -1)
            {
               if(cast(_loc9_[_loc5_], TweenLite).setEnabled(false,false))
               {
                  _loc6_ = true;
               }
            }
         }
         return _loc6_;
      }
   }


