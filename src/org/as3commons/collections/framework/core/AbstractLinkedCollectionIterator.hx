package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.ICollectionIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractLinkedCollectionIterator implements ICollectionIterator
   {
      
      var _next:LinkedNode;
      
      var _current:LinkedNode;
      
      var _collection:AbstractLinkedCollection;
      
      public function new(param1:AbstractLinkedCollection)
      {
         
         this._collection = param1;
         if(param1.size != 0)
         {
            this._next = this._collection/*as3commons_collections::*/.firstNode_internal;
         }
      }
      
      public function start() 
      {
         this._next = ASCompat.dynamicAs(this._collection.size != 0 ? this._collection/*as3commons_collections::*/.firstNode_internal : null, org.as3commons.collections.framework.core.LinkedNode);
         this._current = null;
      }
      
      public function remove() : Bool
      {
         if(this._current == null)
         {
            return false;
         }
         this._next = this._current.right;
         this.removeCurrent();
         this._current = null;
         return true;
      }
      
      public function hasNext() : Bool
      {
         return this._next != null;
      }
      
      function removeCurrent() 
      {
      }
      
      public function hasPrevious() : Bool
      {
         return this._next != this._collection/*as3commons_collections::*/.firstNode_internal && ASCompat.toBool(this._collection.size);
      }
      
      public function next() : ASAny
      {
         if(this._next == null)
         {
            this._current = null;
            return /*undefined*/null;
         }
         this._current = this._next;
         this._next = this._next.right;
         return this._current.item;
      }
      
      public function previous() : ASAny
      {
         if(this._next == this._collection/*as3commons_collections::*/.firstNode_internal || this._collection.size == 0)
         {
            this._current = null;
            return /*undefined*/null;
         }
         this._next = this._next == null ? this._collection/*as3commons_collections::*/.lastNode_internal : this._next.left;
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


