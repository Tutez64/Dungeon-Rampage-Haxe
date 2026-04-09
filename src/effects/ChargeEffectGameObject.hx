package effects
;
   import actor.ActorView;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.render.MovieClipRenderController;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   
    class ChargeEffectGameObject extends EffectGameObject
   {
      
      static inline final FINAL_CHARGE_SCALE_X:Float = 1.3286423841059603;
      
      static inline final FINAL_CHARGE_SCALE_Y:Float = 1.3283450704225352;
      
      static inline final CHARGE_DELAY:Float = 0;
      
      static inline final RADIUS= (50 : UInt);
      
      static var mChargeGlow:GlowFilter = new GlowFilter((16763904 : UInt),1,128,128,1.8);
      
      var mReady:Bool = false;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mActorView:ActorView;
      
      var mChargeLoopClip:MovieClip;
      
      var mChargeLoopRenderer:MovieClipRenderController;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:ActorView)
      {
         super(param1,param2,param3,1);
         mReady = false;
         mLogicalWorkComponent = new LogicalWorkComponent(param1);
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mActorView = param4;
         view.root.visible = false;
         mActorView.root.addChildAt(view.root,0);
      }
      
      @:isVar public var ready(get,never):Bool;
public function  get_ready() : Bool
      {
         return mReady;
      }
      
      public function startCharge(param1:Float) 
      {
         var duration= param1;
         view.root.visible = true;
         view.movieClipRenderer.playRate = view.movieClipRenderer.clip.totalFrames / (duration * 24);
         TweenMax.to(view.root,duration,{"onComplete":function()
         {
            view.root.filters = cast([mChargeGlow]);
            mReady = true;
            playLoopingEffect();
         }});
         cast(view, EffectView).play(true,null);
      }
      
      function playLoopingEffect() 
      {
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("db_fx_chargeReadyLoop");
            if(_loc2_ == null)
            {
               return;
            }
            mChargeLoopClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            if(mActorView.root.contains(view.root))
            {
               mActorView.root.removeChild(view.root);
            }
            mActorView.root.addChildAt(mChargeLoopClip,0);
            mChargeLoopRenderer = new MovieClipRenderController(mDBFacade,mChargeLoopClip);
            mChargeLoopRenderer.play();
         });
      }
      
      override public function destroy() 
      {
         if(this.view != null)
         {
            TweenMax.killTweensOf(this.view.root);
         }
         if(mChargeLoopClip != null && mActorView.root.contains(mChargeLoopClip))
         {
            mActorView.root.removeChild(mChargeLoopClip);
         }
         mActorView = null;
         mChargeLoopClip = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mChargeLoopRenderer != null)
         {
            mChargeLoopRenderer.destroy();
         }
         mChargeLoopRenderer = null;
         if(this.mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         super.destroy();
      }
   }


