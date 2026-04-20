package dr_floor
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.workLoop.LogicalWorkComponent;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.MovieClip;
   
    class FloorMessageView
   {
      
      static inline final DESTROY_TIME:Float = 2;
      
      var mDBFacade:DBFacade;
      
      var mMessageKey:String;
      
      var mMessageString:String;
      
      var mMessageClip:MovieClip;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function new(param1:DBFacade, param2:String, param3:String = "")
      {
         
         mDBFacade = param1;
         mMessageKey = param2;
         mMessageString = param3;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"FloorMessageView");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"FloorMessageView");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),assetLoaded);
      }
      
      function assetLoaded(param1:SwfAsset) 
      {
         var swfAsset= param1;
         var textClass= swfAsset.getClass("floor_message");
         mMessageClip = ASCompat.dynamicAs(ASCompat.createInstance(textClass, []), flash.display.MovieClip);
         ASCompat.setProperty((mMessageClip : ASAny).message_text_01, "autoSize", "center");
         ASCompat.setProperty((mMessageClip : ASAny).message_text_01, "multiline", true);
         if(mMessageString != "")
         {
            ASCompat.setProperty((mMessageClip : ASAny).message_text_01, "text", mMessageString);
         }
         else
         {
            ASCompat.setProperty((mMessageClip : ASAny).message_text_01, "text", Locale.getString(mMessageKey));
         }
         if(ASCompat.toNumberField((mMessageClip : ASAny).message_text_01, "textWidth") > 700)
         {
            ASCompat.setProperty((mMessageClip : ASAny).message_text_01, "autoSize", "center");
         }
         mMessageClip.x = mDBFacade.viewWidth / 2;
         mMessageClip.y = mDBFacade.viewHeight / 2 + 100;
         mSceneGraphComponent.addChild(mMessageClip,(105 : UInt));
         mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
         {
            destroy();
         });
      }
      
      public function destroy() 
      {
         mSceneGraphComponent.removeChild(mMessageClip);
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         mMessageClip = null;
         mDBFacade = null;
      }
   }


