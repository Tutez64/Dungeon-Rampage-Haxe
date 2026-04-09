package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.framework.ILinkedListIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class LinkedListIterator extends AbstractLinkedCollectionIterator implements ILinkedListIterator
   {
      
      public function new(param1:LinkedList)
      {
         super(param1);
      }
      
      public function addBefore(param1:ASAny) 
      {
         _current = null;
         cast(_collection, LinkedList)/*as3commons_collections::*/.addNodeBefore_internal(_next,new LinkedNode(param1));
      }
      
      @:isVar public var previousItem(get,never):ASAny;
public function  get_previousItem() : ASAny
      {
         return _next != null ? (_next.left != null ? _next.left.item : /*undefined*/null) : (_collection.size != 0 ? _collection/*as3commons_collections::*/.lastNode_internal.item : /*undefined*/null);
      }
      
      public function replace(param1:ASAny) : Bool
      {
         if(_current == null)
         {
            return false;
         }
         if(_current.item == param1)
         {
            return false;
         }
         _current.item = param1;
         return true;
      }
      
      override function removeCurrent() 
      {
         cast(_collection, LinkedList)/*as3commons_collections::*/.removeNode_internal(_current);
      }
      
      public function addAfter(param1:ASAny) 
      {
         _current = null;
         if(_next != null)
         {
            cast(_collection, LinkedList)/*as3commons_collections::*/.addNodeBefore_internal(_next,new LinkedNode(param1));
            _next = _next.left;
         }
         else
         {
            cast(_collection, LinkedList)/*as3commons_collections::*/.addNodeBefore_internal(null,new LinkedNode(param1));
            _next = _collection/*as3commons_collections::*/.lastNode_internal;
         }
      }
      
      @:isVar public var nextItem(get,never):ASAny;
public function  get_nextItem() : ASAny
      {
         return _next != null ? _next.item : /*undefined*/null;
      }
   }


