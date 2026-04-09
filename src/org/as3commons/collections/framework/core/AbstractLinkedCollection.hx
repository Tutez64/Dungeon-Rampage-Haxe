package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IInsertionOrder;
   import org.as3commons.collections.framework.IIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractLinkedCollection implements IInsertionOrder
   {
      
      var _size:UInt = (0 : UInt);
      
      var _first:LinkedNode;
      
      var _last:LinkedNode;
      
      public function new()
      {
         
      }
      
      @:isVar public var size(get,never):UInt;
public function  get_size() : UInt
      {
         return this._size;
      }
      
      public function reverse() : Bool
      {
         var _loc2_:LinkedNode = null;
         var _loc3_:LinkedNode = null;
         if(this._size < 2)
         {
            return false;
         }
         var _loc1_= this._last;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_.left;
            if(_loc1_.right == null)
            {
               _loc1_.right = _loc1_.left;
               _loc1_.left = null;
               this._first = _loc1_;
            }
            else if(_loc1_.left == null)
            {
               _loc1_.left = _loc1_.right;
               _loc1_.right = null;
               this._last = _loc1_;
            }
            else
            {
               _loc3_ = _loc1_.right;
               _loc1_.right = _loc1_.left;
               _loc1_.left = _loc3_;
            }
            _loc1_ = _loc2_;
         }
         return true;
      }
      
      function mergeSort(param1:IComparator) 
      {
         var _loc3_:LinkedNode = null;
         var _loc4_:LinkedNode = null;
         var _loc5_:LinkedNode = null;
         var _loc6_:LinkedNode = null;
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc10_= 0;
         var _loc11_= 0;
         var _loc2_= this._first;
         var _loc7_= 1;
         while(true)
         {
            _loc3_ = _loc2_;
            _loc2_ = _loc6_ = null;
            _loc8_ = 0;
            while(_loc3_ != null)
            {
               _loc8_++;
               _loc11_ = 0;
               _loc9_ = 0;
               _loc4_ = _loc3_;
               while(_loc11_ < _loc7_)
               {
                  _loc9_++;
                  _loc4_ = _loc4_.right;
                  if(_loc4_ == null)
                  {
                     break;
                  }
                  _loc11_++;
               }
               _loc10_ = _loc7_;
               while(_loc9_ > 0 || _loc10_ > 0 && _loc4_ != null)
               {
                  if(_loc9_ == 0)
                  {
                     _loc5_ = _loc4_;
                     _loc4_ = _loc4_.right;
                     _loc10_--;
                  }
                  else if(_loc10_ == 0 || _loc4_ == null)
                  {
                     _loc5_ = _loc3_;
                     _loc3_ = _loc3_.right;
                     _loc9_--;
                  }
                  else if(param1.compare(_loc3_.item,_loc4_.item) <= 0)
                  {
                     _loc5_ = _loc3_;
                     _loc3_ = _loc3_.right;
                     _loc9_--;
                  }
                  else
                  {
                     _loc5_ = _loc4_;
                     _loc4_ = _loc4_.right;
                     _loc10_--;
                  }
                  if(_loc6_ != null)
                  {
                     _loc6_.right = _loc5_;
                  }
                  else
                  {
                     _loc2_ = _loc5_;
                  }
                  _loc5_.left = _loc6_;
                  _loc6_ = _loc5_;
               }
               _loc3_ = _loc4_;
            }
            this._first.left = _loc6_;
            _loc6_.right = null;
            if(_loc8_ <= 1)
            {
               break;
            }
            _loc7_ = ASCompat.toInt(_loc7_) << 1;
         }
         this._first = _loc2_;
         this._last = _loc6_;
      }
      
      /*as3commons_collections*/ @:isVar public var firstNode_internal(get,never):LinkedNode;
