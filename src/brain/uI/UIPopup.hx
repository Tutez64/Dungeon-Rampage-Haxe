package brain.uI
;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIPopup extends UIObject
   {
      
      public static inline final YES= (1 : UInt);
      
      public static inline final NO= (2 : UInt);
      
      public static inline final OK= (4 : UInt);
      
      public static inline final CANCEL= (8 : UInt);
      
      var mButtonFlags:UInt = (4 : UInt);
      
      var mModal:Bool = true;
      
      var mCurtainActive:Bool = false;
      
      var mCloseCallback:ASFunction;
      
      var mText:String = "";
      
      var mTextField:TextField;
      
      var mYesButton:UIButton;
      
      var mNoButton:UIButton;
      
      var mOkButton:UIButton;
      
      var mCancelButton:UIButton;
      
      public function new(param1:Facade)
      {
         var _loc2_= new MovieClip();
         MemoryTracker.track(_loc2_,"MovieClip - popup root created in UIPopup()","brain");
         super(param1,_loc2_);
         if(mModal)
         {
            makeCurtain();
         }
         mFacade.sceneGraphManager.addChild(mRoot,105);
      }
      
      public static function show(param1:Facade, param2:String = "", param3:UInt = (4 : UInt), param4:Bool = true, param5:ASFunction = null) : UIPopup
      {
         var _loc6_= new UIPopup(param1);
         _loc6_.mText = param2;
         _loc6_.mButtonFlags = param3;
         _loc6_.mModal = param4;
         _loc6_.mCloseCallback = param5;
         return _loc6_;
      }
      
      override public function destroy() 
      {
         removeCurtain();
      }
      
      @:isVar public var callback(never,set):ASFunction;
public function  set_callback(param1:ASFunction) :ASFunction      {
         return mCloseCallback = param1;
      }
      
      function makeCurtain() 
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      function removeCurtain() 
      {
         if(mCurtainActive)
         {
            mFacade.sceneGraphManager.removePopupCurtain();
            mCurtainActive = false;
         }
      }
      
      function setupUI(param1:Dynamic) 
      {
         var popupClass= param1;
         var popup= ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
         MemoryTracker.track(popup,"MovieClip - popup content created in UIPopup.setupUI()","brain");
         mRoot.addChild(popup);
         mTextField = cast((popup : ASAny).popupText, TextField);
         mTextField.text = mText;
         mYesButton = new UIButton(mFacade,ASCompat.dynamicAs((popup : ASAny).yesButton, flash.display.MovieClip));
         MemoryTracker.track(mYesButton,"UIButton - yes button created in UIPopup.setupUI()","brain");
         mNoButton = new UIButton(mFacade,ASCompat.dynamicAs((popup : ASAny).noButton, flash.display.MovieClip));
         MemoryTracker.track(mNoButton,"UIButton - no button created in UIPopup.setupUI()","brain");
         mOkButton = new UIButton(mFacade,ASCompat.dynamicAs((popup : ASAny).okButton, flash.display.MovieClip));
         MemoryTracker.track(mOkButton,"UIButton - ok button created in UIPopup.setupUI()","brain");
         mCancelButton = new UIButton(mFacade,ASCompat.dynamicAs((popup : ASAny).cancelButton, flash.display.MovieClip));
         MemoryTracker.track(mCancelButton,"UIButton - cancel button created in UIPopup.setupUI()","brain");
         mYesButton.label.text = "Yes";
         mNoButton.label.text = "No";
         mOkButton.label.text = "OK";
         mCancelButton.label.text = "Cancel";
         mYesButton.releaseCallback = function()
         {
            onClose((1 : UInt));
         };
         mNoButton.releaseCallback = function()
         {
            onClose((2 : UInt));
         };
         mOkButton.releaseCallback = function()
         {
            onClose((4 : UInt));
         };
         mCancelButton.releaseCallback = function()
         {
            onClose((8 : UInt));
         };
         mYesButton.root.visible = ((mButtonFlags : Int) & 1) != 0;
         mNoButton.root.visible = ((mButtonFlags : Int) & 2) != 0;
         mOkButton.root.visible = ((mButtonFlags : Int) & 4) != 0;
         mCancelButton.root.visible = ((mButtonFlags : Int) & 8) != 0;
      }
      
      function onClose(param1:UInt) 
      {
         if(mCloseCallback != null)
         {
            mCloseCallback(param1);
         }
         this.destroy();
      }
   }


