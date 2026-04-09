package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
    class SetIterator extends ArrayIterator implements ISetIterator
   {
      
      var _set:Set;
      
      public function new(param1:Set)
      {
         this._set = param1;
         super(this._set.toArray());
      }
      
      @:isVar public var nextItem(get,never):ASAny;
public function  get_nextItem() : ASAny
      {
         return _array[_next];
      }
      
      @:isVar public var previousItem(get,never):ASAny;
public function  get_previousItem() : ASAny
      {
         return _array[previousIndex];
      }
      
      override function removeCurrent() 
      {
         this._set.remove(super.current);
         super.removeCurrent();
      }
   }


