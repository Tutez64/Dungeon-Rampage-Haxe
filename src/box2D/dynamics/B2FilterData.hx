package box2D.dynamics
;
    class B2FilterData
   {
      
      public var categoryBits:UInt = (1 : UInt);
      
      public var maskBits:UInt = (65535 : UInt);
      
      public var groupIndex:Int = 0;
      
      public function new()
      {
         
      }
      
      public function Copy() : B2FilterData
      {
         var _loc1_= new B2FilterData();
         _loc1_.categoryBits = this.categoryBits;
         _loc1_.maskBits = this.maskBits;
         _loc1_.groupIndex = this.groupIndex;
         return _loc1_;
      }
   }


