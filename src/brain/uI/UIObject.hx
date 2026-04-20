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
      
      static inline final NAVIGATION_UP= "UP";
      
      static inline final NAVIGATION_DOWN= "DOWN";
      
      static inline final NAVIGATION_LEFT= "LEFT";
      
      static inline final NAVIGATION_RIGHT= "RIGHT";
      
      static inline final NAVIGATION_SELECTED= "SELECTED";
      
      static inline final NAVIGATION_SET_TO_UNSELECTED= "SET_TO_UNSELECTED";
      
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
      
      var mNavigationDictionary:ASDictionary<ASAny,ASAny> = new ASDictionary(true);
      
      var mNavigationAdditionalInteraction:ASDictionary<ASAny,ASAny> = new ASDictionary(true);
      
      var mIsFocused:Bool = false;
      
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
      
      public function setFocused(param1:Bool) 
      {
         if(mIsFocused != param1)
         {
            mIsFocused = param1;
            if(mIsFocused)
            {
               onFocused();
            }
            else
            {
               onUnfocused();
            }
         }
      }
      
      function onFocused() 
      {
         onRollOver(null);
      }
      
      function onUnfocused() 
      {
         onRollOut(null);
      }
      
      public function onSelected() 
      {
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
               mTooltipTask = mFacade.preRenderWorkManager.doLater(mTooltipDelay,showTooltip,false,"UIObject.tooltip");
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
            mNavigationDictionary = null;
            mRoot = null;
            mFacade = null;
         }
      }
      
      public function canBeFocused() : Bool
      {
         return enabled && visible;
      }
      
      public function isFocused() : Bool
      {
         return mIsFocused;
      }
      
      public function setRootMovieClipAsBitMap() 
      {
         mRoot.cacheAsBitmap = true;
      }
      
      public function isToTheLeftOf(param1:UIObject) 
      {
         this.rightNavigation = param1;
         param1.leftNavigation = this;
      }
      
      public function isAbove(param1:UIObject) 
      {
         this.downNavigation = param1;
         param1.upNavigation = this;
      }
      
            
      @:isVar public var leftNavigation(get,set):UIObject;
public function  get_leftNavigation() : UIObject
      {
         return ASCompat.dynamicAs(mNavigationDictionary["LEFT"], UIObject);
      }
      
            
      @:isVar public var rightNavigation(get,set):UIObject;
public function  get_rightNavigation() : UIObject
      {
         return ASCompat.dynamicAs(mNavigationDictionary["RIGHT"], UIObject);
      }
      
            
      @:isVar public var upNavigation(get,set):UIObject;
public function  get_upNavigation() : UIObject
      {
         return ASCompat.dynamicAs(mNavigationDictionary["UP"], UIObject);
      }
      
            
      @:isVar public var downNavigation(get,set):UIObject;
public function  get_downNavigation() : UIObject
      {
         return ASCompat.dynamicAs(mNavigationDictionary["DOWN"], UIObject);
      }
function  set_leftNavigation(param1:UIObject) :UIObject      {
         if(mNavigationDictionary["LEFT"] == param1)
         {
            Logger.warnch("UI","Navigation left already set to same target on: " + this.mRoot.name);
            return param1;
         }
         if(ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "LEFT"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate left towards: " + Std.string(mNavigationDictionary["LEFT"].mRoot.name));
         }
         mNavigationDictionary["LEFT"] = param1;
return param1;
      }
function  set_rightNavigation(param1:UIObject) :UIObject      {
         if(mNavigationDictionary["RIGHT"] == param1)
         {
            Logger.warnch("UI","Navigation right already set to same target on: " + this.mRoot.name);
            return param1;
         }
         if(ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "RIGHT"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate right towards: " + Std.string(mNavigationDictionary["RIGHT"].mRoot.name));
         }
         mNavigationDictionary["RIGHT"] = param1;
return param1;
      }
function  set_upNavigation(param1:UIObject) :UIObject      {
         if(mNavigationDictionary["UP"] == param1)
         {
            Logger.warnch("UI","Navigation up already set to same target on: " + this.mRoot.name);
            return param1;
         }
         if(ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "UP"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate up towards: " + Std.string(mNavigationDictionary["UP"].mRoot.name));
         }
         mNavigationDictionary["UP"] = param1;
return param1;
      }
