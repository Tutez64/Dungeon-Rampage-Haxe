package combat.weapon
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.gameObject.View;
   import brain.render.ActorSpriteSheetRenderer;
   import brain.workLoop.PreRenderWorkComponent;
   import facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   
    class WeaponView extends View
   {
      
      var mWeaponGameObject:WeaponGameObject;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      var mWeaponAnimRenderer:ActorSpriteSheetRenderer;
      
      var mWeaponRenderer:WeaponRenderer;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:WeaponGameObject)
      {
         mDBFacade = param1;
         super(param1);
         mWeaponGameObject = param2;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mFacade);
         if(ASCompat.stringAsBool(mWeaponGameObject.weaponAesthetic.ModelName))
         {
            mWeaponRenderer = new WeaponRenderer(mDBFacade,mWeaponGameObject,true);
            mWeaponRenderer.loadAssets();
            mWeaponGameObject.actorGameObject.actorView.body.addChild(mWeaponRenderer);
            applyColorAndGlow(mWeaponRenderer);
         }
      }
      
      function applyColorAndGlow(param1:DisplayObject) 
      {
         var _loc2_= mWeaponGameObject.weaponAesthetic;
         if(_loc2_.HasColor)
         {
            param1.transform.colorTransform = new ColorTransform(_loc2_.ItemR,_loc2_.ItemG,_loc2_.ItemB,1,_loc2_.ItemRAdd,_loc2_.ItemGAdd,_loc2_.ItemBAdd,0);
         }
         if(_loc2_.HasGlow)
         {
            param1.filters = cast([new GlowFilter(_loc2_.GlowColor,1,_loc2_.GlowDist,_loc2_.GlowDist,_loc2_.GlowStr)]);
         }
         if(mWeaponGameObject.gmRarity.HasGlow)
         {
            param1.filters = cast([new GlowFilter(mWeaponGameObject.gmRarity.GlowColor,1,mWeaponGameObject.gmRarity.GlowDist,mWeaponGameObject.gmRarity.GlowDist,mWeaponGameObject.gmRarity.GlowStr)]);
         }
      }
      
      function removeColorAndGlow(param1:DisplayObject) 
      {
         var _loc2_= mWeaponGameObject.weaponAesthetic;
         if(_loc2_.HasColor)
         {
            param1.transform.colorTransform = new ColorTransform();
         }
         if(_loc2_.HasGlow)
         {
            param1.filters = cast([]);
         }
      }
      
      @:isVar public var weaponRenderer(get,never):WeaponRenderer;
public function  get_weaponRenderer() : WeaponRenderer
      {
         return mWeaponRenderer;
      }
      
      override public function destroy() 
      {
         if(mWeaponRenderer != null)
         {
            mWeaponRenderer.destroy();
            mWeaponRenderer = null;
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mWeaponGameObject = null;
         mDBFacade = null;
         super.destroy();
      }
   }


