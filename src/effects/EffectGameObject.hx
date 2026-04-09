package effects
;
   import brain.utils.IPoolable;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import flash.geom.Vector3D;
   
    class EffectGameObject extends FloorObject implements IPoolable
   {
      
      var mEffectView:EffectView;
      
      public var swfPath:String;
      
      public var className:String;
      
      var mAssetLoadedCallback:ASFunction;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:Float, param5:UInt = (0 : UInt), param6:ASFunction = null)
      {
         this.swfPath = param2;
         this.className = param3;
         mAssetLoadedCallback = param6;
         super(param1,param5);
         this.layer = 20;
         this.init();
         mEffectView.setPlayRate(param4);
      }
      
      public function setAssetLoadedCallback(param1:ASFunction) 
      {
         mAssetLoadedCallback = param1;
      }
      
      public function postCheckout(param1:Bool) 
      {
         if(!param1 && mAssetLoadedCallback != null)
         {
            view.movieClipRenderer.clip.gotoAndStop(0);
            mAssetLoadedCallback(view.movieClipRenderer.clip);
         }
      }
      
      public function postCheckin() 
      {
         mEffectView.stop();
      }
      
      public function getPoolKey() : String
      {
         return swfPath + ":" + className;
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         super.position = param1;
         return mEffectView.position = param1;
      }
      
      override function buildView() 
      {
         mEffectView = new EffectView(mDBFacade,this,mAssetLoadedCallback);
         MemoryTracker.track(mEffectView,"EffectView \'" + swfPath + ":" + className + "\' - created in EffectGameObject.buildView()","pool");
         this.view = mEffectView ;
      }
      
            
      @:isVar public var rotation(get,set):Float;
public function  get_rotation() : Float
      {
         return mFloorView.rotation;
      }
function  set_rotation(param1:Float) :Float      {
         return this.view.rotation = param1;
      }
      
      override public function destroy() 
      {
         mEffectView = null;
         super.destroy();
      }
   }


