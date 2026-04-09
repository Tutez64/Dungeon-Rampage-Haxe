package box2D.dynamics
;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactFilter
   {
      
      /*b2internal*/ public static var b2_defaultFilter:B2ContactFilter = new B2ContactFilter();
      
      public function new()
      {
         
      }
      
      public function ShouldCollide(param1:B2Fixture, param2:B2Fixture) : Bool
      {
         var _loc3_= param1.GetFilterData();
         var _loc4_= param2.GetFilterData();
         if(_loc3_.groupIndex == _loc4_.groupIndex && _loc3_.groupIndex != 0)
         {
            return _loc3_.groupIndex > 0;
         }
         return ((_loc3_.maskBits : Int) & (_loc4_.categoryBits : Int)) != 0 && ((_loc3_.categoryBits : Int) & (_loc4_.maskBits : Int)) != 0;
      }
      
      public function RayCollide(param1:ASAny, param2:B2Fixture) : Bool
      {
         if(!ASCompat.toBool(param1))
         {
            return true;
         }
         return this.ShouldCollide(ASCompat.dynamicAs(param1 , B2Fixture),param2);
      }
   }


