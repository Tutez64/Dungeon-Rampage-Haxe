package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISortOrder;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractSortedCollection implements ISortOrder
   {
      
      var _root:SortedNode;
      
      var _size:UInt = (0 : UInt);
      
      var _comparator:IComparator;
      
      public function new(param1:IComparator)
      {
         
         this._comparator = param1;
      }
      
      function addNode(param1:SortedNode) 
      {
         var _loc3_= 0;
         if(this._root == null)
         {
            this._comparator.compare(param1.item,param1.item);
            this._root = param1;
            ++this._size;
            return;
         }
         var _loc2_= this._root;
         while(_loc2_ != null)
         {
            _loc3_ = this._comparator.compare(param1.item,_loc2_.item);
            if(_loc3_ == 0)
            {
               _loc3_ = param1.order < _loc2_.order ? -1 : 1;
            }
            if(_loc3_ == -1)
            {
               if(_loc2_.left == null)
               {
                  param1.parent = _loc2_;
                  _loc2_.left = param1;
                  _loc2_ = _loc2_.left;
                  break;
               }
               _loc2_ = _loc2_.left;
            }
            else
            {
               if(_loc3_ != 1)
               {
                  return;
               }
               if(_loc2_.right == null)
               {
                  param1.parent = _loc2_;
                  _loc2_.right = param1;
                  _loc2_ = _loc2_.right;
                  break;
               }
               _loc2_ = _loc2_.right;
            }
         }
         while(_loc2_.parent != null)
         {
            if(_loc2_.parent.priority >= _loc2_.priority)
            {
               break;
            }
            this.rotate(_loc2_.parent,_loc2_);
         }
         ++this._size;
      }
      
      public function remove(param1:ASAny) : Bool
      {
         var _loc2_= this.firstEqualNode(param1);
         if(_loc2_ == null)
         {
            return false;
         }
         if(_loc2_.item == param1)
         {
            this.removeNode(_loc2_);
            return true;
         }
         _loc2_ = this/*as3commons_collections::*/.nextNode_internal(_loc2_);
         while(_loc2_ != null)
         {
            if(this._comparator.compare(param1,_loc2_.item) != 0)
            {
               break;
            }
            if(_loc2_.item == param1)
            {
               this.removeNode(_loc2_);
               return true;
            }
            _loc2_ = this/*as3commons_collections::*/.nextNode_internal(_loc2_);
         }
         return false;
      }
      
      function firstEqualNode(param1:ASAny) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_= 0;
         var _loc2_= this._root;
         while(_loc2_ != null)
         {
            _loc4_ = this._comparator.compare(param1,_loc2_.item);
            if(_loc4_ == -1)
            {
               if(_loc3_ != null)
               {
                  return _loc3_;
               }
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.left;
            }
         }
         return _loc3_;
      }
      
      @:isVar public var size(get,never):UInt;
public function  get_size() : UInt
      {
         return this._size;
      }
      
      public function removeLast() : ASAny
      {
         var _loc1_= this/*as3commons_collections::*/.mostRightNode_internal();
         if(_loc1_ == null)
         {
            return /*undefined*/null;
         }
         this.removeNode(_loc1_);
         return _loc1_.item;
      }
      
      public function removeFirst() : ASAny
      {
         var _loc1_= this/*as3commons_collections::*/.mostLeftNode_internal();
         if(_loc1_ == null)
         {
            return /*undefined*/null;
         }
         this.removeNode(_loc1_);
         return _loc1_.item;
      }
      
      public function clear() : Bool
      {
         if(this._size == 0)
         {
            return false;
         }
         this._root = null;
         this._size = (0 : UInt);
         return true;
      }
      
      public function hasEqual(param1:ASAny) : Bool
      {
         var _loc3_= 0;
         var _loc2_= this._root;
         while(_loc2_ != null)
         {
            _loc3_ = this._comparator.compare(param1,_loc2_.item);
            if(_loc3_ == -1)
            {
               _loc2_ = _loc2_.left;
            }
            else
            {
               if(_loc3_ != 1)
               {
                  return true;
               }
               _loc2_ = _loc2_.right;
            }
         }
         return false;
      }
      
      @:isVar public var last(get,never):ASAny;
