package box2D.collision
;
   import box2D.common.*;
   import box2D.common.math.*;
   
    class B2DynamicTree
   {
      
      var m_root:B2DynamicTreeNode;
      
      var m_freeList:B2DynamicTreeNode;
      
      var m_path:UInt = 0;
      
      var m_insertionCount:Int = 0;
      
      public function new()
      {
         
         this.m_root = null;
         this.m_freeList = null;
         this.m_path = (0 : UInt);
         this.m_insertionCount = 0;
      }
      
      public function CreateProxy(param1:B2AABB, param2:ASAny) : B2DynamicTreeNode
      {
         var _loc3_:B2DynamicTreeNode = null;
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         _loc3_ = this.AllocateNode();
         _loc4_ = B2Settings.b2_aabbExtension;
         _loc5_ = B2Settings.b2_aabbExtension;
         _loc3_.aabb.lowerBound.x = param1.lowerBound.x - _loc4_;
         _loc3_.aabb.lowerBound.y = param1.lowerBound.y - _loc5_;
         _loc3_.aabb.upperBound.x = param1.upperBound.x + _loc4_;
         _loc3_.aabb.upperBound.y = param1.upperBound.y + _loc5_;
         _loc3_.userData = param2;
         this.InsertLeaf(_loc3_);
         return _loc3_;
      }
      
      public function DestroyProxy(param1:B2DynamicTreeNode) 
      {
         this.RemoveLeaf(param1);
         this.FreeNode(param1);
      }
      
      public function MoveProxy(param1:B2DynamicTreeNode, param2:B2AABB, param3:B2Vec2) : Bool
      {
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         B2Settings.b2Assert(param1.IsLeaf());
         if(param1.aabb.Contains(param2))
         {
            return false;
         }
         this.RemoveLeaf(param1);
         _loc4_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (param3.x > 0 ? param3.x : -param3.x);
         _loc5_ = B2Settings.b2_aabbExtension + B2Settings.b2_aabbMultiplier * (param3.y > 0 ? param3.y : -param3.y);
         param1.aabb.lowerBound.x = param2.lowerBound.x - _loc4_;
         param1.aabb.lowerBound.y = param2.lowerBound.y - _loc5_;
         param1.aabb.upperBound.x = param2.upperBound.x + _loc4_;
         param1.aabb.upperBound.y = param2.upperBound.y + _loc5_;
         this.InsertLeaf(param1);
         return true;
      }
      
      public function Rebalance(param1:Int) 
      {
         var _loc3_:B2DynamicTreeNode = null;
         var _loc4_= (0 : UInt);
         if(this.m_root == null)
         {
            return;
         }
         var _loc2_= 0;
         while(_loc2_ < param1)
         {
            _loc3_ = this.m_root;
            _loc4_ = (0 : UInt);
            while(_loc3_.IsLeaf() == false)
            {
               _loc3_ = ((this.m_path : Int) >> (_loc4_ : Int) & 1) != 0 ? _loc3_.child2 : _loc3_.child1;
               _loc4_ = ((_loc4_ + 1 : Int) & 0x1F : UInt);
            }
            ++this.m_path;
            this.RemoveLeaf(_loc3_);
            this.InsertLeaf(_loc3_);
            _loc2_++;
         }
      }
      
      public function GetFatAABB(param1:B2DynamicTreeNode) : B2AABB
      {
         return param1.aabb;
      }
      
      public function GetUserData(param1:B2DynamicTreeNode) : ASAny
      {
         return param1.userData;
      }
      
      public function Query(param1:ASFunction, param2:B2AABB) 
      {
         var _loc8_:Int;
         var _loc9_:Int;
         var _loc5_:B2DynamicTreeNode = null;
         var _loc6_= false;
         if(this.m_root == null)
         {
            return;
         }
         var _loc3_= new Vector<B2DynamicTreeNode>();
         var _loc4_= 0;
         var _loc7_:Int;
         _loc3_[ASCompat.toInt(_loc7_ = _loc4_++)] = this.m_root;
         while(_loc4_ > 0)
         {
            _loc5_ = _loc3_[--_loc4_];
            if(_loc5_.aabb.TestOverlap(param2))
            {
               if(_loc5_.IsLeaf())
               {
                  _loc6_ = ASCompat.toBool(param1(_loc5_));
                  if(!_loc6_)
                  {
                     return;
                  }
               }
               else
               {
                  _loc3_[ASCompat.toInt(_loc8_ = _loc4_++)] = _loc5_.child1;
                  _loc3_[ASCompat.toInt(_loc9_ = _loc4_++)] = _loc5_.child2;
               }
            }
         }
      }
      
      public function RayCast(param1:ASFunction, param2:B2RayCastInput) 
      {
         var _loc20_:Int;
         var _loc21_:Int;
         var _loc3_:B2Vec2 = null;
         var _loc9_:B2AABB = null;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc14_:B2DynamicTreeNode = null;
         var _loc15_:B2Vec2 = null;
         var _loc16_:B2Vec2 = null;
         var _loc17_= Math.NaN;
         var _loc18_:B2RayCastInput = null;
         if(this.m_root == null)
         {
            return;
         }
         _loc3_ = param2.p1;
         var _loc4_= param2.p2;
         var _loc5_= B2Math.SubtractVV(_loc3_,_loc4_);
         _loc5_.Normalize();
         var _loc6_= B2Math.CrossFV(1,_loc5_);
         var _loc7_= B2Math.AbsV(_loc6_);
         var _loc8_= param2.maxFraction;
         _loc9_ = new B2AABB();
         _loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
         _loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
         _loc9_.lowerBound.x = Math.min(_loc3_.x,_loc10_);
         _loc9_.lowerBound.y = Math.min(_loc3_.y,_loc11_);
         _loc9_.upperBound.x = Math.max(_loc3_.x,_loc10_);
         _loc9_.upperBound.y = Math.max(_loc3_.y,_loc11_);
         var _loc12_= new Vector<B2DynamicTreeNode>();
         var _loc13_= 0;
         var _loc19_:Int;
         _loc12_[ASCompat.toInt(_loc19_ = _loc13_++)] = this.m_root;
         while(_loc13_ > 0)
         {
            _loc14_ = _loc12_[--_loc13_];
            if(_loc14_.aabb.TestOverlap(_loc9_) != false)
            {
               _loc15_ = _loc14_.aabb.GetCenter();
               _loc16_ = _loc14_.aabb.GetExtents();
               _loc17_ = Math.abs(_loc6_.x * (_loc3_.x - _loc15_.x) + _loc6_.y * (_loc3_.y - _loc15_.y)) - _loc7_.x * _loc16_.x - _loc7_.y * _loc16_.y;
               if(_loc17_ <= 0)
               {
                  if(_loc14_.IsLeaf())
                  {
                     _loc18_ = new B2RayCastInput();
                     _loc18_.p1 = param2.p1;
                     _loc18_.p2 = param2.p2;
                     _loc18_.maxFraction = param2.maxFraction;
                     _loc8_ = ASCompat.toNumber(param1(_loc18_,_loc14_));
                     if(_loc8_ == 0)
                     {
                        return;
                     }
                     _loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
                     _loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
                     _loc9_.lowerBound.x = Math.min(_loc3_.x,_loc10_);
                     _loc9_.lowerBound.y = Math.min(_loc3_.y,_loc11_);
                     _loc9_.upperBound.x = Math.max(_loc3_.x,_loc10_);
                     _loc9_.upperBound.y = Math.max(_loc3_.y,_loc11_);
                  }
                  else
                  {
                     _loc12_[ASCompat.toInt(_loc20_ = _loc13_++)] = _loc14_.child1;
                     _loc12_[ASCompat.toInt(_loc21_ = _loc13_++)] = _loc14_.child2;
                  }
               }
            }
         }
      }
      
      function AllocateNode() : B2DynamicTreeNode
      {
         var _loc1_:B2DynamicTreeNode = null;
         if(this.m_freeList != null)
         {
            _loc1_ = this.m_freeList;
            this.m_freeList = _loc1_.parent;
            _loc1_.parent = null;
            _loc1_.child1 = null;
            _loc1_.child2 = null;
            return _loc1_;
         }
         return new B2DynamicTreeNode();
      }
      
      function FreeNode(param1:B2DynamicTreeNode) 
      {
         param1.parent = this.m_freeList;
         this.m_freeList = param1;
      }
      
      function InsertLeaf(param1:B2DynamicTreeNode) 
      {
         var _loc6_:B2DynamicTreeNode = null;
         var _loc7_:B2DynamicTreeNode = null;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         ++this.m_insertionCount;
         if(this.m_root == null)
         {
            this.m_root = param1;
            this.m_root.parent = null;
            return;
         }
         var _loc2_= param1.aabb.GetCenter();
         var _loc3_= this.m_root;
         if(_loc3_.IsLeaf() == false)
         {
            do
            {
               _loc6_ = _loc3_.child1;
               _loc7_ = _loc3_.child2;
               _loc8_ = Math.abs((_loc6_.aabb.lowerBound.x + _loc6_.aabb.upperBound.x) / 2 - _loc2_.x) + Math.abs((_loc6_.aabb.lowerBound.y + _loc6_.aabb.upperBound.y) / 2 - _loc2_.y);
               _loc9_ = Math.abs((_loc7_.aabb.lowerBound.x + _loc7_.aabb.upperBound.x) / 2 - _loc2_.x) + Math.abs((_loc7_.aabb.lowerBound.y + _loc7_.aabb.upperBound.y) / 2 - _loc2_.y);
               if(_loc8_ < _loc9_)
               {
                  _loc3_ = _loc6_;
               }
               else
               {
                  _loc3_ = _loc7_;
               }
            }
            while(_loc3_.IsLeaf() == false);
            
         }
         var _loc4_= _loc3_.parent;
         var _loc5_= this.AllocateNode();
         _loc5_.parent = _loc4_;
         _loc5_.userData = null;
         _loc5_.aabb._Combine(param1.aabb,_loc3_.aabb);
         if(_loc4_ != null)
         {
            if(_loc3_.parent.child1 == _loc3_)
            {
               _loc4_.child1 = _loc5_;
            }
            else
            {
               _loc4_.child2 = _loc5_;
            }
            _loc5_.child1 = _loc3_;
            _loc5_.child2 = param1;
            _loc3_.parent = _loc5_;
            param1.parent = _loc5_;
            while(!_loc4_.aabb.Contains(_loc5_.aabb))
            {
               _loc4_.aabb._Combine(_loc4_.child1.aabb,_loc4_.child2.aabb);
               _loc5_ = _loc4_;
               _loc4_ = _loc4_.parent;
               if(_loc4_ == null)
               {
                  break;
               }
            }
         }
         else
         {
            _loc5_.child1 = _loc3_;
            _loc5_.child2 = param1;
            _loc3_.parent = _loc5_;
            param1.parent = _loc5_;
            this.m_root = _loc5_;
         }
      }
      
      function RemoveLeaf(param1:B2DynamicTreeNode) 
      {
         var _loc4_:B2DynamicTreeNode = null;
         var _loc5_:B2AABB = null;
         if(param1 == this.m_root)
         {
            this.m_root = null;
            return;
         }
         var _loc2_= param1.parent;
         var _loc3_= _loc2_.parent;
         if(_loc2_.child1 == param1)
         {
            _loc4_ = _loc2_.child2;
         }
         else
         {
            _loc4_ = _loc2_.child1;
         }
         if(_loc3_ != null)
         {
            if(_loc3_.child1 == _loc2_)
            {
               _loc3_.child1 = _loc4_;
            }
            else
            {
               _loc3_.child2 = _loc4_;
            }
            _loc4_.parent = _loc3_;
            this.FreeNode(_loc2_);
            while(_loc3_ != null)
            {
               _loc5_ = _loc3_.aabb;
               _loc3_.aabb = B2AABB.Combine(_loc3_.child1.aabb,_loc3_.child2.aabb);
               if(_loc5_.Contains(_loc3_.aabb))
               {
                  break;
               }
               _loc3_ = _loc3_.parent;
            }
         }
         else
         {
            this.m_root = _loc4_;
            _loc4_.parent = null;
            this.FreeNode(_loc2_);
         }
      }
   }


