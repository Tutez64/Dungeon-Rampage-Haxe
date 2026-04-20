package uI.friendManager
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIRadioButton;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import town.TownHeader;
   import town.TownStateMachine;
   import uI.friendManager.states.UIBlocked;
   import uI.friendManager.states.UIFriends;
   import uI.friendManager.states.UIInvite;
   import uI.friendManager.states.UIPending;
   import uI.uINewsFeed.UINewsFeedController;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UIFriendManager
   {
      
      public static inline final ERROR_TOO_MANY_FRIENDS= -290;
      
      public static inline final STATE_FRIENDS= (1 : UInt);
      
      public static inline final STATE_PENDING= (2 : UInt);
      
      public static inline final STATE_BLOCKED= (3 : UInt);
      
      public static inline final STATE_INVITE= (4 : UInt);
      
      public static var FRIENDSHIP_MADE:String = "FRIENDSHIP_MADE";
      
      var mDBFacade:DBFacade;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mRoot:MovieClip;
      
      var mTownHeader:TownHeader;
      
      var mSwfAsset:SwfAsset;
      
      public var states:Map;
      
      public var currentState:Int = -1;
      
      var mTabButtons:Map;
      
      var mStateLayer:MovieClip;
      
      var mAlert:MovieClip;
      
      var mAlertRenderer:MovieClipRenderController;
      
      var mNewsFeedController:UINewsFeedController;
      
      public function new(param1:DBFacade, param2:TownStateMachine, param3:MovieClip)
      {
         
         mDBFacade = param1;
         mSwfAsset = param2.townSwf;
         mTownHeader = param2.townHeader;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIFriendManager");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIFriendManager");
         states = new Map();
         states.add(1,new UIFriends(this,mDBFacade,param2));
         states.add(4,new UIInvite(this,mDBFacade,param2));
         states.add(2,new UIPending(this,mDBFacade,param2));
         states.add(3,new UIBlocked(this,mDBFacade,param2));
         if(mNewsFeedController == null)
         {
            mNewsFeedController = new UINewsFeedController(mDBFacade);
         }
         mNewsFeedController.startFeedTask();
         setupUI(param3);
      }
      
      public static function createFriendRPCErrorCallback(param1:DBFacade, param2:String) : ASFunction
      {
         var dbFacade= param1;
         var contextName= param2;
         return function(param1:Error)
         {
            handleFriendError(param1,dbFacade,contextName);
         };
      }
      
      public static function handleFriendError(param1:Error, param2:DBFacade, param3:String = null) 
      {
         var _loc4_= ASCompat.stringAsBool(param3) ? param3 : "FriendRPC";
         if(param1.errorID == -290)
         {
            Logger.warn(_loc4_ + " failed with too many friends: " + Std.string(param1.message));
            param2.errorPopup(Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_TITLE"),Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_DESC") + Std.string(param1.message));
         }
         else
         {
            Logger.error(_loc4_ + " failed with error code: " + param1.errorID + " and message: " + Std.string(param1.message),param1);
         }
      }
      
      function setupUI(param1:MovieClip) 
      {
         var tabButton:UIRadioButton;
         var tabInt:UInt;
         var iter:IMapIterator;
         var rootClip= param1;
         mRoot = rootClip;
         mTabButtons = new Map();
         var group= "UIFriendsTabGroup";
         mTabButtons.add(1,new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_friends, flash.display.MovieClip),group));
         mTabButtons.add(4,new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_invite, flash.display.MovieClip),group));
         mTabButtons.add(2,new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_pending, flash.display.MovieClip),group));
         mTabButtons.add(3,new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_blocked, flash.display.MovieClip),group));
         iter = ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(iter.hasNext())
         {
            tabButton = ASCompat.dynamicAs(iter.next(), brain.uI.UIRadioButton);
            tabInt = (ASCompat.toInt(iter.key) : UInt);
            tabButton.label.text = Locale.getString("FRIEND_MANAGEMENT_TAB_" + Std.string(tabInt));
            ASCompat.setProperty(tabButton.root, "category", tabInt);
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", false);
            tabButton.releaseCallbackThis = function(param1:brain.uI.UIButton)
            {
               changeTab(ASCompat.reinterpretAs(param1 , UIRadioButton));
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mStateLayer = new MovieClip();
         mRoot.addChild(mStateLayer);
         mAlert = ASCompat.dynamicAs((mRoot : ASAny).tab_pending.alert_icon, flash.display.MovieClip);
         mAlertRenderer = new MovieClipRenderController(mDBFacade,mAlert);
         mAlertRenderer.play((0 : UInt),true);
         mAlert.visible = false;
      }
      
      public function enableTabButton(param1:UInt) 
      {
         var _loc2_= ASCompat.dynamicAs(mTabButtons.itemFor(param1), brain.uI.UIRadioButton);
         _loc2_.root.filters = cast([new ColorMatrixFilter()]);
         if(param1 == 2)
         {
         }
      }
      
      public function disableTabButton(param1:UInt) 
      {
         var _loc2_= ASCompat.dynamicAs(mTabButtons.itemFor(param1), brain.uI.UIRadioButton);
         var _loc3_:Float = 0.212671;
         var _loc5_:Float = 0.71516;
         var _loc4_:Float = 0.072169;
         var _loc6_:Array<ASAny> = [];
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([0,0,0,1,0]);
         _loc2_.root.filters = cast([new ColorMatrixFilter(cast(_loc6_))]);
      }
      
      public function init(param1:UInt) 
      {
         ASCompat.setProperty(mTabButtons.itemFor(param1), "selected", true);
         changeState(param1);
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:brain.clock.GameClock)
            {
               mTownHeader.animateHeader();
            });
         }
      }
      
      public function changeTab(param1:UIRadioButton) 
      {
         var radioButton= param1;
         var wrappedCallBack:ASFunction = function()
         {
            changeState((ASCompat.toInt((radioButton.root : ASAny).category) : UInt));
         };
         wrappedCallBack();
      }
      
      public function changeState(param1:UInt) 
      {
         if((currentState : UInt) == param1)
         {
            return;
         }
         if(currentState > -1)
         {
            states.itemFor(currentState).exit();
         }
         currentState = (param1 : Int);
         states.itemFor(currentState).enter();
      }
      
      public function updateHeading(param1:String) 
      {
         ASCompat.setProperty((mRoot : ASAny).avatar_heading_text, "text", param1);
      }
      
      public function updateDescription(param1:String, param2:Bool = false) 
      {
         ASCompat.setProperty((mRoot : ASAny).avatar_description_text, "text", param1);
         ASCompat.setProperty((mRoot : ASAny).avatar_description_text, "selectable", param2);
      }
      
      public function cleanUp() 
      {
         if(currentState > -1)
         {
            states.itemFor(currentState).exit();
            currentState = -1;
         }
      }
      
      @:isVar public var alert(never,set):Bool;
public function  set_alert(param1:Bool) :Bool      {
         return mAlert.visible = param1;
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      public function addToUI(param1:MovieClip) 
      {
         mStateLayer.addChild(param1);
      }
      
      public function removeFromUI(param1:MovieClip) 
      {
         mStateLayer.removeChild(param1);
      }
      
      public function clearUI() 
      {
         while(mStateLayer.numChildren > 0)
         {
            mStateLayer.removeChild(mStateLayer.getChildAt(mStateLayer.numChildren - 1));
         }
      }
      
      public function setPendingList(param1:Array<ASAny>) 
      {
         Logger.debug("setPending");
         if(ASCompat.mapItemForNeNull(states, 2))
         {
            ASCompat.setProperty(states.itemFor(2), "pendingFriendRequests", param1);
         }
      }
      
      public function destroy() 
      {
         var _loc2_:UIRadioButton = null;
         var _loc1_= ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.uI.UIRadioButton);
            _loc2_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
            mAlertRenderer = null;
         }
         cleanUp();
         states = null;
         mDBFacade = null;
         mSwfAsset = null;
         mTownHeader = null;
         mNewsFeedController.stopFeedTask();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         mLogicalWorkComponent.destroy();
      }
   }


