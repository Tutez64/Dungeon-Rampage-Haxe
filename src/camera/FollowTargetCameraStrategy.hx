package camera
;
   import brain.camera.Camera;
   import brain.camera.CameraStrategy;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.workLoop.Task;
   import brain.workLoop.WorkComponent;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
    class FollowTargetCameraStrategy extends CameraStrategy
   {
      
      var mFacade:Facade;
      
      var mTarget:Sprite;
      
      var mUpdateTask:Task;
      
      var mCameraVel:Vector3D = new Vector3D();
      
      var mForce:Float = 4;
      
      var mMaxSpeed:Float = 20.833333333333332;
      
      public function new(param1:Camera, param2:Sprite)
      {
         mTarget = param2;
         super(param1);
      }
      
      override public function destroy() 
      {
         stop();
         super.destroy();
         mTarget = null;
         mFacade = null;
      }
      
      override public function start(param1:WorkComponent) 
      {
         if(mUpdateTask != null)
         {
            mUpdateTask.destroy();
         }
         mUpdateTask = param1.doEveryFrame(update);
      }
      
      override public function stop() 
      {
         if(mUpdateTask != null)
         {
            mUpdateTask.destroy();
            mUpdateTask = null;
         }
      }
      
      function update(param1:GameClock) 
      {
         mCameraVel = mCamera.getDeltaToPoint(mTarget.x,mTarget.y);
         if(mCameraVel.lengthSquared > 0.5)
         {
            mCamera.translateBy(mCameraVel.x,mCameraVel.y);
         }
         mCamera.update(param1);
      }
      
      public function changeTarget(param1:Sprite) 
      {
         mTarget = param1;
      }
   }


