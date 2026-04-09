package org.as3commons.collections.utils
;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IMap;
   
    class ArrayUtils
   {
      
      public function new()
      {
         
      }
      
      public static function shuffle(param1:Array<ASAny>) : Bool
      {
         var _loc3_= (0 : UInt);
         var _loc4_:ASAny = /*undefined*/null;
         var _loc2_= (param1.length : UInt);
         if(_loc2_ < 2)
         {
            return false;
         }
         while(--_loc2_ != 0)
         {
            _loc3_ = (Math.floor(Math.random() * (_loc2_ + 1)) : UInt);
            _loc4_ = param1[(_loc2_ : Int)];
            param1[(_loc2_ : Int)] = param1[(_loc3_ : Int)];
            param1[(_loc3_ : Int)] = _loc4_;
         }
         return true;
      }
      
      public static function arraysEqual(param1:Array<ASAny>, param2:Array<ASAny>) : Bool
      {
         if(param1 == param2)
         {
            return true;
         }
         var _loc3_:Float = param1.length;
         if(_loc3_ != param2.length)
         {
            return false;
         }
         while(ASCompat.floatAsBool(_loc3_--))
         {
            if(param1[Std.int(_loc3_)] != param2[Std.int(_loc3_)])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function arraysMatch(param1:Array<ASAny>, param2:Array<ASAny>) : Bool
      {
         if(param1 == param2)
         {
            return true;
         }
         var _loc3_:Float = param1.length;
         if(_loc3_ != param2.length)
         {
            return false;
         }
         var _loc4_:IMap = new Map();
         while(ASCompat.floatAsBool(_loc3_--))
         {
            if(_loc4_.hasKey(param1[Std.int(_loc3_)]))
            {
               _loc4_.replaceFor(param1[Std.int(_loc3_)],_loc4_.itemFor(param1[Std.int(_loc3_)]) + 1);
            }
            else
            {
               _loc4_.add(param1[Std.int(_loc3_)],1);
            }
         }
         _loc3_ = param2.length;
         while(ASCompat.floatAsBool(_loc3_--))
         {
            if(!_loc4_.hasKey(param2[Std.int(_loc3_)]))
            {
               return false;
            }
            if(ASCompat.toNumber(_loc4_.itemFor(param2[Std.int(_loc3_)])) == 1)
            {
               _loc4_.removeKey(param2[Std.int(_loc3_)]);
            }
            else
            {
               _loc4_.replaceFor(param2[Std.int(_loc3_)],ASCompat.toNumber(_loc4_.itemFor(param2[Std.int(_loc3_)])) - 1);
            }
         }
         return _loc4_.size == 0;
      }
      
      public static function insertionSort(param1:Array<ASAny>, param2:IComparator) : Bool
      {
         var _loc5_:ASAny = /*undefined*/null;
         var _loc6_= (0 : UInt);
         if(param1.length < 2)
         {
            return false;
         }
         var _loc3_= (param1.length : UInt);
         var _loc4_= (1 : UInt);
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param1[(_loc4_ : Int)];
            _loc6_ = _loc4_;
            while(_loc6_ > 0 && param2.compare(param1[(_loc6_ - 1 : Int)],_loc5_) == 1)
            {
               param1[(_loc6_ : Int)] = param1[(_loc6_ - 1 : Int)];
               _loc6_--;
            }
            param1[(_loc6_ : Int)] = _loc5_;
            _loc4_++;
         }
         return true;
      }
      
      public static function mergeSort(param1:Array<ASAny>, param2:IComparator) : Bool
      {
         if(param1.length < 2)
         {
            return false;
         }
         var _loc3_= (Math.floor(param1.length / 2) : UInt);
         var _loc4_= (param1.length - _loc3_ : UInt);
         var _loc5_= ASCompat.allocArray(_loc3_);
         var _loc6_= ASCompat.allocArray(_loc4_);
         var _loc7_= (0 : UInt);
         _loc7_ = (0 : UInt);
         while(_loc7_ < _loc3_)
         {
            _loc5_[(_loc7_ : Int)] = param1[(_loc7_ : Int)];
            _loc7_++;
         }
         _loc7_ = _loc3_;
         while(_loc7_ < _loc3_ + _loc4_)
         {
            _loc6_[(_loc7_ - _loc3_ : Int)] = param1[(_loc7_ : Int)];
            _loc7_++;
         }
         mergeSort(_loc5_,param2);
         mergeSort(_loc6_,param2);
         _loc7_ = (0 : UInt);
         var _loc8_= (0 : UInt);
         var _loc9_= (0 : UInt);
         while((_loc5_.length : UInt) != _loc8_ && (_loc6_.length : UInt) != _loc9_)
         {
            if(param2.compare(_loc5_[(_loc8_ : Int)],_loc6_[(_loc9_ : Int)]) != 1)
            {
               param1[(_loc7_ : Int)] = _loc5_[(_loc8_ : Int)];
               _loc7_++;
               _loc8_++;
            }
            else
            {
               param1[(_loc7_ : Int)] = _loc6_[(_loc9_ : Int)];
               _loc7_++;
               _loc9_++;
            }
         }
         while((_loc5_.length : UInt) != _loc8_)
         {
            param1[(_loc7_ : Int)] = _loc5_[(_loc8_ : Int)];
            _loc7_++;
            _loc8_++;
         }
         while((_loc6_.length : UInt) != _loc9_)
         {
            param1[(_loc7_ : Int)] = _loc6_[(_loc9_ : Int)];
            _loc7_++;
            _loc9_++;
         }
         return true;
      }
   }


