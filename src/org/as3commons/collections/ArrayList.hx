package org.as3commons.collections
;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IOrderedList;
   import org.as3commons.collections.framework.core.AbstractList;
   import org.as3commons.collections.framework.core.ArrayListIterator;
   import org.as3commons.collections.utils.ArrayUtils;
   
    class ArrayList extends AbstractList implements IOrderedList
   {
      
      public function new()
      {
         super();
      }
      
      public function reverse() : Bool
      {
         if(_array.length < 2)
         {
            return false;
         }
         ASCompat.ASArray.reverse(_array);
         return true;
      }
      
      public function sort(param1:IComparator) : Bool
      {
         if(_array.length < 2)
         {
            return false;
         }
         ArrayUtils.mergeSort(_array,param1);
         return true;
      }
      
      public function addAllAt(param1:UInt, param2:Array<ASAny>) : Bool
      {
         if(param1 <= (_array.length : UInt))
         {
            _array = _array.slice(0,(param1 : Int)).concat(param2).concat(_array.slice((param1 : Int)));
            return true;
         }
         return false;
      }
      
      public function replaceAt(param1:UInt, param2:ASAny) : Bool
      {
         if(param1 < (_array.length : UInt))
         {
            if(_array[(param1 : Int)] == param2)
            {
               return false;
            }
            _array[(param1 : Int)] = param2;
            return true;
         }
         return false;
      }
      
      public function addFirst(param1:ASAny) 
      {
         _array.unshift(param1);
      }
      
      public function addAt(param1:UInt, param2:ASAny) : Bool
      {
         if(param1 <= (_array.length : UInt))
         {
            ASCompat.arraySplice(_array, (param1 : Int),(0 : UInt),[param2]);
            return true;
         }
         return false;
      }
      
      override public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         var _loc2_= (ASCompat.toInt(Std.isOfType(param1 , Int) ? (ASCompat.toInt(param1) : UInt) : (0 : UInt)) : UInt);
         return new ArrayListIterator(this,_loc2_);
      }
      
      public function addLast(param1:ASAny) 
      {
         _array.push(param1);
      }
   }


