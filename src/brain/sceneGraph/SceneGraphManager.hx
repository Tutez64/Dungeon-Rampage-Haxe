package brain.sceneGraph
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.render.Layer;
   import brain.render.LayerGroup;
   import brain.render.SortOnAddLayer;
   import brain.render.SortedLayer;
   import brain.utils.MemoryTracker;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class SceneGraphManager
   {
      
      public static var BOTTOM_HEIGHT:Float = 160;
      
      public static inline final GROUND= 5;
      
      public static inline final BACKGROUND= 10;
      
      public static inline final SORTED= 20;
      
      public static inline final FOREGROUND= 30;
      
      public static inline final COLLISION= 40;
      
      public static inline final GAMEFADE= 42;
      
      public static inline final OVERFADE= 46;
      
      public static inline final UI= 50;
      
      public static inline final UITopCenterBackGround= 51;
      
      public static inline final UI1= 53;
      
      public static inline final UI2= 52;
      
      public static inline final UI3= 54;
      
      public static inline final UI4= 55;
      
      public static inline final UI5= 56;
      
      public static inline final UI6= 57;
      
      public static inline final UI7= 59;
      
      public static inline final UI8= 58;
      
      public static inline final UI9= 60;
      
      public static inline final UI10= 63;
      
      public static inline final UI11= 61;
      
      public static inline final UI12= 62;
      
      public static inline final GROUNDDRAGDROP= 70;
      
      public static inline final DRAGANDDROP= 75;
      
      public static inline final FADE= 100;
      
      public static inline final UIPopUpCurtainLayer= 104;
      
      public static inline final POPUP= 105;
      
      public static inline final UICenterPopup= 106;
      
      public static inline final TOOLTIP= 107;
      
      public static inline final UI7T= 162;
      
      public static inline final UI9T= 163;
      
      public static inline final CURSOR= 200;
      
      var mFacade:Facade;
      
      var mWorldLayerGroup:LayerGroup;
      
      var mUILayerGroup:LayerGroup;
      
      var mUILayerGroupT:LayerGroup;
      
      var mGroundLayer:Layer;
      
      var mGroundDragDropLayerd:Layer;
      
      var mBackgroundLayer:Layer;
      
      var mSortedLayer:SortedLayer;
      
      var mForegroundLayer:Layer;
      
      var mCollisionLayer:Layer;
      
      var mGameFadeLayer:Layer;
      
      var mOverFadeLayer:Layer;
      
      var mUILayer:Layer;
      
      var mUILayerT:Layer;
      
      var mUITopCenterBackGround:Layer;
      
      var mUI1:Layer;
      
      var mUI2:Layer;
      
      var mUI3:Layer;
      
      var mUI4:Layer;
      
      var mUI5:Layer;
      
      var mUI6:Layer;
      
      var mUI7:Layer;
      
      var mUI8:Layer;
      
      var mUI9:Layer;
      
      var mUI10:Layer;
      
      var mUI11:Layer;
      
      var mUI12:Layer;
      
      var mUICenterPopup:Layer;
      
      var mUI7T:Layer;
      
      var mUI9T:Layer;
      
      var mDragAndDropLayer:Layer;
      
      var mTooltipLayer:Layer;
      
      var mUIPopUpCurtainLayer:Layer;
      
      var mPopupLayer:Layer;
      
      var mFadeLayer:Layer;
      
      public var mCursorLayer:Layer;
      
      var mLayers:Map = new Map();
      
      var mCurtainReferenceCount:UInt = (0 : UInt);
      
      var mPopupCurtain:Sprite;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
         mWorldLayerGroup = new LayerGroup();
         mWorldLayerGroup.name = "SceneGraphManager.worldLayerGroup";
         mFacade.addRootDisplayObject(mWorldLayerGroup);
         mGroundLayer = this.createLayer((5 : UInt),mWorldLayerGroup,"GroundLayer");
         mBackgroundLayer = this.createSortOnAddLayer((10 : UInt),mWorldLayerGroup,"BackgroundLayer");
         mSortedLayer = this.createSortedLayer((20 : UInt),mWorldLayerGroup,"SortedLayer");
         mForegroundLayer = this.createLayer((30 : UInt),mWorldLayerGroup,"ForegroundLayer");
         mCollisionLayer = this.createLayer((40 : UInt),mWorldLayerGroup,"CollisionLayer");
         mGameFadeLayer = this.createLayer((42 : UInt),mWorldLayerGroup,"GameFadeLayer");
         mOverFadeLayer = this.createLayer((46 : UInt),mWorldLayerGroup,"OverFadeLayer");
         mFacade.layerRenderWorkManager.doEveryFrame(mWorldLayerGroup.onFrame,"SceneGraphManager.WorldLayerGroup");
         mUILayerGroup = new LayerGroup();
         mUILayerGroup.name = "SceneGraphManager.UILayerGroup";
         mFacade.addRootDisplayObject(mUILayerGroup);
         mUILayerGroupT = new LayerGroup();
         mUILayerGroupT.name = "SceneGraphManager.UILayerGroupT";
         mFacade.addRootDisplayObject(mUILayerGroupT);
         mUILayer = this.createLayer((50 : UInt),mUILayerGroup,"UILayer");
         mUITopCenterBackGround = this.createLayer((51 : UInt),mUILayerGroup,"TopCenterBackGround");
         mUI1 = this.createLayer((53 : UInt),mUILayerGroup,"UI1");
         mUI2 = this.createLayer((52 : UInt),mUILayerGroup,"UI2");
         mUI3 = this.createLayer((54 : UInt),mUILayerGroup,"UI3");
         mUI4 = this.createLayer((55 : UInt),mUILayerGroup,"UI4");
         mUI5 = this.createLayer((56 : UInt),mUILayerGroup,"UI5");
         mUI6 = this.createLayer((57 : UInt),mUILayerGroup,"UI6");
         mUI7 = this.createLayer((59 : UInt),mUILayerGroup,"UI7");
         mUI8 = this.createLayer((58 : UInt),mUILayerGroup,"UI8");
         mUI9 = this.createLayer((60 : UInt),mUILayerGroup,"UI9");
         mUI10 = this.createLayer((63 : UInt),mUILayerGroup,"UI10");
         mUI11 = this.createLayer((61 : UInt),mUILayerGroup,"UI11");
         mUI12 = this.createLayer((62 : UInt),mUILayerGroup,"UI12");
         mUIPopUpCurtainLayer = this.createLayer((104 : UInt),mUILayerGroup,"UIPopUpCurtainLayer");
         mUICenterPopup = this.createLayer((106 : UInt),mUILayerGroup,"UICenterPopup");
         mGroundDragDropLayerd = this.createLayer((70 : UInt),mWorldLayerGroup,"GroundLayer2");
         mDragAndDropLayer = this.createLayer((75 : UInt),mUILayerGroup,"DragAndDropLayer");
         mTooltipLayer = this.createLayer((107 : UInt),mUILayerGroup,"TooltipLayer");
         mPopupLayer = this.createLayer((105 : UInt),mUILayerGroup,"PopupLayer");
         mFadeLayer = this.createLayer((100 : UInt),mUILayerGroup,"FadeLayer");
         mUI7T = this.createLayer((162 : UInt),mUILayerGroupT,"UI7T");
         mUI9T = this.createLayer((163 : UInt),mUILayerGroupT,"UI9T");
         mCursorLayer = this.createLayer((200 : UInt),mUILayerGroup,"CursorLayer");
         mFacade.layerRenderWorkManager.doEveryFrame(mUILayerGroup.onFrame,"SceneGraphManager.UILayerGroup");
         mPopupCurtain = new Sprite();
         mPopupCurtain.alpha = 0.5;
         mPopupCurtain.x = 0;
         mPopupCurtain.y = 0;
         mPopupCurtain.graphics.clear();
         mPopupCurtain.graphics.beginFill((0 : UInt));
         mPopupCurtain.graphics.drawRect(0,0,mFacade.viewWidth,mFacade.viewHeight);
         mPopupCurtain.graphics.endFill();
         mPopupCurtain.mouseEnabled = mFacade.popupCurtainBlockMouse;
         mFacade.stageRef.addEventListener("resize",onResize);
         onResize();
         MemoryTracker.track(this,"SceneGraphManager - created in SceneGraphManager()","brain");
      }
      
      public static function setBottomHeight(param1:Float) 
      {
         BOTTOM_HEIGHT = param1;
      }
      
      public static function getLayerFromName(param1:String) : Int
      {
         var _loc2_= 20;
         switch(param1)
         {
            case "ground":
               _loc2_ = 5;
               
            case "background":
               _loc2_ = 10;
               
            case "sorted":
               _loc2_ = 20;
               
            case "foreground":
               _loc2_ = 30;
               
            case "ui":
               _loc2_ = 50;
               
            case "overfade":
               _loc2_ = 46;
               
            default:
               Logger.error("Unknown prop layer: " + param1 + " defaulting to SORTED.");
               _loc2_ = 20;
         }
         return _loc2_;
      }
      
      public static function getGrayScaleSaturationFilter(param1:Float) : ColorMatrixFilter
      {
         param1 /= 100;
         var _loc6_= new ColorMatrixFilter();
         var _loc2_:Array<ASAny> = [1,0,0,0,0];
         var _loc3_:Array<ASAny> = [0,1,0,0,0];
         var _loc8_:Array<ASAny> = [0,0,1,0,0];
         var _loc4_:Array<ASAny> = [0,0,0,1,0];
         var _loc5_:Array<ASAny> = [0.3,0.59,0.11,0,0];
         var _loc7_:Array<ASAny> = [];
         _loc7_ = _loc7_.concat(ASCompat.dynamicAs(interpolateArrays(_loc5_,_loc2_,param1), Array));
         _loc7_ = _loc7_.concat(ASCompat.dynamicAs(interpolateArrays(_loc5_,_loc3_,param1), Array));
         _loc7_ = _loc7_.concat(ASCompat.dynamicAs(interpolateArrays(_loc5_,_loc8_,param1), Array));
         _loc7_ = _loc7_.concat(_loc4_);
         _loc6_.matrix = cast(_loc7_);
         return _loc6_;
      }
      
      public static function setGrayScaleSaturation(param1:DisplayObject, param2:Float) 
      {
         if(param2 >= 100)
         {
            param1.filters = cast([]);
         }
         else
         {
            param1.filters = cast([getGrayScaleSaturationFilter(param2)]);
         }
      }
      
      public static function interpolateArrays(param1:Array<ASAny>, param2:Array<ASAny>, param3:Float) : ASObject
      {
         var _loc4_= param1.length >= param2.length ? param1.slice(0) : param2.slice(0);
         var _loc5_= _loc4_.length;
         while(_loc5_-- != 0)
         {
            _loc4_[_loc5_] = param1[_loc5_] + ASCompat.toNumber(ASCompat.toNumber(param2[_loc5_]) - ASCompat.toNumber(param1[_loc5_])) * param3;
         }
         return _loc4_;
      }
      
      public static function debugPrintNode(param1:DisplayObject, param2:Int = 0) 
      {
         var _loc4_= 0;
         var _loc6_= 0;
         var _loc3_= "";
         _loc4_ = 0;
         while(_loc4_ < param2)
         {
            _loc3_ += " ";
            _loc4_++;
         }
         _loc3_ += param1.toString() + " " + param1.name;
         trace(_loc3_);
         var _loc5_= ASCompat.reinterpretAs(param1 , DisplayObjectContainer);
         if(_loc5_ != null)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_.numChildren)
            {
               debugPrintNode(_loc5_.getChildAt(_loc6_),param2 + 1);
               _loc6_++;
            }
         }
      }
      
      public function ui1_9visible(param1:Bool) 
      {
         mUI1.visible = param1;
         mUI2.visible = param1;
         mUI3.visible = param1;
         mUI4.visible = param1;
         mUI5.visible = param1;
         mUI6.visible = param1;
         mUI7.visible = param1;
         mUI8.visible = param1;
         mUI9.visible = param1;
      }
      
      public function cleanBackgroundLayer() 
      {
         while(mBackgroundLayer.numChildren > 0)
         {
            mBackgroundLayer.removeChildAt(0);
         }
      }
      
      @:isVar public var worldLayerGroup(get,never):LayerGroup;
