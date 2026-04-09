package brain.uI
;
   import brain.facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
    class UIScrollPane extends UIObject
   {
      
      var mSlider:UISlider;
      
      var mMouseWheelDeltaMultiplier:Float = Math.NaN;
      
      var mMouseFlickDeltaMultiplier:Float = Math.NaN;
      
      var mParentContainer:MovieClip;
      
      var mFlickMouseDown:Bool = false;
      
      var mFlickMousePoint:Point;
      
      public function new(param1:Facade, param2:MovieClip, param3:Int = 0)
      {
         super(param1,param2,param3);
         var _loc4_= new Rectangle(0,0,param2.width,param2.height);
         param2.scrollRect = _loc4_;
         mFlickMousePoint = new Point();
      }
      
      public function scrollTo(param1:Float, param2:Float) 
      {
         var _loc3_= root.scrollRect;
         _loc3_.x = param1;
         _loc3_.y = param2;
         root.scrollRect = _loc3_;
      }
      
      public function scrollBy(param1:Float, param2:Float) 
      {
         var _loc3_= root.scrollRect;
         _loc3_.x += param1;
         _loc3_.y += param2;
         root.scrollRect = _loc3_;
      }
      
      public function scrollByX(param1:Float) 
      {
         this.scrollBy(param1,0);
      }
      
      public function scrollByY(param1:Float) 
      {
         this.scrollBy(0,param1);
      }
      
      public function scrollToX(param1:Float) 
      {
         this.scrollTo(param1,root.scrollRect.y);
      }
      
      public function scrollToY(param1:Float) 
      {
         this.scrollTo(root.scrollRect.x,param1);
      }
      
      public function addMouseWheelFunctionality(param1:UISlider, param2:Float = 20, param3:MovieClip = null) 
      {
         mParentContainer = param3;
         mSlider = param1;
         mMouseWheelDeltaMultiplier = param2;
         if(param3 == null)
         {
            mRoot.addEventListener("mouseWheel",onMouseWheel);
         }
         else
         {
            mParentContainer.addEventListener("mouseWheel",onMouseWheel);
         }
      }
      
      public function onMouseWheel(param1:MouseEvent) 
      {
         mSlider.valueWithCallback = mSlider.value - param1.delta * mMouseWheelDeltaMultiplier;
      }
      
      public function addMouseFlickFunctionality(param1:UISlider, param2:Float = 20, param3:MovieClip = null) 
      {
         mParentContainer = param3;
         mSlider = param1;
         mMouseFlickDeltaMultiplier = param2;
         if(param3 == null)
         {
            mRoot.addEventListener("mouseDown",onMouseDown);
            mRoot.addEventListener("mouseMove",onMouseMove);
            mRoot.addEventListener("mouseUp",onMouseUp);
         }
         else
         {
            mParentContainer.addEventListener("mouseDown",onMouseDown);
            mParentContainer.addEventListener("mouseMove",onMouseMove);
            mParentContainer.addEventListener("mouseUp",onMouseUp);
         }
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
      }
      
      public function onMouseDown(param1:MouseEvent) 
      {
         mFlickMousePoint.x = param1.stageX;
         mFlickMousePoint.y = param1.stageY;
         mFlickMouseDown = true;
      }
      
      public function onMouseMove(param1:MouseEvent) 
      {
         var _loc2_= Math.NaN;
         if(mFlickMouseDown && mSlider != null)
         {
            _loc2_ = 0;
            if(mSlider.orientation == 0)
            {
               _loc2_ = param1.stageX - mFlickMousePoint.x;
            }
            else if(mSlider.orientation == 1)
            {
               _loc2_ = param1.stageY - mFlickMousePoint.y;
            }
            mSlider.valueWithCallback = mSlider.value - _loc2_ * mMouseFlickDeltaMultiplier;
            mFlickMousePoint.x = param1.stageX;
            mFlickMousePoint.y = param1.stageY;
         }
      }
      
      public function onMouseUp(param1:MouseEvent) 
      {
         mFlickMouseDown = false;
      }
      
      override public function destroy() 
      {
         if(mSlider != null)
         {
            if(mParentContainer == null)
            {
               mRoot.removeEventListener("mouseWheel",onMouseWheel);
               mRoot.removeEventListener("mouseDown",onMouseDown);
               mRoot.removeEventListener("mouseMove",onMouseMove);
               mRoot.removeEventListener("mouseUp",onMouseUp);
            }
            else
            {
               mParentContainer.removeEventListener("mouseWheel",onMouseWheel);
               mParentContainer.removeEventListener("mouseDown",onMouseDown);
               mParentContainer.removeEventListener("mouseMove",onMouseMove);
               mParentContainer.removeEventListener("mouseUp",onMouseUp);
            }
            mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         }
         mSlider = null;
         mParentContainer = null;
         super.destroy();
      }
   }


