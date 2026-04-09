package brain.uI
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.render.MovieClipRenderController;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
    class UIButton extends UIObject
   {
      
      static inline final UP= (0 : UInt);
      
      static inline final DOWN= (1 : UInt);
      
      static inline final OVER= (2 : UInt);
      
      static inline final DISABLED= (3 : UInt);
      
      static inline final SELECTED= (4 : UInt);
      
      var mUpState:MovieClip;
      
      var mDownState:MovieClip;
      
      var mOverState:MovieClip;
      
      var mDisabledState:MovieClip;
      
      var mUpRenderer:MovieClipRenderController;
      
      var mDownRenderer:MovieClipRenderController;
      
      var mOverRenderer:MovieClipRenderController;
      
      var mDisabledRenderer:MovieClipRenderController;
      
      var mSelected:Bool = false;
      
      var mSelectedState:MovieClip;
      
      var mSelectedRenderer:MovieClipRenderController;
      
      var mHitArea:MovieClip;
      
      var mLabel:TextField;
      
      var mDraggable:Bool = false;
      
      var mDragged:Bool = false;
      
      var mDragStartParent:DisplayObjectContainer;
      
      var mDragStartPos:Point;
      
      var mStates:Array<ASAny>;
      
      var mRenderers:Array<ASAny>;
      
      var mRolloverFilter:GlowFilter;
      
      var mSelectedFilter:GlowFilter;
      
      var mFiltersBeforeRollover:Array<ASAny>;
      
      var mMouseDown:Bool = false;
      
      var mPressCallback:ASFunction;
      
      var mReleaseCallback:ASFunction;
      
      var mDragReleaseCallback:ASFunction;
      
      var mEnterCallback:ASFunction;
      
      var mPressRollOutCallback:ASFunction;
      
      var mRollOverCallback:ASFunction;
      
      var mRollOutCallback:ASFunction;
      
      var mRollOverCursor:String = "POINT";
      
      var mRollOverCursorKey:UInt = 0;
      
      var mDragBounds:Rectangle;
      
      var mDisableEventPropogation:Bool = false;
      
      public function new(param1:Facade, param2:MovieClip, param3:Int = 0, param4:Bool = true)
      {
         if((param2 : ASAny).hasOwnProperty("theButton"))
         {
            param2 = ASCompat.dynamicAs((param2 : ASAny).theButton, flash.display.MovieClip);
         }
         if((param2 : ASAny).hasOwnProperty("up"))
         {
            mUpState = ASCompat.dynamicAs((param2 : ASAny).up, flash.display.MovieClip);
            mUpState.mouseChildren = false;
            mUpRenderer = new MovieClipRenderController(param1,mUpState);
         }
         if((param2 : ASAny).hasOwnProperty("down"))
         {
            mDownState = ASCompat.dynamicAs((param2 : ASAny).down, flash.display.MovieClip);
            mDownState.mouseChildren = false;
            mDownRenderer = new MovieClipRenderController(param1,mDownState);
         }
         else
         {
            mDownState = mUpState;
            mDownRenderer = mUpRenderer;
         }
         if((param2 : ASAny).hasOwnProperty("over"))
         {
            mOverState = ASCompat.dynamicAs((param2 : ASAny).over, flash.display.MovieClip);
            mOverState.mouseChildren = false;
            mOverRenderer = new MovieClipRenderController(param1,mOverState);
         }
         else
         {
            mOverState = mUpState;
            mOverRenderer = mUpRenderer;
         }
         if((param2 : ASAny).hasOwnProperty("disabled"))
         {
            mDisabledState = ASCompat.dynamicAs((param2 : ASAny).disabled, flash.display.MovieClip);
            mDisabledState.mouseChildren = false;
            mDisabledRenderer = new MovieClipRenderController(param1,mDisabledState);
         }
         else
         {
            mDisabledState = mUpState;
            mDisabledRenderer = mUpRenderer;
         }
         if((param2 : ASAny).hasOwnProperty("selected"))
         {
            mSelectedState = ASCompat.dynamicAs((param2 : ASAny).selected, flash.display.MovieClip);
            mSelectedState.mouseChildren = false;
            mSelectedRenderer = new MovieClipRenderController(param1,mSelectedState);
         }
         else
         {
            mSelectedState = mUpState;
            mSelectedRenderer = mUpRenderer;
         }
         mStates = [mUpState,mDownState,mOverState,mDisabledState,mSelectedState];
         mRenderers = [mUpRenderer,mDownRenderer,mOverRenderer,mDisabledRenderer,mSelectedRenderer];
         if((param2 : ASAny).hasOwnProperty("hit"))
         {
            mHitArea = ASCompat.dynamicAs((param2 : ASAny).hit, flash.display.MovieClip);
            mHitArea.visible = false;
            mHitArea.mouseEnabled = false;
            param2.hitArea = mHitArea;
         }
         if((param2 : ASAny).hasOwnProperty("label"))
         {
            mLabel = ASCompat.dynamicAs((param2 : ASAny).label, flash.text.TextField);
            mLabel.mouseEnabled = false;
         }
         super(param1,param2,param3);
         mFiltersBeforeRollover = [];
         mDisableEventPropogation = param4;
      }
      
      public function allowEventPropogation() 
      {
         mDisableEventPropogation = false;
      }
      
            
      @:isVar public var label(get,set):TextField;
public function  get_label() : TextField
      {
         return mLabel;
      }
function  set_label(param1:TextField) :TextField      {
         mLabel = param1;
         mLabel.mouseEnabled = false;
return param1;
      }
      
      public function flattenLabelToBitmap() 
      {
         var _loc1_= new BitmapData(Std.int(mLabel.width),Std.int(mLabel.height),true,(0 : UInt));
         _loc1_.draw(mLabel);
         var _loc2_= new Bitmap(_loc1_,"auto",true);
         _loc2_.transform.matrix = mLabel.transform.matrix;
         mLabel.parent.addChild(_loc2_);
         mLabel.parent.removeChild(mLabel);
         mLabel = null;
      }
      
            
      @:isVar public var selected(get,set):Bool;
public function  get_selected() : Bool
      {
         return mSelected;
      }
function  set_selected(param1:Bool) :Bool      {
         mSelected = param1;
         if(mSelectedFilter != null)
         {
            mSelectedState.filters = cast(param1 ? [mSelectedFilter] : []);
         }
         this.showState(upState);
return param1;
      }
      
            
      @:isVar public var rolloverFilter(get,set):GlowFilter;
public function  set_rolloverFilter(param1:GlowFilter) :GlowFilter      {
         return mRolloverFilter = param1;
      }
function  get_rolloverFilter() : GlowFilter
      {
         return mRolloverFilter;
      }
      
            
      @:isVar public var selectedFilter(get,set):GlowFilter;
public function  set_selectedFilter(param1:GlowFilter) :GlowFilter      {
         return mSelectedFilter = param1;
      }
function  get_selectedFilter() : GlowFilter
      {
         return mSelectedFilter;
      }
      
      @:isVar public var pressCallback(never,set):ASFunction;
public function  set_pressCallback(param1:ASFunction) :ASFunction      {
         return mPressCallback = param1;
      }
      
      @:isVar public var pressCallbackThis(never,set):ASFunction;
public function  set_pressCallbackThis(param1:ASFunction) :ASFunction      {
         var value= param1;
         var _this= this;
         mPressCallback = function()
         {
            value(_this);
         };
return param1;
      }
      
            
      @:isVar public var releaseCallback(get,set):ASFunction;
public function  set_releaseCallback(param1:ASFunction) :ASFunction      {
         return mReleaseCallback = param1;
      }
      
      @:isVar public var releaseCallbackThis(never,set):ASFunction;
public function  set_releaseCallbackThis(param1:ASFunction) :ASFunction      {
         var value= param1;
         var _this= this;
         mReleaseCallback = function()
         {
            value(_this);
         };
return param1;
      }
function  get_releaseCallback() : ASFunction
      {
         return mReleaseCallback;
      }
      
            
      @:isVar public var dragReleaseCallback(get,set):ASFunction;
public function  set_dragReleaseCallback(param1:ASFunction) :ASFunction      {
         return mDragReleaseCallback = param1;
      }
function  get_dragReleaseCallback() : ASFunction
      {
         return mDragReleaseCallback;
      }
      
      @:isVar public var enterCallback(never,set):ASFunction;
public function  set_enterCallback(param1:ASFunction) :ASFunction      {
         return mEnterCallback = param1;
      }
      
      @:isVar public var pressRollOutCallback(never,set):ASFunction;
public function  set_pressRollOutCallback(param1:ASFunction) :ASFunction      {
         return mPressRollOutCallback = param1;
      }
      
      @:isVar public var rollOverCallback(never,set):ASFunction;
public function  set_rollOverCallback(param1:ASFunction) :ASFunction      {
         return mRollOverCallback = param1;
      }
      
      @:isVar public var rollOutCallback(never,set):ASFunction;
public function  set_rollOutCallback(param1:ASFunction) :ASFunction      {
         return mRollOutCallback = param1;
      }
      
            
      @:isVar public var draggable(get,set):Bool;
public function  get_draggable() : Bool
      {
         return mDraggable;
      }
function  set_draggable(param1:Bool) :Bool      {
         return mDraggable = param1;
      }
      
      @:isVar public var rollOverCursor(never,set):String;
public function  set_rollOverCursor(param1:String) :String      {
         return mRollOverCursor = param1;
      }
      
      public function click() 
      {
         onRelease(new MouseEvent("click"));
      }
      
      override function addListeners() 
      {
         super.addListeners();
         mRoot.addEventListener("mouseDown",onPress);
         mRoot.addEventListener("keyDown",onKey);
      }
      
      function popRollOverMouseCursor() 
      {
         if(ASCompat.stringAsBool(mRollOverCursor) && mRollOverCursorKey > 0)
         {
            mFacade.mouseCursorManager.popMouseCursor(mRollOverCursorKey);
            mRollOverCursorKey = (0 : UInt);
         }
      }
      
      override function removeListeners() 
      {
         super.removeListeners();
         mRoot.removeEventListener("mouseDown",onPress);
         mRoot.removeEventListener("keyDown",onKey);
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
      }
      
      override public function  set_enabled(param1:Bool) :Bool      {
         super.enabled = param1;
         mRoot.buttonMode = mEnabled;
         mRoot.tabEnabled = false;
         showState((ASCompat.toInt(mEnabled ? upState : (3 : UInt)) : UInt));
         mMouseDown = false;
         if(!param1)
         {
            if(mRolloverFilter != null)
            {
               mRoot.filters = cast(mFiltersBeforeRollover);
               mFiltersBeforeRollover = null;
            }
            popRollOverMouseCursor();
         }
return param1;
      }
      
      override public function destroy() 
      {
         popRollOverMouseCursor();
         mStates = null;
         var _loc1_:ASAny;
         final __ax4_iter_146 = mRenderers;
         if (checkNullIteratee(__ax4_iter_146)) for (_tmp_ in __ax4_iter_146)
         {
            _loc1_ = _tmp_;
            if(ASCompat.toBool(_loc1_))
            {
               _loc1_.destroy();
            }
         }
         mRenderers = null;
         mPressCallback = null;
         mReleaseCallback = null;
         mLabel = null;
         mDisabledRenderer = null;
         mDisabledState = null;
         mDownRenderer = null;
         mDownState = null;
         mUpRenderer = null;
         mUpState = null;
         mOverRenderer = null;
         mOverState = null;
         mSelectedRenderer = null;
         mSelectedState = null;
         super.destroy();
      }
      
      function showState(param1:UInt) 
      {
         var _loc3_:ASAny;
         final __ax4_iter_147 = mStates;
         if (checkNullIteratee(__ax4_iter_147)) for (_tmp_ in __ax4_iter_147)
         {
            _loc3_ = _tmp_;
            if(ASCompat.toBool(_loc3_))
            {
               ASCompat.setProperty(_loc3_, "visible", false);
            }
         }
         var _loc2_:ASAny;
         final __ax4_iter_148 = mRenderers;
         if (checkNullIteratee(__ax4_iter_148)) for (_tmp_ in __ax4_iter_148)
         {
            _loc2_ = _tmp_;
            if(ASCompat.toBool(_loc2_))
            {
               _loc2_.stop();
            }
         }
         if(mStates != null && ASCompat.toBool(mStates[(param1 : Int)]))
         {
            ASCompat.setProperty(mStates[(param1 : Int)], "visible", true);
         }
         if(mRenderers != null && ASCompat.toBool(mRenderers[(param1 : Int)]))
         {
            mRenderers[(param1 : Int)].play(0,true);
         }
      }
      
      function onKey(param1:KeyboardEvent) 
      {
         param1.stopImmediatePropagation();
         if(param1.keyCode == 13)
         {
            if(mEnterCallback != null)
            {
               mEnterCallback();
            }
         }
      }
      
      function onPress(param1:MouseEvent) 
      {
         if(mDisableEventPropogation)
         {
            param1.stopImmediatePropagation();
         }
         mRoot.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("mouseLeave",onStageMouseLeave);
         if(mDraggable)
         {
            mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
         }
         mMouseDown = true;
         showState(downState);
         if(mDraggable)
         {
            mDragged = false;
         }
         if(mPressCallback != null)
         {
            mPressCallback();
         }
      }
      
      function onMouseMove(param1:MouseEvent) 
      {
         if(mDraggable)
         {
            mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
            startDrag();
         }
      }
      
      override function showTooltip(param1:GameClock = null) 
      {
         if(mDragged)
         {
            return;
         }
         super.showTooltip(param1);
      }
      
      function startDrag() 
      {
         this.hideTooltip();
         mDragged = true;
         mDragStartPos = new Point(mRoot.x,mRoot.y);
         mDragStartParent = mRoot.parent;
         var _loc1_= mRoot.localToGlobal(new Point(0,0));
         mFacade.sceneGraphManager.addChild(mRoot,75);
         mRoot.x = _loc1_.x;
         mRoot.y = _loc1_.y;
         mRoot.startDrag(false,mDragBounds);
      }
      
      @:isVar public var dragBounds(never,set):Rectangle;
public function  set_dragBounds(param1:Rectangle) :Rectangle      {
         return mDragBounds = param1;
      }
      
      function onMouseUp(param1:MouseEvent) 
      {
         var _loc2_= false;
         var _loc4_:DisplayObject = null;
         var _loc5_:MovieClip = null;
         var _loc3_:DisplayObject = null;
         if(mDisableEventPropogation)
         {
            param1.stopImmediatePropagation();
         }
         if(mRoot == null)
         {
            return;
         }
         if(mDraggable)
         {
            mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
         }
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
         if(!mEnabled || !mMouseDown)
         {
            return;
         }
         if(mDraggable && mDragged)
         {
            mDragged = false;
            _loc2_ = false;
            this.stopDrag();
            _loc4_ = mRoot.dropTarget;
            while(_loc4_ != null)
            {
               _loc5_ = ASCompat.reinterpretAs(_loc4_ , MovieClip);
               if(_loc5_ != null)
               {
                  if(!_loc5_.mouseEnabled)
                  {
                     _loc4_.visible = false;
                     mRoot.startDrag(true);
                     mRoot.stopDrag();
                     _loc4_.visible = true;
                     _loc4_ = mRoot.dropTarget;
                     continue;
                  }
                  if((_loc5_ : ASAny).hasOwnProperty("UIObject"))
                  {
                     if(cast((_loc5_ : ASAny).UIObject, UIObject).handleDrop(this))
                     {
                        _loc2_ = true;
                        break;
                     }
                  }
               }
               _loc4_ = _loc4_.parent;
            }
            if(!_loc2_)
            {
               resetDrag();
            }
            onDragRelease(param1);
         }
         else
         {
            _loc3_ = ASCompat.dynamicAs(param1.target , DisplayObject);
            while(_loc3_ != null)
            {
               if(_loc3_ == mRoot)
               {
                  onRelease(param1);
                  return;
               }
               _loc3_ = _loc3_.parent;
            }
            onReleaseOutside(param1);
         }
      }
      
      function stopDrag() 
      {
         mRoot.stopDrag();
      }
      
      function resetDrag() 
      {
         mDragStartParent.addChild(mRoot);
         this.bringToFront();
         mRoot.x = mDragStartPos.x;
         mRoot.y = mDragStartPos.y;
         mDragStartParent = null;
         mDragStartPos = null;
      }
      
      function onReleaseOutside(param1:MouseEvent) 
      {
         mMouseDown = false;
      }
      
      function onRelease(param1:MouseEvent) 
      {
         mMouseDown = false;
         showState(overState);
         if(mReleaseCallback != null)
         {
            mReleaseCallback();
         }
      }
      
      function onDragRelease(param1:MouseEvent) 
      {
         if(mRoot == null)
         {
            return;
         }
         mMouseDown = false;
         showState(overState);
         if(mDragReleaseCallback != null)
         {
            mDragReleaseCallback();
         }
      }
      
      override function onRollOver(param1:MouseEvent) 
      {
         super.onRollOver(param1);
         if(mMouseDown)
         {
            showState(downState);
         }
         else
         {
            showState(overState);
         }
         if(mRolloverFilter != null)
         {
            mFiltersBeforeRollover = mRoot.filters.slice(0);
            mRoot.filters = cast([mRolloverFilter]);
         }
         if(mRollOverCallback != null)
         {
            mRollOverCallback();
         }
         if(ASCompat.stringAsBool(mRollOverCursor))
         {
            mRollOverCursorKey = mFacade.mouseCursorManager.pushMouseCursor(mRollOverCursor,true);
         }
      }
      
      @:isVar var downState(get,never):UInt;
function  get_downState() : UInt
      {
         return (mSelected ? (4 : UInt) : (1 : UInt) : UInt);
      }
      
      @:isVar var upState(get,never):UInt;
function  get_upState() : UInt
      {
         return (mSelected ? (4 : UInt) : (0 : UInt) : UInt);
      }
      
      @:isVar var overState(get,never):UInt;
function  get_overState() : UInt
      {
         return (mSelected ? (4 : UInt) : (2 : UInt) : UInt);
      }
      
      override function onRollOut(param1:MouseEvent) 
      {
         super.onRollOut(param1);
         showState(upState);
         if(mMouseDown)
         {
            if(mPressRollOutCallback != null)
            {
               mPressRollOutCallback();
            }
         }
         if(mRolloverFilter != null)
         {
            if(mRoot != null)
            {
               mRoot.filters = cast(mFiltersBeforeRollover);
            }
            mFiltersBeforeRollover = null;
         }
         if(mRollOutCallback != null)
         {
            mRollOutCallback();
         }
         popRollOverMouseCursor();
      }
      
      function onStageMouseLeave(param1:Event) 
      {
         hideTooltip();
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
         showState(upState);
      }
   }


