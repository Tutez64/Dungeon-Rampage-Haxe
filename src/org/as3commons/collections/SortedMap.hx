package org.as3commons.collections
;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISortedMap;
   import org.as3commons.collections.framework.core.AbstractSortedDuplicatesCollection;
   import org.as3commons.collections.framework.core.SortedMapIterator;
   import org.as3commons.collections.framework.core.SortedMapNode;
   import org.as3commons.collections.framework.core.SortedNode;

import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.SortedMap;
import org.as3commons.collections.framework.core.SortedMapNode;
import org.as3commons.collections.framework.core.SortedNode;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class SortedMap extends AbstractSortedDuplicatesCollection implements ISortedMap
   {
      
      var _items:ASDictionary<ASAny,ASAny>;
      
      var _stringMap:ASObject;
      
      var _keys:ASDictionary<ASAny,ASAny>;
      
      public function new(param1:IComparator)
      {
         super(param1);
         this._items = new ASDictionary<ASAny,ASAny>();
         this._keys = new ASDictionary<ASAny,ASAny>();
         this._stringMap = new ASObject();
      }
      
      override function addNode(param1:SortedNode) 
      {
         super.addNode(param1);
         var _loc2_:ASAny = cast(param1, SortedMapNode).key;
         if(Std.isOfType(_loc2_ , String))
         {
            this._stringMap[_loc2_] = param1;
         }
         else
         {
            this._keys[_loc2_] = _loc2_;
            this._items[_loc2_] = param1;
         }
      }
      
      public function equalKeys(param1:ASAny) : Array<ASAny>
      {
         var _loc2_= new Array<ASAny>();
         var _loc3_= firstEqualNode(param1);
         if(_loc3_ == null)
         {
            return _loc2_;
         }
         while(_loc3_ != null)
         {
            if(_comparator.compare(param1,_loc3_.item) != 0)
            {
               break;
            }
            _loc2_.push(cast(_loc3_, SortedMapNode).key);
            _loc3_ = /*as3commons_collections::*/nextNode_internal(_loc3_);
         }
         return _loc2_;
      }
      
      public function keysToArray() : Array<ASAny>
      {
         var _loc1_= /*as3commons_collections::*/mostLeftNode_internal();
         var _loc2_= new Array<ASAny>();
         while(_loc1_ != null)
         {
            _loc2_.push(cast(_loc1_, SortedMapNode).key);
            _loc1_ = /*as3commons_collections::*/nextNode_internal(_loc1_);
         }
         return _loc2_;
      }
      
      override public function clear() : Bool
      {
         if(_size == 0)
         {
            return false;
         }
         this._keys = new ASDictionary<ASAny,ASAny>();
         this._items = new ASDictionary<ASAny,ASAny>();
         this._stringMap = new ASObject();
         super.clear();
         return true;
      }
      
      public function higherKey(param1:ASAny) : ASAny
      {
         var _loc2_= ASCompat.reinterpretAs(higherNode(param1) , SortedMapNode);
         if(_loc2_ == null)
         {
            return /*undefined*/null;
         }
         return _loc2_.key;
      }
      
      public function add(param1:ASAny, param2:ASAny) : Bool
      {
         if(Std.isOfType(param1 , String))
         {
            if(ASCompat.hasProperty(this._stringMap, param1))
            {
               return false;
            }
         }
         else if(this._keys.exists(param1))
         {
            return false;
         }
         this.addNode(new SortedMapNode(param1,param2));
         return true;
      }
      
      public function hasKey(param1:ASAny) : Bool
      {
         return Std.isOfType(param1 , String) ? ASCompat.hasProperty(this._stringMap, param1) : this._keys.exists(param1);
      }
      
      public function keyIterator() : IIterator
      {
         return new KeyIterator(this);
      }
      
      override public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         var _loc2_:SortedMapNode = null;
         if(Std.isOfType(param1 , String))
         {
            _loc2_ = ASCompat.dynamicAs(this._stringMap[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         else
         {
            _loc2_ = ASCompat.dynamicAs(this._items[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         return new SortedMapIterator(this,_loc2_);
      }
      
      public function replaceFor(param1:ASAny, param2:ASAny) : Bool
      {
         var _loc3_:SortedMapNode = null;
         if(Std.isOfType(param1 , String))
         {
            _loc3_ = ASCompat.dynamicAs(this._stringMap[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         else
         {
            _loc3_ = ASCompat.dynamicAs(this._items[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         if(ASCompat.toBool(_loc3_) && _loc3_.item != param2)
         {
            this.removeNode(_loc3_);
            _loc3_.item = param2;
            this.addNode(_loc3_);
            return true;
         }
         return false;
      }
      
      public function itemFor(param1:ASAny) : ASAny
      {
         var _loc2_:SortedMapNode = null;
         if(Std.isOfType(param1 , String))
         {
            _loc2_ = ASCompat.dynamicAs(this._stringMap[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         else
         {
            _loc2_ = ASCompat.dynamicAs(this._items[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         return _loc2_ != null ? _loc2_.item : /*undefined*/null;
      }
      
      function getNode(param1:ASAny) : SortedMapNode
      {
         if(Std.isOfType(param1 , String))
         {
            return ASCompat.dynamicAs(this._stringMap[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         return ASCompat.dynamicAs(this._items[param1], org.as3commons.collections.framework.core.SortedMapNode);
      }
      
      public function lesserKey(param1:ASAny) : ASAny
      {
         var _loc2_= ASCompat.reinterpretAs(lesserNode(param1) , SortedMapNode);
         if(_loc2_ == null)
         {
            return /*undefined*/null;
         }
         return _loc2_.key;
      }
      
      public function removeKey(param1:ASAny) : ASAny
      {
         var _loc2_:SortedMapNode = null;
         if(Std.isOfType(param1 , String))
         {
            if(!ASCompat.hasProperty(this._stringMap, param1))
            {
               return /*undefined*/null;
            }
            _loc2_ = ASCompat.dynamicAs(this._stringMap[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         else
         {
            if(!this._keys.exists(param1))
            {
               return /*undefined*/null;
            }
            _loc2_ = ASCompat.dynamicAs(this._items[param1], org.as3commons.collections.framework.core.SortedMapNode);
         }
         this.removeNode(_loc2_);
         return _loc2_.item;
      }
      
      override function removeNode(param1:SortedNode) 
      {
         super.removeNode(param1);
         var _loc2_:ASAny = cast(param1, SortedMapNode).key;
         if(Std.isOfType(_loc2_ , String))
         {
            ASCompat.deleteProperty(this._stringMap, _loc2_);
         }
         else
         {
            this._keys.remove(_loc2_);
            this._items.remove(_loc2_);
         }
      }
   }


private class KeyIterator implements IIterator
{
   
   var _next:SortedNode;
   
   var _map:SortedMap;
   
   public function new(param1:SortedMap)
   {
      
      this._map = param1;
      this._next = param1/*as3commons_collections::*/.mostLeftNode_internal();
   }
   
   public function next() : ASAny
   {
      if(this._next == null)
      {
         return /*undefined*/null;
      }
      var _loc1_= this._next;
      this._next = this._map/*as3commons_collections::*/.nextNode_internal(this._next);
      return cast(_loc1_, SortedMapNode).key;
   }
   
   public function hasNext() : Bool
   {
      return this._next != null;
   }
}
