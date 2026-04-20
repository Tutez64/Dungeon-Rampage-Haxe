package uI.map
;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMColiseumTier;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMMapNode;
   import gameMasterDictionary.GMSkin;
   import uI.popup.DBUIPopup;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   
    class UIMapBattlePopup extends DBUIPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final POPUP_CLASS_NAME= "battle_popup";
      
      static inline final POPUP_CLASS_NAME_CONSUMABLES= "battle_popup_consumables";
      
      static inline final DELAY_AMOUNT_FOR_TRANSITIONING_BACK_TO_MAP_MENU_FROM_TAVERN= (0 : UInt);
      
      static final BATTLE_POPUP_POSITION:Point = new Point(250,0);
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mActiveStacks:Vector<UIButton>;
      
      var mActiveHeroPortrait:MovieClip;
      
      var mMapNodeOpen:Bool = false;
      
      var mCurrentDungeon:GMMapNode;
      
      var mBattleButton:UIButton;
      
      var mChangeHeroButton:UIButton;
      
      var mChangeStatButton:UIButton;
      
      var mChangeStatReleaseCallback:ASFunction;
      
      var mChangeHeroReleaseCallback:ASFunction;
      
      var mChangeShopReleaseCallback:ASFunction;
      
      var mBattleReleaseCallback:ASFunction;
      
      var mPrivateButton:UIButton;
      
      public var IsPrivate:Bool = false;
      
      var mTeamBonusUI:UIObject;
      
      var isPopupActive:Bool = false;
      
      var mPopupNavigationLinkDelay:Task;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction, param4:ASFunction, param5:ASFunction, param6:String)
      {
         mBattleReleaseCallback = param5;
         mChangeHeroReleaseCallback = param2;
         mChangeStatReleaseCallback = param3;
         mChangeShopReleaseCallback = param4;
         super(param1,param6,null,true,false);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIMapBattlePopup");
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "battle_popup_consumables";
      }
      
      function togglePrivate() 
      {
         IsPrivate = !IsPrivate;
         mPrivateButton.selected = IsPrivate;
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var activeHeroSkin:GMSkin;
         var gmHero:GMHero;
         var currentXp:Int;
         var level:UInt;
         var levelIndex:UInt;
         var lastLevelExp:UInt;
         var max:UInt;
         var xpBar:UIProgressBar;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.visible = false;
         if(ASCompat.toBool((mPopup : ASAny).text_activeBooster))
         {
            ASCompat.setProperty((mPopup : ASAny).text_activeBooster, "text", Locale.getString("WORLD_MAP_STATS"));
         }
         if(ASCompat.toBool((mPopup : ASAny).text_victorRewards))
         {
            ASCompat.setProperty((mPopup : ASAny).text_victorRewards, "text", Locale.getString("WORLD_MAP_VICTORY_REWARDS"));
         }
         ASCompat.setProperty((mPopup : ASAny).private_dungeon_label, "text", Locale.getString("PRIVATE_DUNGEON_LABEL"));
         ASCompat.setProperty((mPopup : ASAny).population_label, "text", Locale.getString("PLAYER_ACTIVITY_POPULATION"));
         mPrivateButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).radio_button, flash.display.MovieClip));
         mPrivateButton.releaseCallback = togglePrivate;
         mPrivateButton.selected = IsPrivate;
         activeHeroSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         gmHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(activeHeroSkin.ForHero), gameMasterDictionary.GMHero);
         ASCompat.setProperty((mPopup : ASAny).txt_avatar, "text", GameMasterLocale.getGameMasterSubString("SKIN_NAME",gmHero.Constant).toUpperCase());
         mActiveHeroPortrait = ASCompat.dynamicAs((mPopup : ASAny).avatarContainer.avatar, flash.display.MovieClip);
         currentXp = mDBFacade.dbAccountInfo.activeAvatarInfo.experience;
         level = gmHero.getLevelFromExp((currentXp : UInt));
         levelIndex = (gmHero.getLevelIndex(currentXp) : UInt);
         lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
         max = gmHero.getExpFromIndex(levelIndex);
         if((currentXp : UInt) < max)
         {
            xpBar = new UIProgressBar(mFacade,ASCompat.dynamicAs((mPopup : ASAny).UI_XP.xp_bar, flash.display.MovieClip));
            ASCompat.setProperty((mPopup : ASAny).UI_XP.xp_bar_delta, "visible", false);
            ASCompat.setProperty((mPopup : ASAny).UI_XP.xp_points, "text", currentXp + "/" + max);
            xpBar.maximum = max;
            xpBar.minimum = lastLevelExp;
            xpBar.value = currentXp;
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).UI_XP.xp_points, "text", Std.string(currentXp));
         }
         ASCompat.setProperty((mPopup : ASAny).UI_XP.xp_level, "text", level);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(activeHeroSkin.PortraitName),function(param1:SwfAsset)
         {
            var _loc3_= param1.getClass(activeHeroSkin.CardName);
            if(_loc3_ == null)
            {
               return;
            }
            var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            if(mActiveHeroPortrait.numChildren > 0)
            {
               mActiveHeroPortrait.removeChildAt(0);
            }
            mActiveHeroPortrait.addChildAt(_loc4_,0);
         });
         mChangeHeroButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).button_swapAvatar, flash.display.MovieClip));
         mChangeHeroButton.dontKillMyChildren = true;
         mChangeHeroButton.releaseCallback = function()
         {
            mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
            mChangeHeroReleaseCallback();
         };
         mChangeHeroButton.rollOverCursor = "POINT";
         ASCompat.setProperty((mChangeHeroButton.root : ASAny).swap, "text", Locale.getString("WORLD_MAP_CHANGE_HERO_BUTTON"));
         ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseChildren", false);
         ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseEnabled", false);
         mBattleButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).button_battle, flash.display.MovieClip));
         mBattleButton.dontKillMyChildren = true;
         if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
         {
            mBattleButton.releaseCallback = function()
            {
               mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.","NO_WEAPONS_DUNGEON_ERROR_POPUP");
               mDBFacade.metrics.log("NoWeaponsEquippedWarning");
            };
         }
         else
         {
            mBattleButton.releaseCallback = function()
            {
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
               mBattleReleaseCallback();
            };
         }
         mBattleButton.rollOverCursor = "POINT";
         if(mCloseButton != null)
         {
            mCloseButton.dontKillMyChildren = true;
            mCloseButton.releaseCallback = function()
            {
               animatePopupOut();
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
            };
            mCloseButton.rollOverCursor = "POINT";
         }
         if(ASCompat.toBool((mPopup : ASAny).crewbonus))
         {
            mTeamBonusUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).crewbonus, flash.display.MovieClip));
            ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
            ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
            ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_txt1, "text", Locale.getString("TEAM_BONUS_TITLE_CREW"));
            ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_txt2, "text", Locale.getString("TEAM_BONUS_TITLE_BONUS"));
            ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_number, "text", mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
            ASCompat.setProperty((mPopup : ASAny).crewBonus_label, "text", Std.string(((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1) * 5)) + Locale.getString("TEAM_BONUS_BATTLE_POPUP_TEXT"));
         }
         setDungeonDetails();
         setupMenuNavigation();
      }
      
      override function handleKeyDown(param1:KeyboardEvent) 
      {
      }
      
      override public function destroy() 
      {
         super.destroy();
         if(mTeamBonusUI != null)
         {
            mTeamBonusUI.destroy();
         }
         if(mBattleButton != null)
         {
            mBattleButton.destroy();
            mBattleButton = null;
         }
         if(mChangeHeroButton != null)
         {
            mChangeHeroButton.destroy();
            mChangeHeroButton = null;
         }
         if(mChangeStatButton != null)
         {
            mChangeStatButton.destroy();
            mChangeStatButton = null;
         }
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         if(mPopupNavigationLinkDelay != null)
         {
            mPopupNavigationLinkDelay.destroy();
            mPopupNavigationLinkDelay = null;
         }
      }
      
      @:isVar public var battleButton(get,never):UIButton;
