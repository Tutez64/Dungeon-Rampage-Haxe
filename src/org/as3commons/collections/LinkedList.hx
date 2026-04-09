package org.as3commons.collections
;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ILinkedList;
   import org.as3commons.collections.framework.core.AbstractLinkedDuplicatesCollection;
   import org.as3commons.collections.framework.core.LinkedListIterator;
   import org.as3commons.collections.framework.core.LinkedNode;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class LinkedList extends AbstractLinkedDuplicatesCollection implements ILinkedList
   {
      
      public function new()
      {
         super();
      }
      
      override public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         return new LinkedListIterator(this);
      }
      
      public function addFirst(param1:ASAny) 
      {
         addNodeFirst(new LinkedNode(param1));
      }
      
      public function addLast(param1:ASAny) 
      {
         addNodeLast(new LinkedNode(param1));
      }
      
      public function add(param1:ASAny) 
      {
         addNodeLast(new LinkedNode(param1));
      }
      
      /*as3commons_collections*/ public function addNodeBefore_internal(param1:LinkedNode, param2:LinkedNode) 
      {
         addNodeBefore(param1,param2);
      }
      
      /*as3commons_collections*/ public function removeNode_internal(param1:LinkedNode) 
      {
         removeNode(param1);
      }
   }


