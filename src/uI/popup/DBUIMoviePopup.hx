package uI.popup
;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import uI.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   
    class DBUIMoviePopup extends DBUIOneButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      var mContainerMC:MovieClip = new MovieClip();
      
      var mLoader:Loader;
      
      var mMoviePlayer:ASObject;
      
      var mWidth:Float = Math.NaN;
      
      var mHeight:Float = Math.NaN;
      
      var mPopUpClassName:String;
      
      var mLoadingPopUp:DBUIPopup;
      
      var mUseCurtain:Bool = false;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:String, param5:String, param6:String, param7:ASFunction, param8:Float, param9:Float, param10:Bool)
      {
         var dbFacade= param1;
         var popUpClassName= param2;
         var titleText= param3;
         var contentText= param4;
         var moviePath= param5;
         var centerText= param6;
         var centerCallback= param7;
         var width= param8;
         var height= param9;
         var showPagination= param10;
         
         mWidth = width;
	     mHeight = height;
	     mPopUpClassName = popUpClassName;	      
	     mUseCurtain = !showPagination;
	      
         super(dbFacade,titleText,mContainerMC,centerText,centerCallback);
         mMessage.text = contentText;
         mLoadingPopUp = new DBUIPopup(mDBFacade,"LOADING",null,true,false);
         MemoryTracker.track(mLoadingPopUp,"DBUIPopup - created in DBUIMoviePopup.DBUIMoviePopup()");
         mLoader = new Loader();
         mLoader.contentLoaderInfo.addEventListener("init",onLoaderInit);
         mLoader.contentLoaderInfo.addEventListener("ioError",loaderIOErrorHandler);
         mLoader.load(new URLRequest(moviePath));
         if(!showPagination)
         {
            ASCompat.setProperty((mPopup : ASAny).center_button_news, "visible", false);
            ASCompat.setProperty((mPopup : ASAny).pagination, "visible", false);
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
            mCenterButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).center_button_news, flash.display.MovieClip));
            mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mCenterButton.label.text = mCenterText;
            mCenterButton.releaseCallback = function()
            {
               close(mCenterCallback);
            };
         }
      }
      
      override function animatedEntrance() 
      {
         super.animatedEntrance();
      }
      
      override public function getPagination() : MovieClip
      {
         return ASCompat.dynamicAs((mPopup : ASAny).pagination, flash.display.MovieClip);
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return mPopUpClassName;
      }
      
      function loaderIOErrorHandler(param1:IOErrorEvent) 
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         destroy();
      }
      
      function onLoaderInit(param1:Event) 
      {
         mContainerMC.addChild(mLoader);
         mLoader.x = -mWidth / 2;
         mLoader.y = -mHeight / 2;
         mLoader.content.addEventListener("onReady",onPlayerReady);
         mLoader.content.addEventListener("onError",onPlayerError);
         mLoader.content.addEventListener("onStateChange",onPlayerStateChange);
         mLoader.content.addEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange);
      }
      
      function onPlayerReady(param1:Event) 
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         mMoviePlayer = mLoader.content;
         mMoviePlayer.setSize(mWidth,mHeight);
      }
      
      function onPlayerError(param1:Event) 
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
      }
      
      function onPlayerStateChange(param1:Event) 
      {
      }
      
      function onVideoPlaybackQualityChange(param1:Event) 
      {
      }
      
      override public function destroy() 
      {
         super.destroy();
         mContainerMC = null;
         mLoader.contentLoaderInfo.removeEventListener("init",onLoaderInit);
         if(mLoader.content != null)
         {
            mLoader.content.removeEventListener("onReady",onPlayerReady);
            mLoader.content.removeEventListener("onError",onPlayerError);
            mLoader.content.removeEventListener("onStateChange",onPlayerStateChange);
            mLoader.content.removeEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange);
            mLoader.unloadAndStop();
         }
         mLoader = null;
      }
   }


