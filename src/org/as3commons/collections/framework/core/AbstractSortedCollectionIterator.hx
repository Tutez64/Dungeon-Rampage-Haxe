package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.ICollectionIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractSortedCollectionIterator implements ICollectionIterator
   {
      
      var _next:SortedNode;
      
      var _current:SortedNode;
      
      var _collection:AbstractSortedCollection;
      
      public function new(param1:AbstractSortedCollection, param2:SortedNode = null)
      {
         
         this._collection = param1;
         if(param2 != null)
         {
            this._next = param2;
         }
         else if(param1.size != 0)
         {
            this._next = this._collection/*as3commons_collections::*/.mostLeftNode_internal();
         }
      }
      
      public function start() 
      {
         this._next = ASCompat.dynamicAs(this._collection.size != 0 ? this._collection/*as3commons_collections::*/.mostLeftNode_internal() : null, org.as3commons.collections.framework.core.SortedNode);
         this._current = null;
      }
      
      public function remove() : Bool
      {
         if(this._current == null)
         {
            return false;
         }
         this._next = this._collection/*as3commons_collections::*/.nextNode_internal(this._current);
         this._collection/*as3commons_collections::*/.removeNode_internal(this._current);
         this._current = null;
         return true;
      }
      
      public function hasNext() : Bool
      {
         return this._next != null;
      }
      
      public function hasPrevious() : Bool
      {
         return this._next != this._collection/*as3commons_collections::*/.mostLeftNode_internal() && ASCompat.toBool(this._collection.size);
      }
      
      public function next() : ASAny
      {
         if(this._next == null)
         {
            this._current = null;
            return /*undefined*/null;
         }
         this._current = this._next;
         this._next = this._collection/*as3commons_collections::*/.nextNode_internal(this._next);
         return this._current.item;
      }
      
      public function previous() : ASAny
      {
         if(this._next == this._collection/*as3commons_collections::*/.mostLeftNode_internal() || this._collection.size == 0)
         {
            this._current = null;
            return /*undefined*/null;
         }
         this._next = this._next == null ? this._collection/*as3commons_collections::*/.mostRightNode_internal() : this._collection/*as3commons_collections::*/.previousNode_internal(this._next);
         this._current = this._next;
         return this._current.item;
      }
      
      @:isVar public var current(get,never):ASAny;
public function  get_current() : ASAny
      {
         if(this._current == null)
         {
            return /*undefined*/null;
         }
         return this._current.item;
      }
      
      public function end() 
      {
         this._next = this._current = null;
      }
   }


