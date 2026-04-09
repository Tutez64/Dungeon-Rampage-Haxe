package uI.inventory
;
   import account.ChestInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import distributedObjects.DistributedDungeonSummary;
   import facade.DBFacade;
   import gameMasterDictionary.GMChest;
   import flash.display.MovieClip;
   
    class DungeonRewardPanel
   {
      
      var mDungeonSummary:DistributedDungeonSummary;
      
      var mRewardPanel:MovieClip;
      
      var mDBFacade:DBFacade;
      
      var mSelectedCallback:ASFunction;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mDungeonRewardElements:Vector<DungeonRewardElement>;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:DistributedDungeonSummary, param4:ASFunction)
      {
         
         mDBFacade = param1;
         mRewardPanel = param2;
         mDungeonSummary = param3;
         mSelectedCallback = param4;
         populateRewardPanel();
      }
      
      function populateRewardPanel() 
      {
         var _loc2_:DungeonRewardElement = null;
         var _loc3_:ChestInfo = null;
         var _loc5_= 0;
         var _loc4_= 0;
         clearRewardPanel();
         mDungeonRewardElements = new Vector<DungeonRewardElement>();
         var _loc1_= mDungeonSummary.report[0];
         ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1, "visible", true);
         ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2, "visible", true);
         ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3, "visible", true);
         if(mDungeonSummary.isSingleChestList[0])
         {
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1, "visible", false);
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2, "visible", false);
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3.select, "visible", false);
         }
         else
         {
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_1.select, "visible", false);
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_2.select, "visible", false);
            ASCompat.setProperty((mRewardPanel : ASAny).equip_slot_3, "visible", false);
         }
         var _loc6_:Array<ASAny> = [_loc1_.chest_type_1,_loc1_.chest_type_2,_loc1_.chest_type_3,_loc1_.chest_type_4];
         ASCompat.ASArray.sort(_loc6_, mDungeonSummary.compareChestTypes);
         _loc5_ = (_loc1_.chest_type_1 : Int);
         _loc4_ = (_loc1_.chest_type_2 : Int);
         _loc5_ = ASCompat.toInt(_loc6_[0]);
         _loc4_ = ASCompat.toInt(_loc6_[1]);
         if(_loc5_ > 0)
         {
            _loc3_ = new ChestInfo(mDBFacade,null);
            _loc3_.setParams((_loc5_ : UInt));
            _loc3_.setFromDungeonSummary();
            if(mDungeonSummary.isSingleChestList[0])
            {
               _loc2_ = new DungeonRewardElement(mDBFacade,ASCompat.dynamicAs((mRewardPanel : ASAny).equip_slot_3.graphic, flash.display.MovieClip),_loc3_,mSelectedCallback);
            }
            else
            {
               _loc2_ = new DungeonRewardElement(mDBFacade,ASCompat.dynamicAs((mRewardPanel : ASAny).equip_slot_1.graphic, flash.display.MovieClip),_loc3_,mSelectedCallback);
            }
            mDungeonRewardElements.push(_loc2_);
         }
         if(_loc4_ > 0)
         {
            _loc3_ = new ChestInfo(mDBFacade,null);
            _loc3_.setParams((_loc4_ : UInt));
            _loc3_.setFromDungeonSummary();
            _loc2_ = new DungeonRewardElement(mDBFacade,ASCompat.dynamicAs((mRewardPanel : ASAny).equip_slot_2.graphic, flash.display.MovieClip),_loc3_,mSelectedCallback);
            mDungeonRewardElements.push(_loc2_);
         }
      }
      
      public function setChestAsSelected(param1:GMChest) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmChestInfo == param1)
            {
               mDungeonRewardElements[_loc2_].callSelectedCallback();
               highlightChest(mDungeonRewardElements[_loc2_].chestInfo);
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function refresh() 
      {
         populateRewardPanel();
      }
      
      function clearRewardPanel() 
      {
         var _loc1_= 0;
         if(mDungeonRewardElements == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].clear();
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function removeChestFromInventory(param1:ChestInfo) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmId == param1.gmId)
            {
               mDungeonRewardElements[_loc2_].empty();
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function show() 
      {
         mRewardPanel.visible = true;
      }
      
      public function hide() 
      {
         mRewardPanel.visible = false;
      }
      
      public function highlightChest(param1:ChestInfo) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmId == param1.gmId)
            {
               mDungeonRewardElements[_loc2_].select();
            }
            else
            {
               mDungeonRewardElements[_loc2_].deSelect();
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function clearHighlights() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].deSelect();
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mDungeonSummary = null;
         mRewardPanel = null;
         mDBFacade = null;
         mSelectedCallback = null;
         mAssetLoadingComponent = null;
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].destroy();
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
         mDungeonRewardElements = null;
      }
   }


