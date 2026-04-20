package brain.gameObject
;
   import brain.clock.GameClock;
   import brain.facade.Facade;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
    class View
   {
      
      var mFacade:Facade;
      
      var mRoot:Sprite;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mMovieClipRenderer:MovieClipRenderController;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mFadeResetTask:Task;
      
      var mFading:Bool = false;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
         var _loc2_= "View";
         mSceneGraphComponent = new SceneGraphComponent(mFacade,_loc2_);
         mWorkComponent = new LogicalWorkComponent(mFacade,_loc2_);
         mRoot = new Sprite();
         mFading = false;
         MemoryTracker.track(this,_loc2_ + " - created in View()","brain");
      }
      
      static function recursiveFindChildrenOfClass(param1:Array<ASAny>, param2:DisplayObject, param3:Array<ASAny>) 
      {
         var _loc5_= 0;
         var _loc6_= ASCompat.getQualifiedClassName(param2);
         if(param3.indexOf(_loc6_) != -1)
         {
            param1.push(param2);
         }
         var _loc4_= ASCompat.reinterpretAs(param2 , DisplayObjectContainer);
         if(_loc4_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               recursiveFindChildrenOfClass(param1,_loc4_.getChildAt(_loc5_),param3);
               _loc5_++;
            }
         }
      }
      
      public static function findChildrenOfClass(param1:DisplayObjectContainer, param2:Array<ASAny>) : Array<ASAny>
      {
         var _loc3_:Array<ASAny> = [];
         recursiveFindChildrenOfClass(_loc3_,param1,param2);
         return _loc3_;
      }
      
      public function init() 
      {
      }
      
      public function unFade() 
      {
         mRoot.alpha = 1;
         mFadeResetTask.destroy();
         mFadeResetTask = null;
         mFading = false;
      }
      
      public function updateFade(param1:GameClock) 
      {
         var _loc2_= Math.NaN;
         if(mFading)
         {
            mRoot.alpha *= 0.85;
            if(mRoot.alpha <= 0.3)
            {
               mFading = false;
               mRoot.alpha = 0.3;
            }
         }
         else
         {
            _loc2_ = 1 - mRoot.alpha;
            mRoot.alpha = 1 - _loc2_ * _loc2_;
            if(mRoot.alpha > 0.975)
            {
               unFade();
            }
         }
      }
      
      public function doFade() 
      {
         mFading = true;
         if(mFadeResetTask == null)
         {
            mFadeResetTask = mWorkComponent.doEveryFrame(updateFade);
         }
      }
      
      @:isVar public var movieClipRenderer(get,never):MovieClipRenderController;
public function  get_movieClipRenderer() : MovieClipRenderController
      {
         return mMovieClipRenderer;
      }
      
            
      @:isVar public var position(get,set):Vector3D;
public function  get_position() : Vector3D
      {
         return new Vector3D(mRoot.x,mRoot.y);
      }
function  set_position(param1:Vector3D) :Vector3D      {
         mRoot.x = param1.x;
         mRoot.y = param1.y;
return param1;
      }
      
            
      @:isVar public var rotation(get,set):Float;
public function  get_rotation() : Float
      {
         return mRoot.rotation;
      }
function  set_rotation(param1:Float) :Float      {
         return mRoot.rotation = param1;
      }

      
      @:isVar public var root(get,never):Sprite;
public function  get_root() : Sprite
      {
         return mRoot;
      }
      
      public function destroy() 
      {
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         if(mFadeResetTask != null)
         {
            mFadeResetTask.destroy();
            mFadeResetTask = null;
         }
         if(mWorkComponent != null)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mRoot.parent != null)
         {
            mRoot.parent.removeChild(mRoot);
         }
         if(mMovieClipRenderer != null)
         {
            mMovieClipRenderer.destroy();
            mMovieClipRenderer = null;
         }
         mRoot = null;
         mFacade = null;
      }
   }


