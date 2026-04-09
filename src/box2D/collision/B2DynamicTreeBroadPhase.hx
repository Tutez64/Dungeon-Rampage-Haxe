package box2D.collision
;
   import box2D.common.math.*;
   
    class B2DynamicTreeBroadPhase implements IBroadPhase
   {
      
      var m_tree:B2DynamicTree = new B2DynamicTree();
      
      var m_proxyCount:Int = 0;
      
      var m_moveBuffer:Vector<B2DynamicTreeNode> = new Vector();
      
      var m_pairBuffer:Vector<B2DynamicTreePair> = new Vector();
      
      var m_pairCount:Int = 0;
      
      public function new()
      {
         
      }
      
      public function CreateProxy(param1:B2AABB, param2:ASAny) : ASAny
      {
         var _loc3_= this.m_tree.CreateProxy(param1,param2);
         ++this.m_proxyCount;
         this.BufferMove(_loc3_);
         return _loc3_;
      }
      
      public function DestroyProxy(param1:ASAny) 
      {
         this.UnBufferMove(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
         --this.m_proxyCount;
         this.m_tree.DestroyProxy(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
      }
      
      public function MoveProxy(param1:ASAny, param2:B2AABB, param3:B2Vec2) 
      {
         var _loc4_= this.m_tree.MoveProxy(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode),param2,param3);
         if(_loc4_)
         {
            this.BufferMove(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
         }
      }
      
      public function TestOverlap(param1:ASAny, param2:ASAny) : Bool
      {
         var _loc3_= this.m_tree.GetFatAABB(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
         var _loc4_= this.m_tree.GetFatAABB(ASCompat.dynamicAs(param2, box2D.collision.B2DynamicTreeNode));
         return _loc3_.TestOverlap(_loc4_);
      }
      
      public function GetUserData(param1:ASAny) : ASAny
      {
         return this.m_tree.GetUserData(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
      }
      
      public function GetFatAABB(param1:ASAny) : B2AABB
      {
         return this.m_tree.GetFatAABB(ASCompat.dynamicAs(param1, box2D.collision.B2DynamicTreeNode));
      }
      
      public function GetProxyCount() : Int
      {
         return this.m_proxyCount;
      }
      
      public function UpdatePairs(param1:ASFunction) 
      {
         var QueryCallback:ASFunction;
         var queryProxy:B2DynamicTreeNode = null;
         var i= 0;
         var fatAABB:B2AABB = null;
         var primaryPair:B2DynamicTreePair = null;
         var userDataA:ASAny = /*undefined*/null;
         var userDataB:ASAny = /*undefined*/null;
         var pair:B2DynamicTreePair = null;
         var callback= param1;
         this.m_pairCount = 0;
         final __ax4_iter_78 = this.m_moveBuffer;
         if (checkNullIteratee(__ax4_iter_78)) for (_tmp_ in __ax4_iter_78)
         {
            queryProxy  = _tmp_;
            QueryCallback = function(param1:B2DynamicTreeNode):Bool
            {
               if(param1 == queryProxy)
               {
                  return true;
               }
               if(m_pairCount == m_pairBuffer.length)
               {
                  m_pairBuffer[m_pairCount] = new B2DynamicTreePair();
               }
               var _loc2_= m_pairBuffer[m_pairCount];
               _loc2_.proxyA = Reflect.compare(param1 , queryProxy)< 0 ? param1 : queryProxy;
               _loc2_.proxyB = Reflect.compare(param1 , queryProxy)>= 0 ? param1 : queryProxy;
               ++m_pairCount;
               return true;
            };
            fatAABB = this.m_tree.GetFatAABB(queryProxy);
            this.m_tree.Query(QueryCallback,fatAABB);
         }
         this.m_moveBuffer.length = 0;
         i = 0;
         while(i < this.m_pairCount)
         {
            primaryPair = this.m_pairBuffer[i];
            userDataA = this.m_tree.GetUserData(primaryPair.proxyA);
            userDataB = this.m_tree.GetUserData(primaryPair.proxyB);
            callback(userDataA,userDataB);
            i++;
            while(i < this.m_pairCount)
            {
               pair = this.m_pairBuffer[i];
               if(pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB)
               {
                  break;
               }
               i++;
            }
         }
      }
      
      public function Query(param1:ASFunction, param2:B2AABB) 
      {
         this.m_tree.Query(param1,param2);
      }
      
      public function RayCast(param1:ASFunction, param2:B2RayCastInput) 
      {
         this.m_tree.RayCast(param1,param2);
      }
      
      public function Validate() 
      {
      }
      
      public function Rebalance(param1:Int) 
      {
         this.m_tree.Rebalance(param1);
      }
      
      function BufferMove(param1:B2DynamicTreeNode) 
      {
         this.m_moveBuffer[this.m_moveBuffer.length] = param1;
      }
      
      function UnBufferMove(param1:B2DynamicTreeNode) 
      {
         var _loc2_= this.m_moveBuffer.indexOf(param1);
         this.m_moveBuffer.splice(_loc2_,(1 : UInt));
      }
      
      function ComparePairs(param1:B2DynamicTreePair, param2:B2DynamicTreePair) : Int
      {
         return 0;
      }
   }


