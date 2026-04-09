package brain.utils
;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
    class MathUtil
   {
      
      static var spare:Float = Math.NaN;
      
      static var spareReady:Bool = false;
      
      public function new()
      {
         
      }
      
      public static function rand(param1:Float, param2:Float) : Float
      {
         return param1 + (param2 - param1) * Math.random();
      }
      
      public static function rad2deg(param1:Float) : Float
      {
         return param1 * 180 / 3.141592653589793;
      }
      
      public static function deg2rad(param1:Float) : Float
      {
         return param1 * 3.141592653589793 / 180;
      }
      
      public static function degreesBetweenPoints(param1:Point, param2:Point) : Float
      {
         return Math.atan2(param2.y - param1.y,param2.x - param1.x) * 180 / 3.141592653589793;
      }
      
      public static function degreesToFaceObject(param1:DisplayObject, param2:DisplayObject) : Float
      {
         return Math.atan2(param2.y - param1.y,param2.x - param1.x) * 180 / 3.141592653589793;
      }
      
      public static function getGaussian(param1:Float, param2:Float) : Float
      {
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc3_= Math.NaN;
         if(spareReady)
         {
            spareReady = false;
            return spare * param2 + param1;
         }
         do
         {
            _loc4_ = Math.random() * 2 - 1;
            _loc5_ = Math.random() * 2 - 1;
            _loc3_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
         }
         while(_loc3_ >= 1 || _loc3_ == 0);
         
         spare = _loc5_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
         spareReady = true;
         return param1 + param2 * _loc4_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
      }
   }


