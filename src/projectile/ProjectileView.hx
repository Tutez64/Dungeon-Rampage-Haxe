package projectile
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.render.MovieClipRenderController;
   import brain.utils.ColorMatrix;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   
    class ProjectileView extends FloorView
   {
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mBody:MovieClip;
      
      var mEffect:MovieClip;
      
      var mProjectileGameObject:ProjectileGameObject;
      
      var mEffectRenderer:MovieClipRenderController;
      
      var mProjectileRenderer:MovieClipRenderController;
      
      public function new(param1:DBFacade, param2:ProjectileGameObject)
      {
         super(param1,param2);
         mProjectileGameObject = param2;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mFacade);
         if(mProjectileGameObject.effectTimeOffset > 0)
         {
            mLogicalWorkComponent.doLater(mProjectileGameObject.effectTimeOffset,createEffect);
         }
         else
         {
            this.createEffect();
         }
      }
      
      override public function init() 
      {
         super.init();
         var _loc1_= DBFacade.buildFullDownloadPath(mProjectileGameObject.gmProjectile.SwfFilepath);
         mAssetLoadingComponent.getSwfAsset(_loc1_,setupArt);
      }
      
      function createEffect(param1:GameClock = null) 
      {
         if(mProjectileGameObject.effectName != null)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mProjectileGameObject.effectPath),setupEffect);
         }
      }
      
      public function setupEffect(param1:SwfAsset) 
      {
         mEffectRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade,param1,mProjectileGameObject.effectName) , MovieClipRenderController);
         mEffect = mEffectRenderer.clip;
         var _loc3_= mProjectileGameObject.weapon != null ? mProjectileGameObject.weapon.collisionScale() : 1;
         mEffect.scaleX;
         mEffect.scaleY;
         var _loc4_= mProjectileGameObject.gmProjectile.TrailTint;
         var _loc2_= mProjectileGameObject.gmProjectile.TrailSaturation;
         applyColor(_loc4_,_loc2_,mEffect);
         mEffectRenderer.play((0 : UInt),true);
         mRoot.addChildAt(mEffect,0);
         mEffect.rotation = Math.atan2(mProjectileGameObject.velocity.y,mProjectileGameObject.velocity.x) * 180 / 3.141592653589793;
      }
      
      function setupArt(param1:SwfAsset) 
      {
         mProjectileRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade,param1,mProjectileGameObject.gmProjectile.ProjModel) , MovieClipRenderController);
         mBody = mProjectileRenderer.clip;
         mProjectileRenderer.play((0 : UInt),true);
         mRoot.addChild(mBody);
         var _loc3_= mProjectileGameObject.gmProjectile.Tint;
         var _loc2_= mProjectileGameObject.gmProjectile.Saturation;
         applyColor(_loc3_,_loc2_,mBody);
         if(mProjectileGameObject.rotationSpeed == 0)
         {
            if(mProjectileGameObject.shouldRotate)
            {
               mBody.rotation = Math.atan2(mProjectileGameObject.velocity.y,mProjectileGameObject.velocity.x) * 180 / 3.141592653589793;
            }
         }
         else
         {
            mLogicalWorkComponent.doEveryFrame(updateRotation);
         }
         if(mProjectileGameObject.weapon != null)
         {
            applyColorAndGlow(mBody);
            mBody.scaleX *= mProjectileGameObject.weapon.collisionScale();
            mBody.scaleY *= mProjectileGameObject.weapon.collisionScale();
         }
      }
      
      function applyColorAndGlow(param1:DisplayObject) 
      {
         var _loc2_= mProjectileGameObject.weapon.weaponAesthetic;
         if(_loc2_.HasColor)
         {
            param1.transform.colorTransform = new ColorTransform(_loc2_.ItemR,_loc2_.ItemG,_loc2_.ItemB,1,_loc2_.ItemRAdd,_loc2_.ItemGAdd,_loc2_.ItemBAdd,0);
         }
         if(_loc2_.HasGlow)
         {
            param1.filters = cast([new GlowFilter(_loc2_.GlowColor,1,_loc2_.GlowDist,_loc2_.GlowDist,_loc2_.GlowStr)]);
         }
         if(mProjectileGameObject.weapon.gmRarity.HasGlow)
         {
            param1.filters = cast([new GlowFilter(mProjectileGameObject.weapon.gmRarity.GlowColor,0.5,mProjectileGameObject.weapon.gmRarity.GlowDist * mProjectileGameObject.weapon.collisionScale(),mProjectileGameObject.weapon.gmRarity.GlowDist * mProjectileGameObject.weapon.collisionScale(),mProjectileGameObject.weapon.gmRarity.GlowStr * mProjectileGameObject.weapon.collisionScale())]);
         }
      }
      
      function applyColor(param1:Float, param2:Float, param3:DisplayObject) 
      {
         var _loc4_:ColorMatrix = null;
         if(param1 != 0 || param2 != 1)
         {
            _loc4_ = new ColorMatrix();
            _loc4_.adjustHue(param1);
            _loc4_.adjustSaturation(param2);
            param3.filters = cast([_loc4_.filter]);
         }
         else
         {
            param3.filters = cast([]);
         }
      }
      
      function updateRotation(param1:GameClock) 
      {
         if(mBody != null)
         {
            mBody.rotation += mProjectileGameObject.rotationSpeed * mLogicalWorkComponent.gameClock.tickLength;
         }
      }
      
      public function setRotation(param1:Float) 
      {
         if(mBody != null)
         {
            mBody.rotation = param1;
         }
      }
      
      override public function destroy() 
      {
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mBody = null;
         mEffect = null;
         if(mEffectRenderer != null)
         {
            mDBFacade.movieClipPool.checkin(mEffectRenderer);
            mEffectRenderer = null;
         }
         if(mProjectileRenderer != null)
         {
            mDBFacade.movieClipPool.checkin(mProjectileRenderer);
            mProjectileRenderer = null;
         }
         mProjectileGameObject = null;
         super.destroy();
      }
   }


