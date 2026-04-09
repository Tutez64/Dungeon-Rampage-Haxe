package com.greensock.plugins
;
   import com.greensock.*;
   
    class EndArrayPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _a:Array<ASAny>;
      
      var _info:Array<ASAny> = [];
      
      public function new()
      {
         super();
         this.propName = "endArray";
         this.overwriteProps = ["endArray"];
      }
      
      public function init(param1:Array<ASAny>, param2:Array<ASAny>) 
      {
         _a = param1;
         var _loc3_= param2.length;
         while(_loc3_-- != 0)
         {
            if(param1[_loc3_] != param2[_loc3_] && param1[_loc3_] != null)
            {
               _info[_info.length] = new ArrayTweenInfo((_loc3_ : UInt),ASCompat.toNumber(_a[_loc3_]),ASCompat.toNumber(ASCompat.toNumber(param2[_loc3_]) - ASCompat.toNumber(_a[_loc3_])));
            }
         }
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(!Std.isOfType(param1 , Array) || !Std.isOfType(param2 , Array))
         {
            return false;
         }
         init(ASCompat.dynamicAs(param1 , Array),ASCompat.dynamicAs(param2, Array));
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         var _loc3_:ArrayTweenInfo = null;
         var _loc4_= Math.NaN;
         var _loc2_= _info.length;
         if(this.round)
         {
            while(_loc2_-- != 0)
            {
               _loc3_ = ASCompat.dynamicAs(_info[_loc2_], ArrayTweenInfo);
               _loc4_ = _loc3_.start + _loc3_.change * param1;
               if(_loc4_ > 0)
               {
                  _a[(_loc3_.index : Int)] = Std.int(_loc4_ + 0.5) >> 0;
               }
               else
               {
                  _a[(_loc3_.index : Int)] = Std.int(_loc4_ - 0.5) >> 0;
               }
            }
         }
         else
         {
            while(_loc2_-- != 0)
            {
               _loc3_ = ASCompat.dynamicAs(_info[_loc2_], ArrayTweenInfo);
               _a[(_loc3_.index : Int)] = _loc3_.start + _loc3_.change * param1;
            }
         }
return param1;
      }
   }


private class ArrayTweenInfo
{
   
   public var change:Float = Math.NaN;
   
   public var start:Float = Math.NaN;
   
   public var index:UInt = 0;
   
   public function new(param1:UInt, param2:Float, param3:Float)
   {
      
      this.index = param1;
      this.start = param2;
      this.change = param3;
   }
}
