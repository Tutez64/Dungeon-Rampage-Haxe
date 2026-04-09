package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
    class ClipVertex
   {
      
      public var v:B2Vec2 = new B2Vec2();
      
      public var id:B2ContactID = new B2ContactID();
      
      public function new()
      {
         
      }
      
      public function Set(param1:ClipVertex) 
      {
         this.v.SetV(param1.v);
         this.id.Set(param1.id);
      }
   }


