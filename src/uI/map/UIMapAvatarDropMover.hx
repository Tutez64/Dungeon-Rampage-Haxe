package uI.map
;
    class UIMapAvatarDropMover implements UIMapAvatarMover
   {
      
      var mUpdatePosition:ASFunction;
      
      public function new(param1:ASFunction)
      {
         
         mUpdatePosition = param1;
      }
      
      public function moveTo(param1:Float, param2:Float) 
      {
         mUpdatePosition(param1,param2);
      }
      
      public function destroy() 
      {
      }
   }


