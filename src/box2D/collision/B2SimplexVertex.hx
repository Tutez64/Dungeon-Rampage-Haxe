package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
   /*internal*/ class B2SimplexVertex
   {
      
      public var wA:B2Vec2;
      
      public var wB:B2Vec2;
      
      public var w:B2Vec2;
      
      public var a:Float = Math.NaN;
      
      public var indexA:Int = 0;
      
      public var indexB:Int = 0;
      
      public function new()
      {
         
      }
      
      public function Set(param1:B2SimplexVertex) 
      {
         this.wA.SetV(param1.wA);
         this.wB.SetV(param1.wB);
         this.w.SetV(param1.w);
         this.a = param1.a;
         this.indexA = param1.indexA;
         this.indexB = param1.indexB;
      }
   }