public function  get_worldLayerGroup() : LayerGroup
      {
         return mWorldLayerGroup;
      }
      
      @:isVar public var UILayerGroup(get,never):LayerGroup;
public function  get_UILayerGroup() : LayerGroup
      {
         return mUILayerGroup;
      }
      
      public function setUIScale(param1:Float) 
      {
         mUITopCenterBackGround.scaleX = param1;
         mUITopCenterBackGround.scaleY = param1;
         mUI1.scaleX = param1;
         mUI1.scaleY = param1;
         mUI2.scaleX = param1;
         mUI2.scaleY = param1;
         mUI3.scaleX = param1;
         mUI3.scaleY = param1;
         mUI4.scaleX = param1;
         mUI4.scaleY = param1;
         mUI5.scaleX = param1;
         mUI5.scaleY = param1;
         mUI6.scaleX = param1;
         mUI6.scaleY = param1;
         mUI7.scaleX = param1;
         mUI7.scaleY = param1;
         mUI7T.scaleX = param1;
         mUI7T.scaleY = param1;
         mUI8.scaleX = param1;
         mUI8.scaleY = param1;
         mUI9.scaleX = param1;
         mUI9.scaleY = param1;
         mUI9T.scaleX = param1;
         mUI9T.scaleY = param1;
         mUI10.scaleX = param1;
         mUI10.scaleY = param1;
         mUI11.scaleX = param1;
         mUI11.scaleY = param1;
         mUI12.scaleX = param1;
         mUI12.scaleY = param1;
         mUICenterPopup.scaleX = param1;
         mUICenterPopup.scaleY = param1;
      }
      
      public function showPopupCurtain() 
      {
         mCurtainReferenceCount = mCurtainReferenceCount + 1;
         if(!mUIPopUpCurtainLayer.contains(mPopupCurtain))
         {
            mUIPopUpCurtainLayer.addChild(mPopupCurtain);
            if(mCurtainReferenceCount > 1)
            {
               Logger.error("Curtain reference count is greater than one but no curtain was up.");
            }
         }
      }
      
      public function removePopupCurtain() 
      {
         if(mCurtainReferenceCount == 0)
         {
            Logger.error("Lower curtain called without a curtain being up.");
            return;
         }
         mCurtainReferenceCount = mCurtainReferenceCount - 1;
         if(mCurtainReferenceCount == 0)
         {
            if(mUIPopUpCurtainLayer.contains(mPopupCurtain))
            {
               mUIPopUpCurtainLayer.removeChild(mPopupCurtain);
            }
            else
            {
               Logger.error("Lower Curtain called, reference count dropped to 0, but no curtain was up.");
            }
         }
      }
      
      function createLayer(param1:UInt, param2:LayerGroup, param3:String) : Layer
      {
         var _loc4_= new Layer((param1 : Int));
         _loc4_.name = param3;
         param2.addLayer(_loc4_);
         mLayers.add(param1,_loc4_);
         return _loc4_;
      }
      
      function createSortedLayer(param1:UInt, param2:LayerGroup, param3:String) : SortedLayer
      {
         var _loc4_= new SortedLayer((param1 : Int));
         _loc4_.name = param3;
         param2.addLayer(_loc4_);
         mLayers.add(param1,_loc4_);
         return _loc4_;
      }
      
      function createSortOnAddLayer(param1:UInt, param2:LayerGroup, param3:String) : SortOnAddLayer
      {
         var _loc4_= new SortOnAddLayer((param1 : Int));
         _loc4_.name = param3;
         param2.addLayer(_loc4_);
         mLayers.add(param1,_loc4_);
         return _loc4_;
      }
      
      function onResize(param1:Event = null) 
      {
         var _loc5_:Float = 160;
         var _loc3_= (Math.round(0) : UInt);
         var _loc6_= (Math.round(mFacade.viewWidth * 0.5) : UInt);
         var _loc8_= (Math.round(mFacade.viewWidth) : UInt);
         var _loc2_= (Math.round(0) : UInt);
         var _loc4_= (Math.round((mFacade.viewHeight - BOTTOM_HEIGHT) * 0.5) : UInt);
         var _loc7_= (Math.round(mFacade.viewHeight - BOTTOM_HEIGHT) : UInt);
         var _loc9_= (Math.round(mFacade.viewHeight) : UInt);
         mUITopCenterBackGround.x = _loc6_;
         mUITopCenterBackGround.y = _loc2_;
         mUI1.x = _loc3_;
         mUI1.y = _loc2_;
         mUI2.x = _loc6_;
         mUI2.y = _loc2_;
         mUI3.x = _loc8_;
         mUI3.y = _loc2_;
         mUI4.x = _loc3_;
         mUI4.y = _loc4_;
         mUI5.x = _loc6_;
         mUI5.y = _loc4_;
         mUI6.x = _loc8_;
         mUI6.y = _loc4_;
         mUI7.x = _loc3_;
         mUI7.y = _loc7_;
         mUI7T.x = _loc3_;
         mUI7T.y = _loc7_;
         mUI8.x = _loc6_;
         mUI8.y = _loc7_;
         mUI9.x = _loc8_;
         mUI9.y = _loc7_;
         mUI9T.x = _loc8_;
         mUI9T.y = _loc7_;
         mUI10.x = _loc3_;
         mUI10.y = _loc9_;
         mUI11.x = _loc6_;
         mUI11.y = _loc9_;
         mUI12.x = _loc8_;
         mUI12.y = _loc9_;
         mUICenterPopup.x = _loc6_;
         mUICenterPopup.y = _loc4_;
         mPopupCurtain.graphics.clear();
         mPopupCurtain.graphics.beginFill((0 : UInt));
         mPopupCurtain.graphics.drawRect(0,0,mFacade.viewWidth,mFacade.viewHeight);
         mPopupCurtain.graphics.endFill();
      }
      
      public function getLayer(param1:Int) : Layer
      {
         return ASCompat.dynamicAs(mLayers.itemFor(param1), brain.render.Layer);
      }
      
      @:isVar public var worldTransformNode(get,never):Sprite;
