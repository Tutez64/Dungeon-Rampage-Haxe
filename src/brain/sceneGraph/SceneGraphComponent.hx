package brain.sceneGraph
;
   import brain.component.Component;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
    class SceneGraphComponent extends Component
   {
      
      static var mFadeSprite:Sprite;
      
      static var mFadeTween:TweenMax;
      
      var mDisplayObjects:Set;
      
      var mCurtainActive:Bool = false;
      
      public function new(param1:Facade, param2:String = null)
      {
         super(param1);
         mDisplayObjects = new Set();
         MemoryTracker.track(this,"SceneGraphComponent - " + (if (ASCompat.stringAsBool(param2)) param2 else "unknown"),"brain");
      }
      
      public static function bringToFront(param1:DisplayObject) 
      {
         if(param1.parent != null)
         {
            param1.parent.addChildAt(param1,param1.parent.numChildren);
         }
      }
      
      public static function sendToBack(param1:DisplayObject) 
      {
         if(param1.parent != null)
         {
            param1.parent.addChildAt(param1,0);
         }
      }
      
      public static function buildFadeSprite(param1:Facade) 
      {
         mFadeSprite = new Sprite();
         mFadeSprite.graphics.beginFill((0 : UInt),1);
         mFadeSprite.graphics.drawRect(0,0,param1.viewWidth,param1.viewHeight);
         mFadeSprite.graphics.endFill();
         mFadeSprite.mouseEnabled = true;
         mFadeSprite.mouseChildren = false;
      }
      
      public function addChild(param1:DisplayObject, param2:UInt) : DisplayObject
      {
         if(!mDisplayObjects.has(param1))
         {
            mDisplayObjects.add(param1);
         }
         return mFacade.sceneGraphManager.addChild(param1,(param2 : Int));
      }
      
      public function addChildAt(param1:DisplayObject, param2:UInt, param3:UInt) : DisplayObject
      {
         if(!mDisplayObjects.has(param1))
         {
            mDisplayObjects.add(param1);
         }
         return mFacade.sceneGraphManager.addChildAt(param1,(param2 : Int),(param3 : Int));
      }
      
      public function showPopupCurtain() 
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      public function removePopupCurtain() 
      {
         if(mCurtainActive)
         {
            mFacade.sceneGraphManager.removePopupCurtain();
            mCurtainActive = false;
         }
      }
      
      public function removeChild(param1:DisplayObject) : DisplayObject
      {
         if(param1 == null)
         {
            Logger.warn("SceneGraphComponent:removeChild child is null");
            return null;
         }
         mDisplayObjects.remove(param1);
         return mFacade.sceneGraphManager.removeChild(param1);
      }
      
      public function contains(param1:DisplayObject, param2:UInt) : Bool
      {
         return mDisplayObjects.has(param1);
      }
      
      function killFadeTween() 
      {
         if(mFadeTween != null)
         {
            mFadeTween.kill();
            mFadeTween = null;
         }
      }
      
      public function fadeIn(param1:Float) 
      {
         if(mFadeSprite == null)
         {
            buildFadeSprite(mFacade);
         }
         killFadeTween();
         if(param1 == 0)
         {
            this.removeChild(mFadeSprite);
            return;
         }
         this.addChild(mFadeSprite,(100 : UInt));
         mFadeTween = TweenMax.to(mFadeSprite,param1,{
            "alpha":0,
            "onComplete":finishFadeIn
         });
      }
      
      function finishFadeIn() 
      {
         this.removeChild(mFadeSprite);
      }
      
      function finishFadeOut() 
      {
      }
      
      public function fadeOut(param1:Float, param2:Float = 1) 
      {
         if(mFadeSprite == null)
         {
            buildFadeSprite(mFacade);
         }
         killFadeTween();
         this.addChild(mFadeSprite,(100 : UInt));
         if(param1 == 0)
         {
            mFadeSprite.alpha = 1;
            return;
         }
         mFadeTween = TweenMax.to(mFadeSprite,param1,{
            "alpha":param2,
            "onComplete":finishFadeOut
         });
      }
      
      public function saturateLayers(param1:Float, param2:Array<ASAny>) 
      {
         mFacade.sceneGraphManager.saturateLayers(param1,param2);
      }
      
      public function cleanBackgroundLayer() 
      {
         mFacade.sceneGraphManager.cleanBackgroundLayer();
      }
      
      override public function destroy() 
      {
         var _loc1_:DisplayObject = null;
         var _loc2_= ASCompat.reinterpretAs(mDisplayObjects.iterator() , ISetIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc2_.next() , DisplayObject);
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
         }
         mDisplayObjects.clear();
         mDisplayObjects = null;
         removePopupCurtain();
         super.destroy();
      }
   }


