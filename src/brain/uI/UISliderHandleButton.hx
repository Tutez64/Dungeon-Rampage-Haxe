package brain.uI
;
   import brain.facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
    class UISliderHandleButton extends UIButton
   {
      
      var mSliderWidth:Float = Math.NaN;
      
      var mSliderHeight:Float = Math.NaN;
      
      var mOrientation:UInt = 0;
      
      var mSlideCallback:ASFunction;
      
      public function new(param1:Facade, param2:MovieClip, param3:UInt, param4:Float, param5:Float)
      {
         super(param1,param2);
         mOrientation = param3;
         mSliderWidth = param4;
         mSliderHeight = param5;
      }
      
      override public function destroy() 
      {
         mSlideCallback = null;
         super.destroy();
      }
      
      @:isVar public var slideCallback(never,set):ASFunction;
public function  set_slideCallback(param1:ASFunction) :ASFunction      {
         return mSlideCallback = param1;
      }
      
      override function onPress(param1:MouseEvent) 
      {
         super.onPress(param1);
         if(mOrientation == 0)
         {
            mRoot.startDrag(false,new Rectangle(0,0,mSliderWidth,0));
         }
         else
         {
            mRoot.startDrag(false,new Rectangle(0,0,0,mSliderHeight));
         }
         mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
      }
      
      override function onRelease(param1:MouseEvent) 
      {
         super.onRelease(param1);
         mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
      }
      
      override function onMouseUp(param1:MouseEvent) 
      {
         super.onMouseUp(param1);
         mRoot.stopDrag();
         mSlideCallback();
      }
      
      override function onMouseMove(param1:MouseEvent) 
      {
         if(mSlideCallback != null)
         {
            mSlideCallback();
         }
         super.onMouseMove(param1);
      }
   }


