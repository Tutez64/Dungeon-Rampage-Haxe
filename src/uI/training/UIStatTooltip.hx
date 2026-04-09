package uI.training
;
   import facade.DBFacade;
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
         mTitleLabel.text = mGMStatItem.Name.toUpperCase();
         mDescription.text = mGMStatItem.Description;
return param1;
      }
      
      @:isVar public var superStatItem(never,set):GMSuperStat;
public function  set_superStatItem(param1:GMSuperStat) :GMSuperStat      {
         mGMSuperStatItem = param1;
         mTitleLabel.text = mGMSuperStatItem.Name.toUpperCase();
         mDescription.text = mGMSuperStatItem.Description;
return param1;
      }
   }


