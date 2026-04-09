package pathfinding
;
   import flash.geom.Vector3D;
   
    class AstarGridNode
   {
      
      public static inline final ASTAR_GRID_WIDTH= (50 : UInt);
      
      public static inline final GRID_HALF_WIDTH:Float = 0.5;
      
      public static inline final GRID_HALF_HEIGHT:Float = 0.5;
      
      public static inline final ASTAR_TILE_GRID_SIZE= (18 : UInt);
      
      public static inline final ASTAR_GRID_SIZE= (216 : UInt);
      
      public var Id:UInt = 0;
      
      public var Center:Vector3D;
      
      public var Neighbors:Array<ASAny> = [];
      
      public var Parent:UInt = 0;
      
      public var f:Float = Math.NaN;
      
      public var g:Float = Math.NaN;
      
      public var h:Float = Math.NaN;
      
      public var visited:Int = 0;
      
      public function new(param1:Int)
      {
         
         Id = (param1 : UInt);
         f = 0;
         g = 1;
         h = 0;
         visited = -1;
         Parent = (0 : UInt);
         findNeighbors();
         Center = new Vector3D();
         Center.x = Id % 216 * 50 + 50 / 2;
         Center.y = Std.int(Id / 216) * 50 + 50 / 2;
      }
      
      public function destroy() 
      {
         Neighbors.resize(0);
         Neighbors = null;
         Center = null;
      }
      
      public function findNeighbors() 
      {
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc1_= 0;
         var _loc2_= 0;
         var _loc7_= 0;
         var _loc3_= (Std.int(Id / 216) : UInt);
         var _loc4_= Id % 216;
         _loc5_ = -1;
         while(_loc5_ < 2)
         {
            _loc6_ = -1;
            while(_loc6_ < 2)
            {
               _loc1_ = (_loc3_ + _loc5_ : Int);
               _loc2_ = (_loc4_ + _loc6_ : Int);
               if(_loc1_ >= 0 && _loc2_ >= 0 && _loc1_ < 216 && _loc2_ < 216)
               {
                  _loc7_ = _loc1_ * 216 + _loc2_;
                  if((_loc7_ : UInt) != Id)
                  {
                     Neighbors.push(_loc1_ * 216 + _loc2_);
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
      }
      
      public function costToNeighbor(param1:UInt) : Float
      {
         var _loc2_= (Std.int(Math.abs(Id - param1)) : UInt);
         if(_loc2_ > (216 + 1 : UInt))
         {
            return 999999;
         }
         if(_loc2_ == 1 || _loc2_ == 150)
         {
            return 60;
         }
         return 85;
      }
   }


