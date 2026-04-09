package effects
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import flash.display.MovieClip;
   
    class EffectView extends FloorView
   {
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mEffect:MovieClip;
      
      var mEffectClassName:String;
      
      var mLoop:Bool = false;
      
      var mShouldBePlaying:ShouldBePlaying;
      
      var mAssetLoadedCallback:ASFunction;
      
      public function new(param1:DBFacade, param2:EffectGameObject, param3:ASFunction = null)
      {
         super(param1,param2);
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mEffectClassName = param2.className;
         mAssetLoadedCallback = param3;
         mAssetLoadingComponent.getSwfAsset(param2.swfPath,assetLoaded);
      }
      
      public function setPlayRate(param1:Float) 
      {
         if(mMovieClipRenderer != null)
         {
            mMovieClipRenderer.playRate = param1;
         }
      }
      
      public function play(param1:Bool, param2:ASFunction) 
      {
         if(mMovieClipRenderer != null)
         {
            mMovieClipRenderer.play((0 : UInt),param1,param2);
         }
         else
         {
            mShouldBePlaying = new ShouldBePlaying(param1,param2);
         }
      }
      
      public function stop() 
      {
         mShouldBePlaying = null;
         if(mMovieClipRenderer != null)
         {
            mMovieClipRenderer.stop();
            mMovieClipRenderer.finishedCallback = null;
         }
         this.removeFromStage();
         if(mRoot.parent != null)
         {
            mRoot.parent.removeChild(mRoot);
         }
      }
      
      function assetLoaded(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass(mEffectClassName);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find class: " + mEffectClassName);
            return;
         }
         mEffect = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
         mMovieClipRenderer = new MovieClipRenderController(mFacade,mEffect);
         if(mShouldBePlaying != null)
         {
            mMovieClipRenderer.play((0 : UInt),mShouldBePlaying.loop,mShouldBePlaying.finishedCallback);
         }
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         mRoot.addChild(mEffect);
         if(mAssetLoadedCallback != null)
         {
            mAssetLoadedCallback(mEffect);
         }
      }
      
      override public function destroy() 
      {
         mEffect = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
   }


private class ShouldBePlaying
{
   
   public var loop:Bool = false;
   
   public var finishedCallback:ASFunction;
   
   public function new(param1:Bool, param2:ASFunction)
   {
      
      loop = param1;
      finishedCallback = param2;
   }
}
