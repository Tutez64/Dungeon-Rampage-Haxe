package org.as3commons.collections.iterators
;
   import org.as3commons.collections.framework.IListIterator;
   
    class ArrayIterator implements IListIterator
   {
      
      var _next:Int = 0;
      
      var _array:Array<ASAny>;
      
      var _current:Int = -1;
      
      public function new(param1:Array<ASAny>, param2:UInt = (0 : UInt))
      {
         
         this._array = param1;
         this._next = param2 >= (this._array.length : UInt) ? -1 : param2;
      }
      
      public function next() : ASAny
      {
         if(this._next == -1)
         {
            this._current = -1;
            return /*undefined*/null;
         }
         this._current = this._next;
         this._next = this._next >= this._array.length - 1 ? -1 : this._next + 1;
         return this._array[this._current];
      }
      
      public function remove() : Bool
      {
         if(this._current == -1)
         {
            return false;
         }
         if(this._current == this._next)
         {
            if(this._next >= this._array.length - 1)
            {
               this._next = -1;
            }
         }
         else if(this._next > 0)
         {
            --this._next;
         }
         this.removeCurrent();
         this._current = -1;
         return true;
      }
      
      public function end() 
      {
         this._next = this._current = -1;
      }
      
      @:isVar public var previousIndex(get,never):Int;
public function  get_previousIndex() : Int
      {
         return this._next == -1 ? this._array.length - 1 : this._next - 1;
      }
      
      function removeCurrent() 
      {
         this._array.splice(this._current,(1 : UInt))[0];
      }
      
      @:isVar public var nextIndex(get,never):Int;
public function  get_nextIndex() : Int
      {
         return this._next;
      }
      
      @:isVar public var index(get,never):Int;
public function  get_index() : Int
      {
         return this._current;
      }
      
      public function start() 
      {
         this._next = this._array.length != 0 ? 0 : -1;
         this._current = -1;
      }
      
      public function hasNext() : Bool
      {
         return this._next > -1;
      }
      
      public function hasPrevious() : Bool
      {
         return ASCompat.toBool(this._next) && ASCompat.toBool(this._array.length);
      }
      
      public function previous() : ASAny
      {
         if(this._next == 0 || this._array.length == 0)
         {
            this._current = -1;
            return /*undefined*/null;
         }
         this._next = this._next == -1 ? this._array.length - 1 : this._next - 1;
         this._current = this._next;
         return this._array[this._current];
      }
      
      @:isVar public var current(get,never):ASAny;
public function  get_current() : ASAny
      {
         return this._array[this._current];
      }
   }