public function  get_firstNode_internal() : LinkedNode
      {
         return this._first;
      }
      
      public function remove(param1:ASAny) : Bool
      {
         var _loc2_= this.firstNodeOf(param1);
         if(_loc2_ == null)
         {
            return false;
         }
         this.removeNode(_loc2_);
         return true;
      }
      
      public function removeFirst() : ASAny
      {
         if(this._size == 0)
         {
            return /*undefined*/null;
         }
         var _loc1_:ASAny = this._first.item;
         this._first = this._first.right;
         if(this._first != null)
         {
            this._first.left = null;
         }
         else
         {
            this._last = null;
         }
         --this._size;
         return _loc1_;
      }
      
      public function clear() : Bool
      {
         if(this._size == 0)
         {
            return false;
         }
         this._first = this._last = null;
         this._size = (0 : UInt);
         return true;
      }
      
      function addNodeBefore(param1:LinkedNode, param2:LinkedNode) 
      {
         if(param1 == null)
         {
            this.addNodeLast(param2);
            return;
         }
         if(param1.left == null)
         {
            this._first = param2;
         }
         param2.left = param1.left;
         param2.right = param1;
         if(param1.left != null)
         {
            param1.left.right = param2;
         }
         param1.left = param2;
         ++this._size;
      }
      
      function firstNodeOf(param1:ASAny) : LinkedNode
      {
         var _loc2_= this._first;
         while(_loc2_ != null)
         {
            if(param1 == _loc2_.item)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_.right;
         }
         return null;
      }
      
      @:isVar public var last(get,never):ASAny;
public function  get_last() : ASAny
      {
         if(this._last != null)
         {
            return this._last.item;
         }
         return /*undefined*/null;
      }
      
      function addNodeAfter(param1:LinkedNode, param2:LinkedNode) 
      {
         if(param1 == null)
         {
            this.addNodeFirst(param2);
            return;
         }
         if(param1.right == null)
         {
            this._last = param2;
         }
         param2.left = param1;
         param2.right = param1.right;
         if(param1.right != null)
         {
            param1.right.left = param2;
         }
         param1.right = param2;
         ++this._size;
      }
      
      public function sort(param1:IComparator) : Bool
      {
         if(this._size < 2)
         {
            return false;
         }
         this.mergeSort(param1);
         return true;
      }
      
      public function has(param1:ASAny) : Bool
      {
         return this.firstNodeOf(param1) != null;
      }
      
      /*as3commons_collections*/ @:isVar public var lastNode_internal(get,never):LinkedNode;
public function  get_lastNode_internal() : LinkedNode
      {
         return this._last;
      }
      
      function removeNode(param1:LinkedNode) 
      {
         if(param1.left != null)
         {
            param1.left.right = param1.right;
         }
         else
         {
            this._first = param1.right;
         }
         if(param1.right != null)
         {
            param1.right.left = param1.left;
         }
         else
         {
            this._last = param1.left;
         }
         --this._size;
      }
      
      public function toArray() : Array<ASAny>
      {
         var _loc1_= this._first;
         var _loc2_= new Array<ASAny>();
         while(_loc1_ != null)
         {
            _loc2_.push(_loc1_.item);
            _loc1_ = _loc1_.right;
         }
         return _loc2_;
      }
      
      public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         return null;
      }
      
      @:isVar public var first(get,never):ASAny;
public function  get_first() : ASAny
      {
         if(this._first != null)
         {
            return this._first.item;
         }
         return /*undefined*/null;
      }
      
      function addNodeFirst(param1:LinkedNode) 
      {
         if(this._first == null)
         {
            this._first = this._last = param1;
            this._size = (1 : UInt);
            return;
         }
         this._first.left = param1;
         param1.right = this._first;
         this._first = param1;
         ++this._size;
      }
      
      function addNodeLast(param1:LinkedNode) 
      {
         if(this._first == null)
         {
            this._first = this._last = param1;
            this._size = (1 : UInt);
            return;
         }
         this._last.right = param1;
         param1.left = this._last;
         this._last = param1;
         ++this._size;
      }
      
      public function removeLast() : ASAny
      {
         if(this._size == 0)
         {
            return /*undefined*/null;
         }
         var _loc1_:ASAny = this._last.item;
         this._last = this._last.left;
         if(this._last != null)
         {
            this._last.right = null;
         }
         else
         {
            this._first = null;
         }
         --this._size;
         return _loc1_;
      }
   }