public function  get_last() : ASAny
      {
         if(this._root == null)
         {
            return /*undefined*/null;
         }
         return this/*as3commons_collections::*/.mostRightNode_internal().item;
      }
      
      /*as3commons_collections*/ public function mostLeftNode_internal(param1:SortedNode = null) : SortedNode
      {
         if(this._root == null)
         {
            return null;
         }
         if(param1 == null)
         {
            param1 = this._root;
         }
         while(param1.left != null)
         {
            param1 = param1.left;
         }
         return param1;
      }
      
      /*as3commons_collections*/ public function mostRightNode_internal(param1:SortedNode = null) : SortedNode
      {
         if(this._root == null)
         {
            return null;
         }
         if(param1 == null)
         {
            param1 = this._root;
         }
         while(param1.right != null)
         {
            param1 = param1.right;
         }
         return param1;
      }
      
      function rotate(param1:SortedNode, param2:SortedNode) 
      {
         var _loc3_= param1.parent;
         var _loc4_= "right";
         var _loc5_= "left";
         if(param2 == param1.left)
         {
            _loc4_ = "left";
            _loc5_ = "right";
         }
         (param1 : ASAny)[_loc4_] = (param2 : ASAny)[_loc5_];
         if(ASCompat.toBool((param2 : ASAny)[_loc5_]))
         {
            cast((param2 : ASAny)[_loc5_], SortedNode).parent = param1;
         }
         param1.parent = param2;
         (param2 : ASAny)[_loc5_] = param1;
         param2.parent = _loc3_;
         if(_loc3_ != null)
         {
            if((_loc3_ : ASAny)[_loc5_] == param1)
            {
               (_loc3_ : ASAny)[_loc5_] = param2;
            }
            else
            {
               (_loc3_ : ASAny)[_loc4_] = param2;
            }
         }
         else
         {
            this._root = param2;
         }
      }
      
      public function has(param1:ASAny) : Bool
      {
         var _loc2_= this.firstEqualNode(param1);
         if(_loc2_ == null)
         {
            return false;
         }
         if(_loc2_.item == param1)
         {
            return true;
         }
         _loc2_ = this/*as3commons_collections::*/.nextNode_internal(_loc2_);
         while(_loc2_ != null)
         {
            if(this._comparator.compare(param1,_loc2_.item) != 0)
            {
               break;
            }
            if(_loc2_.item == param1)
            {
               return true;
            }
            _loc2_ = this/*as3commons_collections::*/.nextNode_internal(_loc2_);
         }
         return false;
      }
      
      /*as3commons_collections*/ public function previousNode_internal(param1:SortedNode) : SortedNode
      {
         var _loc2_:SortedNode = null;
         if(param1.left != null)
         {
            param1 = this/*as3commons_collections::*/.mostRightNode_internal(param1.left);
         }
         else
         {
            _loc2_ = param1.parent;
            while(ASCompat.toBool(_loc2_) && param1 == _loc2_.left)
            {
               param1 = _loc2_;
               _loc2_ = _loc2_.parent;
            }
            param1 = _loc2_;
         }
         return param1;
      }
      
      public function toArray() : Array<ASAny>
      {
         var _loc1_= new Array<ASAny>();
         var _loc2_= this/*as3commons_collections::*/.mostLeftNode_internal();
         while(_loc2_ != null)
         {
            _loc1_.push(_loc2_.item);
            _loc2_ = this/*as3commons_collections::*/.nextNode_internal(_loc2_);
         }
         return _loc1_;
      }
      
      function removeNode(param1:SortedNode) 
      {
         var _loc2_:SortedNode = null;
         while(ASCompat.toBool(param1.left) || ASCompat.toBool(param1.right))
         {
            if(ASCompat.toBool(param1.left) && ASCompat.toBool(param1.right))
            {
               _loc2_ = param1.left.priority < param1.right.priority ? param1.left : param1.right;
            }
            else if(param1.left != null)
            {
               _loc2_ = param1.left;
            }
            else
            {
               if(param1.right == null)
               {
                  break;
               }
               _loc2_ = param1.right;
            }
            this.rotate(param1,_loc2_);
         }
         if(param1.parent != null)
         {
            if(param1.parent.left == param1)
            {
               param1.parent.left = null;
            }
            else
            {
               param1.parent.right = null;
            }
            param1.parent = null;
         }
         else
         {
            this._root = null;
         }
         --this._size;
      }
      
      /*as3commons_collections*/ public function nextNode_internal(param1:SortedNode) : SortedNode
      {
         var _loc2_:SortedNode = null;
         if(param1.right != null)
         {
            param1 = this/*as3commons_collections::*/.mostLeftNode_internal(param1.right);
         }
         else
         {
            _loc2_ = param1.parent;
            while(ASCompat.toBool(_loc2_) && param1 == _loc2_.right)
            {
               param1 = _loc2_;
               _loc2_ = _loc2_.parent;
            }
            param1 = _loc2_;
         }
         return param1;
      }
      
      function lesserNode(param1:ASAny) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_= 0;
         var _loc2_= this._root;
         while(_loc2_ != null)
         {
            _loc4_ = this._comparator.compare(param1,_loc2_.item);
            if(_loc4_ == -1)
            {
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc2_ = _loc2_.left;
            }
         }
         return _loc3_;
      }
      
      public function iterator(param1:ASAny = /*undefined*/null) : IIterator
      {
         return null;
      }
      
      function higherNode(param1:ASAny) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_= 0;
         var _loc2_= this._root;
         while(_loc2_ != null)
         {
            _loc4_ = this._comparator.compare(param1,_loc2_.item);
            if(_loc4_ == -1)
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc2_ = _loc2_.right;
            }
         }
         return _loc3_;
      }
      
      /*as3commons_collections*/ public function removeNode_internal(param1:SortedNode) 
      {
         this.removeNode(param1);
      }
      
      @:isVar public var first(get,never):ASAny;
public function  get_first() : ASAny
      {
         if(this._root == null)
         {
            return /*undefined*/null;
         }
         return this/*as3commons_collections::*/.mostLeftNode_internal().item;
      }
   }


