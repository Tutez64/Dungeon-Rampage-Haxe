package box2D.collision
;
    class B2DynamicTreeNode
   {
      
      public var userData:ASAny;
      
      public var aabb:B2AABB = new B2AABB();
      
      public var parent:B2DynamicTreeNode;
      
      public var child1:B2DynamicTreeNode;
      
      public var child2:B2DynamicTreeNode;
      
      public function new()
      {
         
      }
      
      public function IsLeaf() : Bool
      {
         return this.child1 == null;
      }
   }