function  set_downNavigation(param1:UIObject) :UIObject      {
         if(mNavigationDictionary["DOWN"] == param1)
         {
            Logger.warnch("UI","Navigation down already set to same target on: " + this.mRoot.name);
            return param1;
         }
         if(ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "DOWN"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate down towards: " + Std.string(mNavigationDictionary["DOWN"].mRoot.name));
         }
         mNavigationDictionary["DOWN"] = param1;
return param1;
      }
      
      public function clearLeftNavigation() 
      {
         mNavigationDictionary["LEFT"] = null;
      }
      
      public function clearRightNavigation() 
      {
         mNavigationDictionary["RIGHT"] = null;
      }
      
      public function clearUpNavigation() 
      {
         mNavigationDictionary["UP"] = null;
      }
      
      public function clearDownNavigation() 
      {
         mNavigationDictionary["DOWN"] = null;
      }
      
      public function clearNavigationAndInteractions() 
      {
         mNavigationDictionary["LEFT"] = null;
         mNavigationDictionary["RIGHT"] = null;
         mNavigationDictionary["UP"] = null;
         mNavigationDictionary["DOWN"] = null;
         mNavigationAdditionalInteraction["LEFT"] = null;
         mNavigationAdditionalInteraction["RIGHT"] = null;
         mNavigationAdditionalInteraction["UP"] = null;
         mNavigationAdditionalInteraction["DOWN"] = null;
         mNavigationAdditionalInteraction["SELECTED"] = null;
         mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = null;
      }
      
            
      @:isVar public var leftNavigationAdditionalInteraction(get,set):ASFunction;
public function  get_leftNavigationAdditionalInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["LEFT"]);
      }
      
            
      @:isVar public var rightNavigationAdditionalInteraction(get,set):ASFunction;
public function  get_rightNavigationAdditionalInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["RIGHT"]);
      }
      
            
      @:isVar public var upNavigationAdditionalInteraction(get,set):ASFunction;
public function  get_upNavigationAdditionalInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["UP"]);
      }
      
            
      @:isVar public var downNavigationAdditionalInteraction(get,set):ASFunction;
public function  get_downNavigationAdditionalInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["DOWN"]);
      }
      
            
      @:isVar public var navigationSelectedInteraction(get,set):ASFunction;
public function  get_navigationSelectedInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["SELECTED"]);
      }
      
            
      @:isVar public var navigationSetToUnselectedInteraction(get,set):ASFunction;
public function  get_navigationSetToUnselectedInteraction() : ASFunction
      {
         return ASCompat.asFunction(mNavigationAdditionalInteraction["SET_TO_UNSELECTED"]);
      }
function  set_leftNavigationAdditionalInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "LEFT"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + Std.string(mNavigationAdditionalInteraction["LEFT"].mRoot.name));
         }
         mNavigationAdditionalInteraction["LEFT"] = param1;
return param1;
      }
function  set_rightNavigationAdditionalInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "RIGHT"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + Std.string(mNavigationAdditionalInteraction["RIGHT"].mRoot.name));
         }
         mNavigationAdditionalInteraction["RIGHT"] = param1;
return param1;
      }
function  set_upNavigationAdditionalInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "UP"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + Std.string(mNavigationAdditionalInteraction["UP"].mRoot.name));
         }
         mNavigationAdditionalInteraction["UP"] = param1;
return param1;
      }
function  set_downNavigationAdditionalInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "DOWN"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction: " + Std.string(mNavigationAdditionalInteraction["DOWN"].mRoot.name));
         }
         mNavigationAdditionalInteraction["DOWN"] = param1;
return param1;
      }
function  set_navigationSelectedInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "SELECTED"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has a selected interaction: " + Std.string(mNavigationAdditionalInteraction["SELECTED"].mRoot.name));
         }
         mNavigationAdditionalInteraction["SELECTED"] = param1;
return param1;
      }
function  set_navigationSetToUnselectedInteraction(param1:ASFunction) :ASFunction      {
         if(ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "SET_TO_UNSELECTED"))
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an unselected interaction: " + Std.string(mNavigationAdditionalInteraction["SET_TO_UNSELECTED"].mRoot.name));
         }
         mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = param1;
return param1;
      }
   }


