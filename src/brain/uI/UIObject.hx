package brain.uI
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.workLoop.DoLater;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   
    class UIObject
   {
      
      static inline final DEFAULT_TOOLTIP_DELAY:Float = 0;
      
      static inline final DEFAULT_TOOLTIP_LAYER= 107;
      
      var mEnabled:Bool = true;
      
      var mFacade:Facade;
      
      var mRoot:MovieClip;
      
      var mTooltip:MovieClip;
      
      var mTooltipLabel:TextField;
      
      var mTooltipPos:Point = new Point();
      
      var mTooltipDelay:Float = 0;
      
      var mTooltipTask:DoLater;
      
      var mTooltipLayer:Float = 107;
      
      var mDontKillMyChildren:Bool = false;
      
      var mIsParentedToStage:Bool = false;
      
      public function new(param1:Facade, param2:MovieClip, param3:Int = 0, param4:Bool = false)
      {
         
         mFacade = param1;
         mRoot = param2;
         if((mRoot : ASAny).hasOwnProperty("tooltip"))
         {
            if(param3 != 0)
            {
               mTooltipLayer = param3;
            }
            this.tooltip = ASCompat.dynamicAs((mRoot : ASAny).tooltip, flash.display.MovieClip);
         }
         try
         {
            ASCompat.setProperty(mRoot, "UIObject", this);
         }
         catch(errObject:Dynamic)
         {
         }
         this.enabled = true;
         mDontKillMyChildren = param4;
         mIsParentedToStage = false;
      }
      
      public static function scaleToFit(param1:DisplayObject, param2:Float) 
      {
         param1.scaleX = param1.scaleY = 1;
         var _loc4_= param1.height > param1.width ? param1.height : param1.width;
         var _loc5_= param2 / _loc4_;
         param1.scaleX = param1.scaleY = _loc5_;
         var _loc3_= param1.getBounds(param1);
         param1.x = -(_loc3_.left + _loc3_.width * 0.5);
         param1.y = -(_loc3_.top + _loc3_.height * 0.5);
      }
      
      public function handleDrop(param1:UIObject) : Bool
      {
         return false;
      }
      
            
      @:isVar public var visible(get,set):Bool;
public function  set_visible(param1:Bool) :Bool      {
         return mRoot.visible = param1;
      }
function  get_visible() : Bool
      {
         return mRoot.visible;
      }
      
            
      @:isVar public var enabled(get,set):Bool;
public function  get_enabled() : Bool
      {
         return mEnabled;
      }
function  set_enabled(param1:Bool) :Bool      {
         mEnabled = param1;
         hideTooltip();
         removeListeners();
         if(mEnabled)
         {
            addListeners();
         }
return param1;
      }
      
      function addListeners() 
      {
         mRoot.addEventListener("rollOver",onRollOver);
         mRoot.addEventListener("rollOut",onRollOut);
      }
      
      function removeListeners() 
      {
         mRoot.removeEventListener("rollOver",onRollOver);
         mRoot.removeEventListener("rollOut",onRollOut);
      }
      
      function onRollOver(param1:MouseEvent) 
      {
         hideTooltip();
         if(mTooltip != null)
         {
            if(mTooltipDelay == 0)
            {
               showTooltip();
            }
            else
            {
               mTooltipTask = mFacade.preRenderWorkManager.doLater(mTooltipDelay,showTooltip);
            }
         }
      }
      
      function onRollOut(param1:MouseEvent) 
      {
         hideTooltip();
      }
      
      public function bringToFront() 
      {
         mRoot.parent.setChildIndex(mRoot,mRoot.parent.numChildren - 1);
      }
      
      public function sendToBack() 
      {
         mRoot.parent.setChildIndex(mRoot,0);
      }
      
      public function detach() 
      {
         if(mRoot.parent != null)
         {
            mRoot.parent.removeChild(mRoot);
         }
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      @:isVar public var tooltipPos(never,set):Point;
public function  set_tooltipPos(param1:Point) :Point      {
         return mTooltipPos = param1;
      }
      
      public function setTooltipToBeParentedToStage() 
      {
         mIsParentedToStage = true;
      }
      
            
      @:isVar public var tooltip(get,set):MovieClip;
public function  get_tooltip() : MovieClip
      {
         return mTooltip;
      }
      
      @:isVar public var tooltipLabel(get,never):TextField;
public function  get_tooltipLabel() : TextField
      {
         return mTooltipLabel;
      }
function  set_tooltip(param1:MovieClip) :MovieClip      {
         setTooltip(param1);
return param1;
      }
      
      public function setTooltip(param1:ASAny) 
      {
         hideTooltip();
         if(Std.isOfType(param1 , MovieClip))
         {
            mTooltip = ASCompat.dynamicAs(param1 , MovieClip);
            mTooltipLabel = null;
         }
         else if(Std.isOfType(param1 , TextField))
         {
            mTooltip = new MovieClip();
            mTooltipLabel = ASCompat.dynamicAs(param1 , TextField);
            mTooltip.addChild(mTooltipLabel);
         }
         else if(Std.isOfType(param1 , String))
         {
            mTooltip = new MovieClip();
            mTooltipLabel = new TextField();
            mTooltipLabel.text = ASCompat.asString(param1 );
            mTooltipLabel.autoSize = "center";
            mTooltipLabel.background = true;
            mTooltipLabel.backgroundColor = (0 : UInt);
            mTooltipLabel.textColor = (16777215 : UInt);
            mTooltip.addChild(mTooltipLabel);
         }
         else if(param1 == null)
         {
            if(mTooltip != null && mTooltip.parent != null)
            {
               mTooltip.parent.removeChild(mTooltip);
            }
            if(mTooltipLabel != null && mTooltipLabel.parent != null)
            {
               mTooltipLabel.parent.removeChild(mTooltipLabel);
            }
            mTooltipLabel = null;
            mTooltip = null;
         }
         else
         {
            Logger.error("invalid tooltip type: " + Std.string(param1));
         }
         if(mTooltip != null)
         {
            mTooltip.mouseChildren = false;
            mTooltip.mouseEnabled = false;
            this.tooltipPos = new Point(mTooltip.x,mTooltip.y);
            if(mTooltip.parent != null)
            {
               mTooltip.parent.removeChild(mTooltip);
            }
         }
      }
      
      @:isVar public var tooltipDelay(never,set):Float;
public function  set_tooltipDelay(param1:Float) :Float      {
         return mTooltipDelay = param1;
      }
      
      function hideTooltip() 
      {
         if(mTooltipTask != null)
         {
            mTooltipTask.destroy();
         }
         if(mTooltip != null && mTooltip.parent != null)
         {
            mTooltip.parent.removeChild(mTooltip);
         }
      }
      
      function showTooltip(param1:GameClock = null) 
      {
         var _loc2_:Point = null;
         if(mTooltip != null)
         {
            if(!mIsParentedToStage)
            {
               _loc2_ = root.localToGlobal(mTooltipPos);
               mTooltip.x = _loc2_.x;
               mTooltip.y = _loc2_.y;
            }
            else
            {
               mTooltip.x = mTooltipPos.x;
               mTooltip.y = mTooltipPos.y;
            }
            mFacade.sceneGraphManager.addChild(mTooltip,Std.int(mTooltipLayer));
         }
      }
      
      @:isVar public var dontKillMyChildren(never,set):Bool;
public function  set_dontKillMyChildren(param1:Bool) :Bool      {
         return mDontKillMyChildren = param1;
      }
      
      public function destroy() 
      {
         if(mRoot != null)
         {
            if((mRoot : ASAny).hasOwnProperty("UIObject"))
            {
               ASCompat.setProperty(mRoot, "UIObject", null);
            }
            hideTooltip();
            removeListeners();
            if(!mDontKillMyChildren)
            {
               while(mRoot.numChildren > 0)
               {
                  mRoot.removeChildAt(0);
               }
            }
            mRoot = null;
            mFacade = null;
         }
      }
      
      public function setRootMovieClipAsBitMap() 
      {
         mRoot.cacheAsBitmap = true;
      }
   }


