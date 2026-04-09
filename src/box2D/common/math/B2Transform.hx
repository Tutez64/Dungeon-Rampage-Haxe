package box2D.common.math
;
    class B2Transform
   {
      
      public var position:B2Vec2 = new B2Vec2();
      
      public var R:B2Mat22 = new B2Mat22();
      
      public function new(param1:B2Vec2 = null, param2:B2Mat22 = null)
      {
         
         if(param1 != null)
         {
            this.position.SetV(param1);
            this.R.SetM(param2);
         }
      }
      
      public function Initialize(param1:B2Vec2, param2:B2Mat22) 
      {
         this.position.SetV(param1);
         this.R.SetM(param2);
      }
      
      public function SetIdentity() 
      {
         this.position.SetZero();
         this.R.SetIdentity();
      }
      
      public function Set(param1:B2Transform) 
      {
         this.position.SetV(param1.position);
         this.R.SetM(param1.R);
      }
      
      public function GetAngle() : Float
      {
         return Math.atan2(this.R.col1.y,this.R.col1.x);
      }
   }


