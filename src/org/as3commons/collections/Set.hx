package org.as3commons.collections
;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISet;
   import org.as3commons.collections.framework.core.SetIterator;
   
    class Set implements ISet
   {
      
      var _size:UInt = (0 : UInt);
      
      var _items:ASDictionary<ASAny,ASAny>;
      
      var _stringItems:ASObject;
      
      public function new()
      {
         
         this._items = new ASDictionary<ASAny,ASAny>();
         this._stringItems = new ASObject();
      }
      
      @:isVar public var size(get,never):UInt;
public function  get_size() : UInt
      {
         return this._size;
      }
      
      public function remove(param1:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            if(!ASCompat.hasProperty(this._stringItems, param1))
            {
               return false;
            }
            ASCompat.deleteProperty(this._stringItems, param1);
         }
         else
         {
            if(!this._items.exists(param1))
            {
               return false;
            }
            this._items.remove(param1);
         }
         --this._size;
         return true;
      }
      
      public function clear() : Bool
      {
         if(this._size == 0)
         {
            return false;
         }
         this._items = new ASDictionary<ASAny,ASAny>();
         this._stringItems = new ASObject();
         this._size = (0 : UInt);
         return true;
      }
      
      public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         return new SetIterator(this);
      }
      
      public function add(param1:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            if(ASCompat.hasProperty(this._stringItems, param1))
            {
               return false;
            }
            this._stringItems[param1] = param1;
         }
         else
         {
            if(this._items.exists(param1))
            {
               return false;
            }
            this._items[param1] = param1;
         }
         ++this._size;
         return true;
      }
      
      public function has(param1:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            return ASCompat.hasProperty(this._stringItems, param1);
         }
         return this._items.exists(param1);
      }
      
      public function toArray() : Array<ASAny>
      {
         var _loc2_:ASAny = /*undefined*/null;
         var _loc1_= new Array<ASAny>();
         final __ax4_iter_158:ASObject = this._stringItems;
         if (checkNullIteratee(__ax4_iter_158)) for (_tmp_ in iterateDynamicValues(__ax4_iter_158))
         {
            _loc2_  = _tmp_;
            _loc1_.push(_loc2_);
         }
         final __ax4_iter_159 = this._items;
         if (checkNullIteratee(__ax4_iter_159)) for (_tmp_ in __ax4_iter_159)
         {
            _loc2_  = _tmp_;
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
   }


