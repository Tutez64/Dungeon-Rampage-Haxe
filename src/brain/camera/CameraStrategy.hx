package brain.camera
;
   import brain.workLoop.WorkComponent;
   
    class CameraStrategy
   {
      
      var mCamera:Camera;
      
      public function new(param1:Camera)
      {
         
         mCamera = param1;
      }
      
      public function destroy() 
      {
         mCamera = null;
         stop();
      }
      
      public function start(param1:WorkComponent) 
      {
         throw new Error("Override this start function in the camera strategy sub-class.");
      }
      
      public function stop() 
      {
         throw new Error("Override this stop function in the camera strategy sub-class.");
      }
   }


