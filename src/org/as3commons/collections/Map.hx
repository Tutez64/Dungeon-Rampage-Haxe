package org.as3commons.collections
;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IMap;
   import org.as3commons.collections.framework.core.MapIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
    class Map implements IMap
   {
      
      var _items:ASDictionary<ASAny,ASAny>;
      
      var _stringMap:ASObject;
      
      var _keys:ASDictionary<ASAny,ASAny>;
      
      var _size:UInt = (0 : UInt);
      
      public function new()
      {
         
         this._items = new ASDictionary<ASAny,ASAny>();
         this._keys = new ASDictionary<ASAny,ASAny>();
         this._stringMap = new ASObject();
      }
      
      public function removeAll(param1:ASAny) : UInt
      {
         var _loc3_:String = null;
         var _loc4_:ASAny = /*undefined*/null;
         var _loc2_= (0 : UInt);
         final __ax4_iter_160:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_160)) for(_tmp_ in __ax4_iter_160.___keys())
         {
            _loc3_  = _tmp_;
            if(this._stringMap[_loc3_] == param1)
            {
               ASCompat.deleteProperty(this._stringMap, _loc3_);
               --this._size;
               this.itemRemoved(_loc3_,param1);
               _loc2_++;
            }
         }
         final __ax4_iter_161 = this._items;
         if (checkNullIteratee(__ax4_iter_161)) for(_tmp_ in __ax4_iter_161.keys())
         {
            _loc4_  = _tmp_;
            if(this._items[_loc4_] == param1)
            {
               this._keys.remove(_loc4_);
               this._items.remove(_loc4_);
               --this._size;
               this.itemRemoved(_loc3_,param1);
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      @:isVar public var size(get,never):UInt;
public function  get_size() : UInt
      {
         return this._size;
      }
      
      public function keysToArray() : Array<ASAny>
      {
         var _loc2_:String = null;
         var _loc3_:ASAny = /*undefined*/null;
         var _loc1_= new Array<ASAny>();
         final __ax4_iter_162:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_162)) for(_tmp_ in __ax4_iter_162.___keys())
         {
            _loc2_  = _tmp_;
            _loc1_.push(_loc2_);
         }
         final __ax4_iter_163 = this._keys;
         if (checkNullIteratee(__ax4_iter_163)) for (_tmp_ in __ax4_iter_163)
         {
            _loc3_  = _tmp_;
            _loc1_.push(_loc3_);
         }
         return _loc1_;
      }
      
      public function clear() : Bool
      {
         if(this._size == 0)
         {
            return false;
         }
         this._keys = new ASDictionary<ASAny,ASAny>();
         this._items = new ASDictionary<ASAny,ASAny>();
         this._stringMap = new ASObject();
         this._size = (0 : UInt);
         return true;
      }
      
      public function count(param1:ASAny) : UInt
      {
         var _loc3_:ASAny = /*undefined*/null;
         var _loc2_= (0 : UInt);
         final __ax4_iter_164:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_164)) for (_tmp_ in iterateDynamicValues(__ax4_iter_164))
         {
            _loc3_  = _tmp_;
            if(_loc3_ == param1)
            {
               _loc2_++;
            }
         }
         final __ax4_iter_165 = this._items;
         if (checkNullIteratee(__ax4_iter_165)) for (_tmp_ in __ax4_iter_165)
         {
            _loc3_  = _tmp_;
            if(_loc3_ == param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function has(param1:ASAny) : Bool
      {
         var _loc2_:ASAny = /*undefined*/null;
         final __ax4_iter_166:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_166)) for (_tmp_ in iterateDynamicValues(__ax4_iter_166))
         {
            _loc2_  = _tmp_;
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         final __ax4_iter_167 = this._items;
         if (checkNullIteratee(__ax4_iter_167)) for (_tmp_ in __ax4_iter_167)
         {
            _loc2_  = _tmp_;
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function remove(param1:ASAny) : Bool
      {
         var _loc2_:String = null;
         var _loc3_:ASAny = /*undefined*/null;
         final __ax4_iter_168:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_168)) for(_tmp_ in __ax4_iter_168.___keys())
         {
            _loc2_  = _tmp_;
            if(this._stringMap[_loc2_] == param1)
            {
               ASCompat.deleteProperty(this._stringMap, _loc2_);
               --this._size;
               this.itemRemoved(_loc2_,param1);
               return true;
            }
         }
         final __ax4_iter_169 = this._items;
         if (checkNullIteratee(__ax4_iter_169)) for(_tmp_ in __ax4_iter_169.keys())
         {
            _loc3_  = _tmp_;
            if(this._items[_loc3_] == param1)
            {
               this._keys.remove(_loc3_);
               this._items.remove(_loc3_);
               --this._size;
               this.itemRemoved(_loc2_,param1);
               return true;
            }
         }
         return false;
      }
      
      public function toArray() : Array<ASAny>
      {
         var _loc2_:ASAny = /*undefined*/null;
         var _loc1_= new Array<ASAny>();
         final __ax4_iter_170:ASObject = this._stringMap;
         if (checkNullIteratee(__ax4_iter_170)) for (_tmp_ in iterateDynamicValues(__ax4_iter_170))
         {
            _loc2_  = _tmp_;
            _loc1_.push(_loc2_);
         }
         final __ax4_iter_171 = this._items;
         if (checkNullIteratee(__ax4_iter_171)) for (_tmp_ in __ax4_iter_171)
         {
            _loc2_  = _tmp_;
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function add(param1:ASAny, param2:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            if(ASCompat.hasProperty(this._stringMap, param1))
            {
               return false;
            }
            this._stringMap[param1] = param2;
         }
         else
         {
            if(this._keys.exists(param1))
            {
               return false;
            }
            this._keys[param1] = param1;
            this._items[param1] = param2;
         }
         ++this._size;
         return true;
      }
      
      public function hasKey(param1:ASAny) : Bool
      {
         return Std.isOfType(param1 , String) ? ASCompat.hasProperty(this._stringMap, param1) : this._keys.exists(param1);
      }
      
      public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         return new MapIterator(this);
      }
      
      function itemRemoved(param1:ASAny, param2:ASAny) 
      {
      }
      
      public function keyIterator() : IIterator
      {
         return new ArrayIterator(this.keysToArray());
      }
      
      public function replaceFor(param1:ASAny, param2:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            switch(param2)
            {
               case (_ == this._stringMap[param1] => true):
                  return false;
               case (_ == this._stringMap[param1] => true):
                  return false;
               default:
                  this._stringMap[param1] = param2;
            }
         }
         else
         {
            switch(param2)
            {
               case (_ == this._keys[param1] => true):
                  return false;
               case (_ == this._items[param1] => true):
                  return false;
               default:
                  this._items[param1] = param2;
            }
         }
         return true;
      }
      
      public function removeKey(param1:ASAny) : ASAny
      {
         var _loc2_:ASAny = /*undefined*/null;
         if(Std.isOfType(param1 , String))
         {
            if(!ASCompat.hasProperty(this._stringMap, param1))
            {
               return /*undefined*/null;
            }
            _loc2_ = this._stringMap[param1];
            ASCompat.deleteProperty(this._stringMap, param1);
         }
         else
         {
            if(!this._keys.exists(param1))
            {
               return /*undefined*/null;
            }
            _loc2_ = this._items[param1];
            this._keys.remove(param1);
            this._items.remove(param1);
         }
         --this._size;
         return _loc2_;
      }
      
      public function itemFor(param1:ASAny) : ASAny
      {
         if(Std.isOfType(param1 , String))
         {
            return this._stringMap[param1];
         }
         return this._items[param1];
      }
   }


