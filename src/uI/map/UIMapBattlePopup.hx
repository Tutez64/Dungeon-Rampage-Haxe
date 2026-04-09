package uI.map
;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMColiseumTier;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMMapNode;
   import gameMasterDictionary.GMSkin;
   import uI.DBUIPopup;
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
      
      static final BATTLE_POPUP_POSITION:Point = new Point(250,0);
      
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
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction, param4:ASFunction, param5:ASFunction, param6:String)
      {
         mBattleReleaseCallback = param5;
         mChangeHeroReleaseCallback = param2;
         mChangeStatReleaseCallback = param3;
         mChangeShopReleaseCallback = param4;
         super(param1,param6,null,true,false);
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
         mPrivateButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).radio_button, flash.display.MovieClip));
         mPrivateButton.releaseCallback = togglePrivate;
         mPrivateButton.selected = IsPrivate;
         activeHeroSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         gmHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(activeHeroSkin.ForHero), gameMasterDictionary.GMHero);
         ASCompat.setProperty((mPopup : ASAny).txt_avatar, "text", gmHero.Name.toUpperCase());
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
         mChangeHeroButton.releaseCallback = mChangeHeroReleaseCallback;
         mChangeHeroButton.rollOverCursor = "POINT";
         ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseChildren", false);
         ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseEnabled", false);
         mBattleButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).button_battle, flash.display.MovieClip));
         mBattleButton.dontKillMyChildren = true;
         if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
         {
            mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.");
            mBattleButton.releaseCallback = function()
            {
               mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.");
               mDBFacade.metrics.log("NoWeaponsEquippedWarning");
            };
         }
         else
         {
            mBattleButton.releaseCallback = mBattleReleaseCallback;
         }
         mBattleButton.rollOverCursor = "POINT";
         if(mCloseButton != null)
         {
            mCloseButton.dontKillMyChildren = true;
            mCloseButton.releaseCallback = this.animatePopupOut;
            mCloseButton.rollOverCursor = "POINT";
         }
         if(ASCompat.toBool((mPopup : ASAny).crewbonus))
         {
            mTeamBonusUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).crewbonus, flash.display.MovieClip));
            ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
            ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
            ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_number, "text", mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
            ASCompat.setProperty((mPopup : ASAny).crewBonus_label, "text", Std.string(((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1) * 5)) + Locale.getString("TEAM_BONUS_BATTLE_POPUP_TEXT"));
         }
         setDungeonDetails();
      }
      
      override function handleKeyDown(param1:KeyboardEvent) 
      {
         if(param1.keyCode == 27)
         {
            this.animatePopupOut();
         }
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
         setTitle(mCurrentDungeon.Name.toUpperCase());
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
            setDifficulty(mCurrentDungeon.DifficultyName);
         }
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
         if(mPopup == null)
         {
            return;
         }
         mPopup.visible = true;
         if(!mCurtainActive)
         {
            makeCurtain();
         }
         var _loc1_= BATTLE_POPUP_POSITION.x;
         var _loc2_= BATTLE_POPUP_POSITION.y;
         mPopup.x = 730;
         mPopup.y = _loc2_;
         TweenMax.killTweensOf(mPopup);
         new TimelineMax({
            "tweens":[TweenMax.to(mPopup,0.25,{
               "x":_loc1_,
               "y":_loc2_
            })],
            "align":"sequence"
         });
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
      }
   }


