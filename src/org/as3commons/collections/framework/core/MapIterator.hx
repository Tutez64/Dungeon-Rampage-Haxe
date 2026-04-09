package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
    class MapIterator extends ArrayIterator implements IMapIterator
   {
      
      var _map:Map;
      
      public function new(param1:Map)
      {
         this._map = param1;
         super(this._map.keysToArray());
      }
      
      override public function next() : ASAny
      {
         return this._map.itemFor(super.next());
      }
      
      @:isVar public var previousKey(get,never):ASAny;
public function  get_previousKey() : ASAny
      {
         return _array[previousIndex];
      }
      
      override function removeCurrent() 
      {
         this._map.removeKey(super.current);
         super.removeCurrent();
      }
      
      override public function previous() : ASAny
      {
         return this._map.itemFor(super.previous());
      }
      
      override public function  get_current() : ASAny
      {
         return this._map.itemFor(super.current);
      }
      
      @:isVar public var nextKey(get,never):ASAny;
public function  get_nextKey() : ASAny
      {
         return _array[_next];
      }
      
      @:isVar public var key(get,never):ASAny;
public function  get_key() : ASAny
      {
         return super.current;
      }
   }


