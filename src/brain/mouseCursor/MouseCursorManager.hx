package brain.mouseCursor
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import org.as3commons.collections.Map;

import flash.display.MovieClip;
   
    class MouseCursorManager
   {
      
      var mCursorTypes:Map;
      
      var mCurrentCursor:String;
      
      var mIsTransient:Bool = false;
      
      var mCursorClip:MovieClip;
      
      var mCursorStack:Array<ASAny>;
      
      var mFacade:Facade;
      
      var mNextKey:UInt = 0;
      
      var mDisabled:Bool = false;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
         mCursorTypes = new Map();
         mNextKey = (1 : UInt);
         mIsTransient = false;
         mDisabled = false;
         mCursorStack = [];
         registerBuiltInTypes();
         setMouseCursor("auto");
      }
      
      @:isVar public var disable(never,set):Bool;
public function  set_disable(param1:Bool) :Bool      {
         mDisabled = param1;
         if(mDisabled)
         {
            if(mCursorClip != null)
            {
               mFacade.stageRef.removeEventListener("mouseOver",onMouseOver);
               mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
               mFacade.stageRef.removeEventListener("mouseOut",onMouseOut);
               mFacade.sceneGraphManager.removeChild(mCursorClip);
            }
            setBuiltInCursor("auto");
         }
return param1;
      }
      
      function registerBuiltInTypes() 
      {
         var _loc1_= new CursorType(null,true);
         mCursorTypes.add("arrow",_loc1_);
         mCursorTypes.add("auto",_loc1_);
         mCursorTypes.add("button",_loc1_);
         mCursorTypes.add("hand",_loc1_);
         mCursorTypes.add("ibeam",_loc1_);
      }
      
      public function registerMouseCursor(param1:MovieClip, param2:String, param3:Bool = false) 
      {
         var _loc4_:CursorType = null;
         if(param1 == null)
         {
            Logger.error("Trying to register a mouse cursor with a null MovieClip.");
            return;
         }
         param1.mouseChildren = false;
         param1.mouseEnabled = false;
         if(mCursorTypes.hasKey(param2))
         {
            if(!param3)
            {
               return;
            }
            _loc4_ = ASCompat.dynamicAs(mCursorTypes.itemFor(param2), CursorType);
            _loc4_.isBuiltIn = false;
            _loc4_.root = param1;
            if(param2 == mCurrentCursor)
            {
               setMouseCursor(param2);
            }
         }
         else
         {
            _loc4_ = new CursorType(param1,false);
            mCursorTypes.add(param2,_loc4_);
         }
      }
      
      function onMouseMove(param1:MouseEvent) 
      {
         mCursorClip.x = param1.stageX;
         mCursorClip.y = param1.stageY;
         param1.updateAfterEvent();
      }
      
      function onMouseOver(param1:MouseEvent) 
      {
         if(mCursorClip != null)
         {
            mCursorClip.visible = true;
            mFacade.stageRef.removeEventListener("mouseOver",onMouseOver);
         }
      }
      
      function onMouseOut(param1:MouseEvent) 
      {
         if(mCursorClip != null && mCursorClip.visible)
         {
            mCursorClip.visible = false;
            mFacade.stageRef.addEventListener("mouseOver",onMouseOver);
            mFacade.stageRef.removeEventListener("mouseOut",onMouseOut);
         }
      }
      
      function setBuiltInCursor(param1:String) 
      {
         Mouse.show();
         Mouse.cursor = param1;
         mCursorClip = null;
      }
      
      function setCustomCursor(param1:CursorType) 
      {
         Mouse.hide();
         mCursorClip = param1.root;
         mCursorClip.visible = true;
         mCursorClip.mouseChildren = false;
         mCursorClip.mouseEnabled = false;
         mFacade.sceneGraphManager.addChild(mCursorClip,200);
         param1.root.x = param1.root.stage.mouseX;
         param1.root.y = param1.root.stage.mouseY;
         mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
         mFacade.stageRef.addEventListener("mouseOut",onMouseOut);
      }
      
      public function pushMouseCursor(param1:String, param2:Bool = false) : UInt
      {
         return (0 : UInt);
      }
      
      public function popMouseCursor(param1:UInt = (0 : UInt)) 
      {
      }
      
      public function setMouseCursor(param1:String) 
      {
         var _loc2_:ASAny = null;
      }
   }


private class CursorType
{
   
   public var isBuiltIn:Bool = false;
   
   public var root:MovieClip;
   
   public function new(param1:MovieClip, param2:Bool)
   {
      
      root = param1;
      isBuiltIn = param2;
   }
}
