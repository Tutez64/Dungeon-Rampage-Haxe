package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IDataProvider;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IList;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractList implements IList implements  IDataProvider
   {
      
      var _array:Array<ASAny>;
      
      public function new()
      {
         
         this._array = new Array<ASAny>();
      }
      
      public function firstIndexOf(param1:ASAny) : Int
      {
         return this._array.indexOf(param1);
      }
      
      @:isVar public var array(never,set):Array<ASAny>;
public function  set_array(param1:Array<ASAny>) :Array<ASAny>      {
         this._array = param1.copy();
return param1;
      }
      
      @:isVar public var size(get,never):UInt;
public function  get_size() : UInt
      {
         return (this._array.length : UInt);
      }
      
      public function removeLast() : ASAny
      {
         return this._array.pop();
      }
      
      public function remove(param1:ASAny) : Bool
      {
         var _loc2_= this._array.indexOf(param1);
         if(_loc2_ == -1)
         {
            return false;
         }
         this._array.splice(_loc2_,(1 : UInt));
         this.itemRemoved((_loc2_ : UInt),param1);
         return true;
      }
      
      public function removeFirst() : ASAny
      {
         return this._array.shift();
      }
      
      public function clear() : Bool
      {
         if(this._array.length == 0)
         {
            return false;
         }
         this._array = new Array<ASAny>();
         return true;
      }
      
      public function removeAllAt(param1:UInt, param2:UInt) : Array<ASAny>
      {
         return this._array.splice((param1 : Int),param2);
      }
      
      function itemRemoved(param1:UInt, param2:ASAny) 
      {
      }
      
      public function removeAt(param1:UInt) : ASAny
      {
         return this._array.splice((param1 : Int),(1 : UInt))[0];
      }
      
      @:isVar public var last(get,never):ASAny;
public function  get_last() : ASAny
      {
         return this._array[this._array.length - 1];
      }
      
      public function count(param1:ASAny) : UInt
      {
         var _loc2_= (0 : UInt);
         var _loc3_= (this._array.length : UInt);
         var _loc4_= 0;
         while((_loc4_ : UInt) < _loc3_)
         {
            if(this._array[_loc4_] == param1)
            {
               _loc2_++;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function add(param1:ASAny) : UInt
      {
         this._array.push(param1);
         return (this._array.length - 1 : UInt);
      }
      
      public function lastIndexOf(param1:ASAny) : Int
      {
         var _loc2_= this._array.length - 1;
         while(_loc2_ >= 0)
         {
            if(param1 == this._array[_loc2_])
            {
               return _loc2_;
            }
            _loc2_--;
         }
         return -1;
      }
      
      public function toArray() : Array<ASAny>
      {
         return this._array.copy();
      }
      
      public function itemAt(param1:UInt) : ASAny
      {
         return this._array[(param1 : Int)];
      }
      
      public function has(param1:ASAny) : Bool
      {
         return this.firstIndexOf(param1) > -1;
      }
      
      /*as3commons_collections*/ @:isVar public var array_internal(get,never):Array<ASAny>;
public function  get_array_internal() : Array<ASAny>
      {
         return this._array;
      }
      
      public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         var _loc2_= (ASCompat.toInt(Std.isOfType(param1 , Int) ? (ASCompat.toInt(param1) : UInt) : (0 : UInt)) : UInt);
         return new AbstractListIterator(this,_loc2_);
      }
      
      @:isVar public var first(get,never):ASAny;
public function  get_first() : ASAny
      {
         return this._array[0];
      }
      
      public function removeAll(param1:ASAny) : UInt
      {
         var _loc2_= (this._array.length : UInt);
         var _loc3_= 0;
         while((_loc3_ : UInt) < _loc2_)
         {
            if(this._array[_loc3_] == param1)
            {
               this._array.splice(_loc3_,(1 : UInt));
               this.itemRemoved((_loc3_ : UInt),param1);
               _loc3_--;
            }
            _loc3_++;
         }
         return _loc2_ - this._array.length;
      }
   }


