package uI.popup
;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIButton;
   import brain.jsonRPC.JSONRPCService;
   import dBGlobals.DBGlobal;
   import events.FriendSummaryNewsFeedEvent;
   import facade.DBFacade;
   import facade.Locale;
   import generatedCode.DungeonReport;
   import flash.text.TextFormat;
   
    class UIReportPopup extends DBUIPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_score_report.swf";
      
      static inline final POPUP_CLASS_NAME= "popup_report";
      
      var mLeftButton:UIButton;
      
      var mLeftCallback:ASFunction;
      
      var mLeftButtonLabelText:String;
      
      var mRightButton:UIButton;
      
      var mRightCallback:ASFunction;
      
      var mRightButtonLabelText:String;
      
      var check_button_a:UIButton;
      
      var check_button_b:UIButton;
      
      var check_button_c:UIButton;
      
      var check_button_a_value:String = "Behaviour";
      
      var check_button_b_value:String = "VerbalAbuse";
      
      var check_button_c_value:String = "Cheating";
      
      var check_button_label_a:String;
      
      var check_button_label_b:String;
      
      var check_button_label_c:String;
      
      var mDungeonReport:Vector<DungeonReport>;
      
      var mSuccessCallback:ASFunction;
      
      var mMatchPlayers:Array<ASAny>;
      
      var mPersonName:String;
      
      var mSelectedButtonValuesArray:Array<ASAny>;
      
      public function new(param1:DBFacade, param2:String, param3:UInt, param4:Array<ASAny>, param5:ASFunction, param6:ASFunction)
      {
         var dbFacade= param1;
         var personName= param2;
         var personId= param3;
         var matchPlayers= param4;
         var reportedCallback= param5;
         var successCallback= param6;
         mSelectedButtonValuesArray = [];
         var titleText= Locale.getString("REPORT") + " " + personName + "?";
         var contentText= Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01") + personName + Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_02");
         check_button_label_a = Locale.getString("REPORT_REASON_BEHAVIOUR");
         check_button_label_b = Locale.getString("REPORT_REASON_VERBAL_ABUSE");
         check_button_label_c = Locale.getString("REPORT_REASON_CHEATING");
         mLeftCallback = null;
         mLeftButtonLabelText = Locale.getString("CANCEL");
         mRightCallback = function()
         {
            reportPlayer(personId,personName);
            reportedCallback();
         };
         mRightButtonLabelText = Locale.getString("REPORT");
         mMatchPlayers = matchPlayers;
         mPersonName = personName;
         mSuccessCallback = successCallback;
         super(dbFacade,titleText,contentText,true,true,null,false);
      }
      
      public function reportPlayer(param1:UInt, param2:String) 
      {
         var _loc3_= JSONRPCService.getFunction("ReportPlayer",mDBFacade.rpcRoot + "report");
         _loc3_({
            "reportingPlayerId":mDBFacade.dbAccountInfo.id,
            "reportingPlayerName":mDBFacade.dbAccountInfo.name,
            "reportedPlayerId":param1,
            "reportedPlayerName":param2,
            "reportReasons":selectedButtonValues,
            "matchPlayers":mMatchPlayers
         },mSuccessCallback);
      }
      
      override public function destroy() 
      {
         if(mLeftButton != null)
         {
            mLeftButton.destroy();
            mLeftButton = null;
         }
         if(mRightButton != null)
         {
            mRightButton.destroy();
            mRightButton = null;
         }
         mLeftButtonLabelText = null;
         mRightButtonLabelText = null;
         check_button_label_a = null;
         check_button_label_b = null;
         check_button_label_c = null;
         check_button_a_value = null;
         check_button_b_value = null;
         check_button_c_value = null;
         if(check_button_a != null)
         {
            check_button_a.destroy();
            check_button_a = null;
         }
         if(check_button_b != null)
         {
            check_button_b.destroy();
            check_button_b = null;
         }
         if(check_button_c != null)
         {
            check_button_c.destroy();
            check_button_c = null;
         }
         mMatchPlayers = null;
         mPersonName = null;
         mSelectedButtonValuesArray = null;
         mLeftCallback = null;
         mRightCallback = null;
         mSuccessCallback = null;
         mDungeonReport = null;
         super.destroy();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var tf:TextFormat;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         tf = new TextFormat();
         tf.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
         super.colorizeMessage(tf,Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01").length,Locale.getString("VICTORY_SCREEN_REPORT_POPUP_MESSAGE_01").length + mPersonName.length);
         ASCompat.setProperty((mPopup : ASAny).check_button_a_label, "text", check_button_label_a);
         check_button_a = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).check_button_a, flash.display.MovieClip));
         check_button_a.releaseCallback = function()
         {
            checkButtonCallback(check_button_a,check_button_a_value);
         };
         ASCompat.setProperty((mPopup : ASAny).check_button_b_label, "text", check_button_label_b);
         check_button_b = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).check_button_b, flash.display.MovieClip));
         check_button_b.releaseCallback = function()
         {
            checkButtonCallback(check_button_b,check_button_b_value);
         };
         ASCompat.setProperty((mPopup : ASAny).check_button_c_label, "text", check_button_label_c);
         check_button_c = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).check_button_c, flash.display.MovieClip));
         check_button_c.releaseCallback = function()
         {
            checkButtonCallback(check_button_c,check_button_c_value);
         };
         if(ASCompat.stringAsBool(mLeftButtonLabelText))
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", true);
            mLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).left_button, flash.display.MovieClip));
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mLeftButton.label.text = mLeftButtonLabelText;
            mLeftButton.releaseCallback = function()
            {
               close(mLeftCallback);
            };
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
         }
         if(ASCompat.stringAsBool(mRightButtonLabelText))
         {
            ASCompat.setProperty((mPopup : ASAny).right_button, "visible", true);
            mRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).right_button, flash.display.MovieClip));
            mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mRightButton.label.text = mRightButtonLabelText;
            mRightButton.releaseCallback = function()
            {
               close(mRightCallback);
            };
            mRightButton.enabled = false;
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
         }
      }
      
      function checkButtonCallback(param1:UIButton, param2:String) 
      {
         var _loc3_= 0;
         if(param1.selected)
         {
            param1.selected = false;
            _loc3_ = mSelectedButtonValuesArray.indexOf(param2);
            if(_loc3_ != -1)
            {
               mSelectedButtonValuesArray.splice(_loc3_,(1 : UInt));
            }
         }
         else
         {
            param1.selected = true;
            mSelectedButtonValuesArray.push(param2);
         }
         updateRightButtonState();
      }
      
      function updateRightButtonState() 
      {
         mRightButton.enabled = mSelectedButtonValuesArray.length > 0;
      }
      
      override function getClassName() : String
      {
         return "popup_report";
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      @:isVar public var selectedButtonValues(get,never):Array<ASAny>;
public function  get_selectedButtonValues() : Array<ASAny>
      {
         return mSelectedButtonValuesArray;
      }
   }


