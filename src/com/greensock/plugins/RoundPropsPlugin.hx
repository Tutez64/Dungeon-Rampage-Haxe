package com.greensock.plugins
;
   import com.greensock.TweenLite;
   import com.greensock.core.PropTween;
   
    class RoundPropsPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _tween:TweenLite;
      
      public function new()
      {
         super();
         this.propName = "roundProps";
         this.overwriteProps = ["roundProps"];
         this.round = true;
         this.priority = -1;
         this.onInitAllProps = _initAllProps;
      }
      
      public function add(param1:ASObject, param2:String, param3:Float, param4:Float) 
      {
         addTween(param1,param2,param3,param3 + param4,param2);
         this.overwriteProps[this.overwriteProps.length] = param2;
      }
      
      function _removePropTween(param1:PropTween) 
      {
         if(param1.nextNode != null)
         {
            param1.nextNode.prevNode = param1.prevNode;
         }
         if(param1.prevNode != null)
         {
            param1.prevNode.nextNode = param1.nextNode;
         }
         else if(_tween.cachedPT1 == param1)
         {
            _tween.cachedPT1 = param1.nextNode;
         }
         if(param1.isPlugin && ASCompat.toBool(param1.target.onDisable))
         {
            param1.target.onDisable();
         }
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _tween = param3;
         this.overwriteProps = this.overwriteProps.concat(ASCompat.dynamicAs(param2 , Array));
         return true;
      }
      
      function _initAllProps() 
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc4_:PropTween = null;
         var _loc3_:Array<ASAny> = ASCompat.dynamicAs(_tween.vars.roundProps, Array);
         var _loc5_= _loc3_.length;
         while(--_loc5_ > -1)
         {
            _loc1_ = _loc3_[_loc5_];
            _loc4_ = _tween.cachedPT1;
            while(_loc4_ != null)
            {
               if(_loc4_.name == _loc1_)
               {
                  if(_loc4_.isPlugin)
                  {
                     ASCompat.setProperty(_loc4_.target, "round", true);
                  }
                  else
                  {
                     add(_loc4_.target,_loc1_,_loc4_.start,_loc4_.change);
                     _removePropTween(_loc4_);
                     _tween.propTweenLookup[_loc1_] = _tween.propTweenLookup.roundProps;
                  }
               }
               else if(_loc4_.isPlugin && _loc4_.name == "_MULTIPLE_" && !ASCompat.toBool(_loc4_.target.round))
               {
                  _loc2_ = " " + Std.string(ASCompat.dynJoin(_loc4_.target.overwriteProps, " "))+ " ";
                  if(_loc2_.indexOf(" " + _loc1_ + " ") != -1)
                  {
                     ASCompat.setProperty(_loc4_.target, "round", true);
                  }
               }
               _loc4_ = _loc4_.nextNode;
            }
         }
      }
   }


