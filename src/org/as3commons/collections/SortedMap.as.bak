package org.as3commons.collections
{
   import flash.utils.Dictionary;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISortedMap;
   import org.as3commons.collections.framework.core.AbstractSortedDuplicatesCollection;
   import org.as3commons.collections.framework.core.SortedMapIterator;
   import org.as3commons.collections.framework.core.SortedMapNode;
   import org.as3commons.collections.framework.core.SortedNode;
   import org.as3commons.collections.framework.core.as3commons_collections;
   
   use namespace as3commons_collections;
   
   public class SortedMap extends AbstractSortedDuplicatesCollection implements ISortedMap
   {
      
      protected var _items:Dictionary;
      
      protected var _stringMap:Object;
      
      protected var _keys:Dictionary;
      
      public function SortedMap(param1:IComparator)
      {
         super(param1);
         this._items = new Dictionary();
         this._keys = new Dictionary();
         this._stringMap = new Object();
      }
      
      override protected function addNode(param1:SortedNode) : void
      {
         super.addNode(param1);
         var _loc2_:* = SortedMapNode(param1).key;
         if(_loc2_ is String)
         {
            this._stringMap[_loc2_] = param1;
         }
         else
         {
            this._keys[_loc2_] = _loc2_;
            this._items[_loc2_] = param1;
         }
      }
      
      public function equalKeys(param1:*) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:SortedNode = firstEqualNode(param1);
         if(!_loc3_)
         {
            return _loc2_;
         }
         while(_loc3_)
         {
            if(_comparator.compare(param1,_loc3_.item))
            {
               break;
            }
            _loc2_.push(SortedMapNode(_loc3_).key);
            _loc3_ = as3commons_collections::nextNode_internal(_loc3_);
         }
         return _loc2_;
      }
      
      public function keysToArray() : Array
      {
         var _loc1_:SortedNode = as3commons_collections::mostLeftNode_internal();
         var _loc2_:Array = new Array();
         while(_loc1_)
         {
            _loc2_.push(SortedMapNode(_loc1_).key);
            _loc1_ = as3commons_collections::nextNode_internal(_loc1_);
         }
         return _loc2_;
      }
      
      override public function clear() : Boolean
      {
         if(!_size)
         {
            return false;
         }
         this._keys = new Dictionary();
         this._items = new Dictionary();
         this._stringMap = new Object();
         super.clear();
         return true;
      }
      
      public function higherKey(param1:*) : *
      {
         var _loc2_:SortedMapNode = higherNode(param1) as SortedMapNode;
         if(!_loc2_)
         {
            return undefined;
         }
         return _loc2_.key;
      }
      
      public function add(param1:*, param2:*) : Boolean
      {
         if(param1 is String)
         {
            if(this._stringMap[param1] !== undefined)
            {
               return false;
            }
         }
         else if(this._keys[param1] !== undefined)
         {
            return false;
         }
         this.addNode(new SortedMapNode(param1,param2));
         return true;
      }
      
      public function hasKey(param1:*) : Boolean
      {
         return param1 is String ? this._stringMap[param1] !== undefined : this._keys[param1] !== undefined;
      }
      
      public function keyIterator() : IIterator
      {
         return new KeyIterator(this);
      }
      
      override public function iterator(param1:* = undefined) : IIterator
      {
         var _loc2_:SortedMapNode = null;
         if(param1 is String)
         {
            _loc2_ = this._stringMap[param1];
         }
         else
         {
            _loc2_ = this._items[param1];
         }
         return new SortedMapIterator(this,_loc2_);
      }
      
      public function replaceFor(param1:*, param2:*) : Boolean
      {
         var _loc3_:SortedMapNode = null;
         if(param1 is String)
         {
            _loc3_ = this._stringMap[param1];
         }
         else
         {
            _loc3_ = this._items[param1];
         }
         if(Boolean(_loc3_) && _loc3_.item !== param2)
         {
            this.removeNode(_loc3_);
            _loc3_.item = param2;
            this.addNode(_loc3_);
            return true;
         }
         return false;
      }
      
      public function itemFor(param1:*) : *
      {
         var _loc2_:SortedMapNode = null;
         if(param1 is String)
         {
            _loc2_ = this._stringMap[param1];
         }
         else
         {
            _loc2_ = this._items[param1];
         }
         return _loc2_ ? _loc2_.item : undefined;
      }
      
      protected function getNode(param1:*) : SortedMapNode
      {
         if(param1 is String)
         {
            return this._stringMap[param1];
         }
         return this._items[param1];
      }
      
      public function lesserKey(param1:*) : *
      {
         var _loc2_:SortedMapNode = lesserNode(param1) as SortedMapNode;
         if(!_loc2_)
         {
            return undefined;
         }
         return _loc2_.key;
      }
      
      public function removeKey(param1:*) : *
      {
         var _loc2_:SortedMapNode = null;
         if(param1 is String)
         {
            if(this._stringMap[param1] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._stringMap[param1];
         }
         else
         {
            if(this._keys[param1] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._items[param1];
         }
         this.removeNode(_loc2_);
         return _loc2_.item;
      }
      
      override protected function removeNode(param1:SortedNode) : void
      {
         super.removeNode(param1);
         var _loc2_:* = SortedMapNode(param1).key;
         if(_loc2_ is String)
         {
            delete this._stringMap[_loc2_];
         }
         else
         {
            delete this._keys[_loc2_];
            delete this._items[_loc2_];
         }
      }
   }
}

import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.core.SortedMapNode;
import org.as3commons.collections.framework.core.SortedNode;
import org.as3commons.collections.framework.core.as3commons_collections;

use namespace as3commons_collections;

class KeyIterator implements IIterator
{
   
   private var _next:SortedNode;
   
   private var _map:SortedMap;
   
   public function KeyIterator(param1:SortedMap)
   {
      super();
      this._map = param1;
      this._next = param1.as3commons_collections::mostLeftNode_internal();
   }
   
   public function next() : *
   {
      if(!this._next)
      {
         return undefined;
      }
      var _loc1_:SortedNode = this._next;
      this._next = this._map.as3commons_collections::nextNode_internal(this._next);
      return SortedMapNode(_loc1_).key;
   }
   
   public function hasNext() : Boolean
   {
      return this._next != null;
   }
}
