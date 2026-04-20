package uI.training
;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import gameMasterDictionary.GMStat;
   import gameMasterDictionary.GMSuperStat;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIStatTooltip extends MovieClip
   {
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mGMStatItem:GMStat;
      
      var mGMSuperStatItem:GMSuperStat;
      
      var mTitleLabel:TextField;
      
      var mDescription:TextField;
      
      public function new(param1:DBFacade, param2:Dynamic)
      {
         super();
         mDBFacade = param1;
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip);
         this.addChild(mRoot);
         mTitleLabel = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
         mDescription = ASCompat.dynamicAs((mRoot : ASAny).stat_description_label, flash.text.TextField);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      @:isVar public var statItem(never,set):GMStat;
public function  set_statItem(param1:GMStat) :GMStat      {
         mGMStatItem = param1;
         mTitleLabel.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMStatItem.Constant).toUpperCase();
         mDescription.text = GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMStatItem.Constant);
return param1;
      }
      
      @:isVar public var superStatItem(never,set):GMSuperStat;
public function  set_superStatItem(param1:GMSuperStat) :GMSuperStat      {
         mGMSuperStatItem = param1;
         mTitleLabel.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mGMSuperStatItem.Constant).toUpperCase();
         mDescription.text = GameMasterLocale.getGameMasterSubString("STATS_DESCRIPTION",mGMSuperStatItem.Constant);
return param1;
      }
   }