public function  get_battleButton() : UIButton
      {
         return mBattleButton;
      }
      
      public function setTitle(param1:String) 
      {
         if(mPopup != null && ASCompat.toBool((mPopup : ASAny).title_label))
         {
            ASCompat.setProperty((mPopup : ASAny).title_label, "text", param1);
         }
      }
      
      public function setDifficulty(param1:String) 
      {
         if(mPopup != null && ASCompat.toBool((mPopup : ASAny).text_recommendedLevel))
         {
            ASCompat.setProperty((mPopup : ASAny).text_recommendedLevel, "text", param1);
         }
      }
      
      @:isVar public var mapNodeOpen(never,set):Bool;
public function  set_mapNodeOpen(param1:Bool) :Bool      {
         return mMapNodeOpen = param1;
      }
      
      @:isVar public var currentDungeon(never,set):GMMapNode;
public function  set_currentDungeon(param1:GMMapNode) :GMMapNode      {
         return mCurrentDungeon = param1;
      }
      
      public function setDungeonDetails() 
      {
         var _loc2_:GMColiseumTier = null;
         var _loc1_:String = null;
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         if(mDBFacade != null && mDBFacade.gameMaster != null && mDBFacade.gameMaster.coliseumTierByConstant != null)
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mCurrentDungeon.TierRank), gameMasterDictionary.GMColiseumTier);
         }
         if(_loc2_ != null && ASCompat.toBool((mPopup : ASAny).dungeonXp_label))
         {
            ASCompat.setProperty((mPopup : ASAny).dungeonXp_label, "text", Std.string(mCurrentDungeon.CompletionXPBonus) + Locale.getString("WORLD_MAP_BONUS_XP"));
         }
         ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text.battle_text, "text", Locale.getString("WORLD_MAP_UNLOCK"));
         setTitle(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",mCurrentDungeon.Constant).toUpperCase());
         if(_loc2_.TotalFloors > 0 && mCurrentDungeon.NodeType != "BOSS")
         {
            _loc1_ = _loc2_.TotalFloors > 1 ? Locale.getString("FLOORS").toUpperCase() : Locale.getString("FLOOR").toUpperCase();
            if(_loc2_.TotalFloors >= 50)
            {
               setDifficulty("INFINITE " + _loc1_);
            }
            else
            {
               setDifficulty(Std.string(_loc2_.TotalFloors) + " " + _loc1_);
            }
         }
         else
         {
            setDifficulty(GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME",mCurrentDungeon.Constant));
         }
         ASCompat.setProperty((mPopup : ASAny).activity_label, "text", mDBFacade.playerActivityCount.getActivityString((mCurrentDungeon.Id : Int)));
      }
      
      @:isVar public var keyCostClip(get,never):MovieClip;
public function  get_keyCostClip() : MovieClip
      {
         if(mPopup != null)
         {
            return ASCompat.dynamicAs((mPopup : ASAny).basic_key_icon, flash.display.MovieClip);
         }
         return null;
      }
      
      public function animatePopupIn() 
      {
         var destX:Float;
         var destY:Float;
         if(mPopup == null)
         {
            return;
         }
         mPopup.visible = true;
         if(!mCurtainActive)
         {
            makeCurtain();
         }
         destX = BATTLE_POPUP_POSITION.x;
         destY = BATTLE_POPUP_POSITION.y;
         mPopup.x = 730;
         mPopup.y = destY;
         TweenMax.killTweensOf(mPopup);
         new TimelineMax({
            "tweens":[TweenMax.to(mPopup,0.25,{
               "x":destX,
               "y":destY
            })],
            "align":"sequence"
         });
         isPopupActive = true;
         if(mPopupNavigationLinkDelay != null)
         {
            mPopupNavigationLinkDelay.destroy();
         }
         mPopupNavigationLinkDelay = mLogicalWorkComponent.doLater(0,function(param1:brain.clock.GameClock)
         {
            var gameclock= param1;
            mDBFacade.menuNavigationController.pushNewLayer("UI_MAP_BATTLE_POPUP",function()
            {
               mDBFacade.menuNavigationController.popLayer("UI_MAP_BATTLE_POPUP");
               animatePopupOut();
            },mBattleButton,mBattleButton);
         });
         DBGlobal.highlightButton(mBattleButton);
      }
      
      public function animatePopupOut(param1:Bool = false) 
      {
         var destX:Float;
         var destY:Float;
         var startX:Float;
         var hidePopup:ASFunction;
         var keepCurtain= param1;
         if(mPopup == null)
         {
            return;
         }
         isPopupActive = false;
         if(mCurtainActive && !keepCurtain)
         {
            removeCurtain();
         }
         destX = 1440;
         destY = BATTLE_POPUP_POSITION.y;
         startX = BATTLE_POPUP_POSITION.x;
         mPopup.x = startX;
         mPopup.y = destY;
         hidePopup = function()
         {
            if(mPopup != null)
            {
               mPopup.visible = false;
            }
         };
         TweenMax.killTweensOf(mPopup);
         new TimelineMax({
            "tweens":[TweenMax.to(mPopup,0.25,{
               "x":destX,
               "y":destY,
               "onComplete":hidePopup
            })],
            "align":"sequence"
         });
         removeButtonFilters();
      }
      
      override function setupMenuNavigation() 
      {
         mPrivateButton.isAbove(mBattleButton);
         mCloseButton.isAbove(mPrivateButton);
         mChangeHeroButton.isToTheLeftOf(mBattleButton);
         setButtonFilters();
      }
      
      public function setButtonFilters() 
      {
         DBGlobal.highlightButton(mBattleButton);
         mBattleButton.upNavigationAdditionalInteraction = function()
         {
            DBGlobal.highlightButton(mPrivateButton);
            DBGlobal.unHighlightButton(mBattleButton);
         };
         mPrivateButton.downNavigationAdditionalInteraction = function()
         {
            DBGlobal.unHighlightButton(mPrivateButton);
            DBGlobal.highlightButton(mBattleButton);
         };
         mPrivateButton.upNavigationAdditionalInteraction = function()
         {
            DBGlobal.unHighlightButton(mPrivateButton);
         };
         mBattleButton.leftNavigationAdditionalInteraction = function()
         {
            DBGlobal.unHighlightButton(mBattleButton);
            DBGlobal.highlightButton(mChangeHeroButton);
         };
         mChangeHeroButton.rightNavigationAdditionalInteraction = function()
         {
            DBGlobal.unHighlightButton(mChangeHeroButton);
            DBGlobal.highlightButton(mBattleButton);
         };
         mCloseButton.downNavigationAdditionalInteraction = function()
         {
            DBGlobal.highlightButton(mPrivateButton);
         };
      }
      
      public function removeButtonFilters() 
      {
         mBattleButton.setFocused(false);
         mPrivateButton.setFocused(false);
         mChangeHeroButton.setFocused(false);
         mCloseButton.setFocused(false);
      }
   }


