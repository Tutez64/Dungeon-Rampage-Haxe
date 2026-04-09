package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.ArrayList;
   import org.as3commons.collections.framework.IOrderedList;
   import org.as3commons.collections.framework.IOrderedListIterator;
   
    class ArrayListIterator extends AbstractListIterator implements IOrderedListIterator
   {
      
      public function new(param1:ArrayList, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
      }
      
      public function addBefore(param1:ASAny) : UInt
      {
         var _loc2_= (0 : UInt);
         _current = -1;
         if(_next == -1)
         {
            _loc2_ = (this._arrayList.size : UInt);
         }
         else
         {
            _loc2_ = (_next : UInt);
            ++_next;
         }
         this._arrayList.addAt(_loc2_,param1);
         return _loc2_;
      }
      
      public function replace(param1:ASAny) : Bool
      {
         if(_current == -1)
         {
            return false;
         }
         return this._arrayList.replaceAt((_current : UInt),param1);
      }
      
      @:isVar var _arrayList(get,never):IOrderedList;
function  get__arrayList() : IOrderedList
      {
         return ASCompat.reinterpretAs(_list , IOrderedList);
      }
      
      public function addAfter(param1:ASAny) : UInt
      {
         var _loc2_= (0 : UInt);
         _current = -1;
         if(_next == -1)
         {
            _loc2_ = (this._arrayList.size : UInt);
            _next = (_loc2_ : Int);
         }
         else
         {
            _loc2_ = (_next : UInt);
         }
         this._arrayList.addAt(_loc2_,param1);
         return _loc2_;
      }
   }


