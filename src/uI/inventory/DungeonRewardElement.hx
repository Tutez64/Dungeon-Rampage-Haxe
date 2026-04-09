package uI.inventory
;
   import account.ChestInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.render.MovieClipRenderer;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import flash.display.MovieClip;
   
    class DungeonRewardElement extends UIButton
   {
      
      var mDBFacade:DBFacade;
      
      var mChestInfo:ChestInfo;
      
      var mSelectedCallback:ASFunction;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mChestEmptyPicMC:MovieClip;
      
      var mChestRenderer:MovieClipRenderer;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ChestInfo, param4:ASFunction)
      {
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var dbFacade= param1;
         var root= param2;
         var chestInfo= param3;
         var selectedCallback= param4;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mChestInfo = chestInfo;
         mSelectedCallback = selectedCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         releaseCallback = callSelectedCallback;
         ChestInfo.loadItemIconFromId(mChestInfo.gmId,mRoot,mDBFacade,(60 : UInt),(100 : UInt),mAssetLoadingComponent);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mRoot);
         mChestRenderer.play((0 : UInt),true);
         bgColoredExists = mChestInfo.hasColoredBackground;
         bgSwfPath = mChestInfo.backgroundSwfPath;
         bgIconName = mChestInfo.backgroundIconName;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc3_:MovieClip = null;
               var _loc2_= param1.getClass(bgIconName);
               if(_loc2_ != null)
               {
                  _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                  mRoot.addChildAt(_loc3_,1);
               }
            });
         }
      }
      
      @:isVar public var chestInfo(get,never):ChestInfo;
public function  get_chestInfo() : ChestInfo
      {
         return mChestInfo;
      }
      
      public function callSelectedCallback() 
      {
         mSelectedCallback(mChestInfo);
      }
      
      public function select() 
      {
         ASCompat.setProperty((ASCompat.reinterpretAs(mRoot.parent , MovieClip) : ASAny).select, "visible", true);
      }
      
      public function deSelect() 
      {
         ASCompat.setProperty((ASCompat.reinterpretAs(mRoot.parent , MovieClip) : ASAny).select, "visible", false);
      }
      
      public function empty() 
      {
         deSelect();
         while(mRoot.numChildren > 1)
         {
            mRoot.removeChildAt(1);
         }
      }
      
      public function clear() 
      {
         while(mRoot.numChildren > 1)
         {
            mRoot.removeChildAt(1);
         }
      }
      
      override public function destroy() 
      {
         clear();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mChestRenderer.destroy();
         mChestRenderer = null;
         mDBFacade = null;
         mChestInfo = null;
         mSelectedCallback = null;
         releaseCallback = null;
         super.destroy();
      }
   }