public function  get_worldTransformNode() : Sprite
      {
         return mWorldLayerGroup.transformNode;
      }
      
      public function contains(param1:DisplayObject, param2:Int) : Bool
      {
         var _loc3_= ASCompat.dynamicAs(mLayers.itemFor(param2), brain.render.Layer);
         if(_loc3_ != null)
         {
            return _loc3_.contains(param1);
         }
         Logger.error("contains: layerIndex not found: " + Std.string(param2));
         return false;
      }
      
      public function addChild(param1:DisplayObject, param2:Int) : DisplayObject
      {
         var _loc3_= ASCompat.dynamicAs(mLayers.itemFor(param2), brain.render.Layer);
         if(_loc3_ != null)
         {
            return _loc3_.addChild(param1);
         }
         Logger.error("layerIndex not found");
         return param1;
      }
      
      public function addChildAt(param1:DisplayObject, param2:Int, param3:Int) : DisplayObject
      {
         var _loc4_= ASCompat.dynamicAs(mLayers.itemFor(param2), brain.render.Layer);
         if(_loc4_ != null)
         {
            return _loc4_.addChildAt(param1,param3);
         }
         Logger.error("layerIndex not found");
         return param1;
      }
      
      public function removeChild(param1:DisplayObject) : DisplayObject
      {
         if(param1 != null && param1.parent != null)
         {
            return param1.parent.removeChild(param1);
         }
         return param1;
      }
      
      public function saturateLayers(param1:Float, param2:Array<ASAny>) 
      {
         var _loc3_= mLayers.keysToArray();
         var _loc4_:ASAny;
         if (checkNullIteratee(_loc3_)) for (_tmp_ in _loc3_)
         {
            _loc4_ = _tmp_;
            if(param2.indexOf(_loc4_) == -1)
            {
               setGrayScaleSaturation(ASCompat.dynamicAs(mLayers.itemFor(_loc4_), flash.display.DisplayObject),param1);
            }
         }
      }
      
      public function debugPrint() 
      {
         var _loc4_:Layer = null;
         var _loc5_:DisplayObject = null;
         var _loc1_= 0;
         var _loc3_= 0;
         var _loc2_= ASCompat.reinterpretAs(mLayers.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc2_.next(), brain.render.Layer);
            Logger.debug("Layer: " + _loc4_.name + " children: " + Std.string(_loc4_.numChildren));
            _loc3_ = 0;
            while(_loc3_ < _loc4_.numChildren)
            {
               _loc5_ = _loc4_.getChildAt(_loc3_);
               _loc1_ = Std.isOfType(_loc5_ , DisplayObjectContainer) ? cast(_loc5_, DisplayObjectContainer).numChildren : 0;
               Logger.debug("    child " + Std.string(_loc3_) + ": " + _loc5_.toString() + " name: " + _loc5_.name + " children: " + _loc1_);
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
      }
      
      public function destroy() 
      {
         mFacade = null;
         mWorldLayerGroup.destroy();
         mUILayerGroup.destroy();
         mGroundDragDropLayerd = null;
         mGroundLayer = null;
         mBackgroundLayer = null;
         mSortedLayer = null;
         mForegroundLayer = null;
         mGameFadeLayer = null;
         mOverFadeLayer = null;
         mUILayer = null;
         mUITopCenterBackGround = null;
         mUI1 = null;
         mUI2 = null;
         mUI3 = null;
         mUI4 = null;
         mUI5 = null;
         mUI6 = null;
         mUI7 = null;
         mUI7T = null;
         mUI8 = null;
         mUI9 = null;
         mUI9T = null;
         mUI10 = null;
         mUI11 = null;
         mUI12 = null;
         mUICenterPopup = null;
         mDragAndDropLayer = null;
         mTooltipLayer = null;
         mPopupLayer = null;
         mFadeLayer = null;
         mCursorLayer = null;
         mLayers.clear();
         mLayers = null;
      }
   }


