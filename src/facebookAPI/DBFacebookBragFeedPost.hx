package facebookAPI
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.render.MovieClipRenderController;
   import brain.render.MovieClipRenderer;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMFeedPosts;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMMapNode;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMSkin;
   import town.TownHeader;
   import uI.popup.DBUIOneButtonPopup;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   
    class DBFacebookBragFeedPost
   {
      
      public function new()
      {
         
      }
      
      public static function buyHeroSuccess(param1:TownHeader, param2:GMHero, param3:DBFacade, param4:AssetLoadingComponent) 
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var townHeader= param1;
         var gmHero= param2;
         var facade= param3;
         var assetLoadingComponent= param4;
         var popupTitle= Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Float = 0.4;
         if(facade.isDRPlayer)
         {
            if(facade.steamAchievementsManager != null)
            {
               facade.steamAchievementsManager.setAchievement(facade.steamAchievementsManager.findUnlockHeroAchievementAPIName(gmHero));
            }
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var tooltipClass= swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClassName= "avatar_purchase_popup";
            var gloatPopupClass= swfAsset.getClass(gloatPopupClassName);
            gloatPopup = ASCompat.dynamicAs(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmHero.PortraitName),function(param1:brain.assetRepository.SwfAsset)
            {
               var TeamBonusUI:UIObject;
               var teamBonusUIMCRenderer:MovieClipRenderer;
               var TeamBonusUIHeader:UIObject;
               var teamBonusUIHeaderMCRenderer:MovieClipRenderer;
               var onCompleteFunc:ASFunction = null;
               var onCompleteHeaderFunc:ASFunction = null;
               var popup:DBUIOneButtonPopup;
               var swfAsset= param1;
               var picClass= swfAsset.getClass(gmHero.IconName);
               var avatarPic= ASCompat.dynamicAs(ASCompat.createInstance(picClass, []), flash.display.MovieClip);
               var movieClipRenderer= new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               if(ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0)
               {
                  (gloatPopup : ASAny).avatar.removeChildAt(0);
               }
               (gloatPopup : ASAny).avatar.addChildAt(avatarPic,0);
               ASCompat.setProperty((gloatPopup : ASAny).gloat_text, "text", Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmHero.Name.toUpperCase());
               TeamBonusUI = new UIObject(facade,ASCompat.dynamicAs((gloatPopup : ASAny).crewbonus, flash.display.MovieClip));
               ASCompat.setProperty((TeamBonusUI.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
               ASCompat.setProperty((TeamBonusUI.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
               ASCompat.setProperty((TeamBonusUI.root : ASAny).header_crew_bonus_number, "text", facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2);
               teamBonusUIMCRenderer = new MovieClipRenderer(facade,ASCompat.dynamicAs((TeamBonusUI.root : ASAny).header_crew_bonus_anim, flash.display.MovieClip),onCompleteFunc);
               teamBonusUIMCRenderer.play();
               TeamBonusUIHeader = new UIObject(facade,ASCompat.dynamicAs((gloatPopup : ASAny).crewbonus_header, flash.display.MovieClip));
               ASCompat.setProperty((TeamBonusUIHeader.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
               ASCompat.setProperty((TeamBonusUIHeader.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
               ASCompat.setProperty((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number, "text", facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2);
               teamBonusUIHeaderMCRenderer = new MovieClipRenderer(facade,ASCompat.dynamicAs((TeamBonusUIHeader.root : ASAny).header_crew_bonus_anim, flash.display.MovieClip),onCompleteHeaderFunc);
               teamBonusUIHeaderMCRenderer.play();
               onCompleteFunc = function()
               {
                  ASCompat.setProperty((TeamBonusUI.root : ASAny).header_crew_bonus_number, "text", facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
               };
               onCompleteHeaderFunc = function()
               {
                  ASCompat.setProperty((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number, "text", facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
               };
               TweenMax.to((TeamBonusUI.root : ASAny).header_crew_bonus_number,1.4,{"onComplete":onCompleteFunc});
               TweenMax.to((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number,1.4,{"onComplete":onCompleteHeaderFunc});
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function()
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmHero.Id);
                  }
                  TeamBonusUI.destroy();
                  TeamBonusUI = null;
                  TeamBonusUIHeader.destroy();
                  TeamBonusUIHeader = null;
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buyHeroSuccess()");
               popup.root.x = 100;
               popup.root.y = -180;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x -= 150 * avatarPicScale;
               townHeader.updateTeamBonusUI();
            });
         });
      }
      
      public static function buySkinSuccess(param1:GMSkin, param2:DBFacade, param3:AssetLoadingComponent) 
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var gmSkin= param1;
         var facade= param2;
         var assetLoadingComponent= param3;
         var popupTitle= Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Float = 0.45;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var tooltipClass= swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass= swfAsset.getClass("tavern_gloat");
            gloatPopup = ASCompat.dynamicAs(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:brain.assetRepository.SwfAsset)
            {
               var popup:DBUIOneButtonPopup;
               var swfAsset= param1;
               var picClass= swfAsset.getClass(gmSkin.IconName);
               var avatarPic= ASCompat.dynamicAs(ASCompat.createInstance(picClass, []), flash.display.MovieClip);
               var movieClipRenderer= new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x -= 150 * avatarPicScale;
               if(ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0)
               {
                  (gloatPopup : ASAny).avatar.removeChildAt(0);
               }
               (gloatPopup : ASAny).avatar.addChildAt(avatarPic,0);
               ASCompat.setProperty((gloatPopup : ASAny).gloat_text, "text", Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmSkin.Name.toUpperCase());
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function()
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmSkin.Id);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buySkinSuccess()");
            });
         });
      }
      
      public static function buyPetSuccess(param1:GMNpc, param2:DBFacade, param3:AssetLoadingComponent) 
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var gmPet= param1;
         var facade= param2;
         var assetLoadingComponent= param3;
         var popupTitle= Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Float = 1;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var tooltipClass= swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass= swfAsset.getClass("tavern_gloat");
            gloatPopup = ASCompat.dynamicAs(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmPet.IconSwfFilepath),function(param1:brain.assetRepository.SwfAsset)
            {
               var popup:DBUIOneButtonPopup;
               var swfAsset= param1;
               var picClass= swfAsset.getClass(gmPet.IconName);
               var avatarPic= ASCompat.dynamicAs(ASCompat.createInstance(picClass, []), flash.display.MovieClip);
               var movieClipRenderer= new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x = 0;
               if(ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0)
               {
                  (gloatPopup : ASAny).avatar.removeChildAt(0);
               }
               (gloatPopup : ASAny).avatar.addChildAt(avatarPic,0);
               ASCompat.setProperty((gloatPopup : ASAny).gloat_text, "text", Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TEXT") + gmPet.Name.toUpperCase());
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function()
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmPet.Id);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buyPetSuccess()");
            });
         });
      }
      
      public static function openChestBrag(param1:DBFacade, param2:String, param3:String, param4:MovieClip, param5:String, param6:UInt, param7:AssetLoadingComponent) 
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var facade= param1;
         var shortItemName= param2;
         var fullItemName= param3;
         var itemPic= param4;
         var imagePath= param5;
         var itemType= param6;
         var assetLoadingComponent= param7;
         var popupTitle= Locale.getString("BRAG_CHEST_OPEN_POPUP_TITLE");
         var picScale:Float = 1;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_CHEST_OPEN_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var movieClipRenderer:MovieClipRenderController;
            var popup:DBUIOneButtonPopup;
            var swfAsset= param1;
            var tooltipClass= swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass= swfAsset.getClass("tavern_gloat");
            gloatPopup = ASCompat.dynamicAs(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
            gloatPopup.x += 40;
            movieClipRenderer = new MovieClipRenderController(facade,itemPic);
            movieClipRenderer.play();
            itemPic.scaleX = itemPic.scaleY = picScale;
            itemPic.y = 0;
            itemPic.x = 0;
            if(ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0)
            {
               (gloatPopup : ASAny).avatar.removeChildAt(0);
            }
            (gloatPopup : ASAny).avatar.addChildAt(itemPic,0);
            ASCompat.setProperty((gloatPopup : ASAny).gloat_text, "text", Locale.getString("BRAG_CHEST_OPEN_POPUP_TEXT") + fullItemName.toUpperCase());
            popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function()
            {
               if(!facade.isDRPlayer)
               {
                  facade.facebookController.chestUnlockFeedPost(itemType,shortItemName,fullItemName,imagePath);
               }
            });
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.openChestBrag()");
         });
      }
      
      public static function defeatMapNodeBrag(param1:DBFacade, param2:GMMapNode, param3:AssetLoadingComponent) 
      {
         var gloatPopup:MovieClip;
         var popupTitle:String;
         var popupCenterButtonText:String;
         var picScale:Float;
         var itemPic:Bitmap;
         var facade= param1;
         var gmMapNode= param2;
         var assetLoadingComponent= param3;
         var feedPosts= DBFacebookAPIController.getFeedPosts(facade,gmMapNode.Id,"MAP_NODE_DEFEATED");
         if(feedPosts.length == 0)
         {
            return;
         }
         popupTitle = Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_TITLE");
         picScale = 1.25;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var feedPosts:Vector<GMFeedPosts>;
            var swfAsset= param1;
            var tooltipClass= swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass= swfAsset.getClass("tavern_gloat");
            gloatPopup = ASCompat.dynamicAs(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
            gloatPopup.x += 40;
            feedPosts = DBFacebookAPIController.getFeedPosts(facade,gmMapNode.Id,"MAP_NODE_DEFEATED");
            assetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath(feedPosts[0].FeedImageLink),function(param1:brain.assetRepository.ImageAsset)
            {
               var popup:DBUIOneButtonPopup;
               var imageAsset= param1;
               itemPic = imageAsset.image;
               itemPic.scaleX = itemPic.scaleY = picScale;
               itemPic.y = -itemPic.height * 0.5;
               itemPic.x = -itemPic.width * 0.5;
               if(ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0)
               {
                  (gloatPopup : ASAny).avatar.removeChildAt(0);
               }
               (gloatPopup : ASAny).avatar.addChildAt(itemPic,0);
               ASCompat.setProperty((gloatPopup : ASAny).gloat_text, "text", Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_TEXT") + gmMapNode.Name.toUpperCase());
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function()
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.mapNodeDefeatedFeedPost(gmMapNode.Id,gmMapNode.Name);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.defeatMapNodeBrag()");
            });
         });
      }
   }


