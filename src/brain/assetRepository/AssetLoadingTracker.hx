package brain.assetRepository
;
    class AssetLoadingTracker
   {
      
      public var pendingLoadCallback:ASFunction;
      
      public var pendingErrorCallback:ASFunction;
      
      public var assetLoadingComponent:AssetLoadingComponent;
      
      public var assetKey:String;
      
      public function new(param1:String, param2:AssetLoadingComponent, param3:ASFunction, param4:ASFunction)
      {
         
         this.assetKey = param1;
         this.assetLoadingComponent = param2;
         this.pendingLoadCallback = param3;
         this.pendingErrorCallback = param4;
         this.assetLoadingComponent.mPendingDownloads.add(this);
      }
      
      public function errorCallback() 
      {
         if(pendingErrorCallback != null)
         {
            pendingErrorCallback();
         }
         if(assetLoadingComponent != null)
         {
            assetLoadingComponent.RemoveLoader(this);
         }
      }
      
      public function successCallback(param1:Asset) 
      {
         if(pendingLoadCallback != null)
         {
            pendingLoadCallback(param1);
         }
         if(assetLoadingComponent != null)
         {
            assetLoadingComponent.RemoveLoader(this);
         }
      }
      
      public function destroy() 
      {
         pendingLoadCallback = null;
         pendingErrorCallback = null;
         assetLoadingComponent = null;
         assetKey = null;
      }
   }


