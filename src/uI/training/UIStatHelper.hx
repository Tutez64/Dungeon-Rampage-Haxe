package uI.training
;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   
    class UIStatHelper
   {
      
      public static inline final MAX_PIPS_PER_LINE= 25;
      
      var mDBFacade:DBFacade;
      
      var mUIRoot:MovieClip;
      
      var mStatName:String;
      
      var mStatAmount:UInt = 0;
      
      var mStatBars:Vector<UIStatProgressBar>;
      
      var mStatNameText:TextField;
      
      var mStatIconRenderer:MovieClipRenderController;
      
      var mStatIcon:MovieClip;
      
      var mStatIconName:String;
      
      var mStatIconTooltip:UIStatTooltip;
      
      var mStatIconTooltipBar:UIObject;
      
      var mTooltipBar:UIObject;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:MovieClip)
      {
         
         mDBFacade = param1;
         mUIRoot = param3;
         this.setupUI(param2);
      }
      
      function setupUI(param1:Dynamic) 
      {
         var _loc2_= 0;
         var _loc4_:Array<ASAny> = [(mUIRoot : ASAny).training_meter01,(mUIRoot : ASAny).training_meter02,(mUIRoot : ASAny).training_meter03];
         var _loc3_:Array<ASAny> = [(mUIRoot : ASAny).training_meter01_full,(mUIRoot : ASAny).training_meter02_full,(mUIRoot : ASAny).training_meter03_full];
         mStatBars = new Vector<UIStatProgressBar>();
         _loc2_ = 0;
         while(_loc2_ < 3)
         {
            mStatBars.push(new UIStatProgressBar(mDBFacade,ASCompat.dynamicAs(_loc4_[_loc2_], flash.display.MovieClip),ASCompat.dynamicAs(_loc3_[_loc2_], flash.display.MovieClip)));
            _loc2_++;
         }
         mStatIconTooltipBar = new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).hit, flash.display.MovieClip));
         mStatIconTooltip = new UIStatTooltip(mDBFacade,param1);
         mStatIconTooltipBar.tooltip = mStatIconTooltip;
         mStatIconTooltipBar.tooltipPos = new Point(-75,ASCompat.toNumber(ASCompat.toNumberField((mUIRoot : ASAny).hit, "height") * -0.5 + 25));
         mStatNameText = ASCompat.dynamicAs((mUIRoot : ASAny).training_meter_text, flash.text.TextField);
         mTooltipBar = new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).barTooltip_hit, flash.display.MovieClip));
         ASCompat.setProperty((mUIRoot : ASAny).barTooltip, "text", "0/75");
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mDBFacade = null;
         mTooltipBar.destroy();
         _loc1_ = 0;
         while(_loc1_ < 3)
         {
            mStatBars[_loc1_].destroy();
            _loc1_++;
         }
         mStatBars = null;
         if(mStatIconRenderer != null)
         {
            mStatIconRenderer.destroy();
         }
         mStatIconTooltipBar.destroy();
         mStatIconTooltip.destroy();
      }
      
      @:isVar public var amount(get,never):UInt;
public function  get_amount() : UInt
      {
         return mStatAmount;
      }
      
            
      @:isVar public var statAmount(get,set):UInt;
public function  set_statAmount(param1:UInt) :UInt      {
         return mStatAmount = param1;
      }
function  get_statAmount() : UInt
      {
         return mStatAmount;
      }
      
      @:isVar public var statName(never,set):String;
public function  set_statName(param1:String) :String      {
         return mStatName = param1;
      }
      
      public function refresh(param1:SwfAsset) 
      {
         var _loc2_:Dynamic = null;
         if(ASCompat.mapItemForNeNull(mDBFacade.gameMaster.statByConstant, mStatName))
         {
            mStatNameText.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mDBFacade.gameMaster.statByConstant.itemFor(mStatName).Constant).toUpperCase();
            mStatIconName = mDBFacade.gameMaster.statByConstant.itemFor(mStatName).IconName;
            mStatIconTooltip.statItem = ASCompat.dynamicAs(mDBFacade.gameMaster.statByConstant.itemFor(mStatName), gameMasterDictionary.GMStat);
         }
         else
         {
            mStatNameText.text = GameMasterLocale.getGameMasterSubString("STATS_NAME",mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName).Constant).toUpperCase();
            mStatIconName = mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName).IconName;
            mStatIconTooltip.superStatItem = ASCompat.dynamicAs(mDBFacade.gameMaster.superStatByConstant.itemFor(mStatName), gameMasterDictionary.GMSuperStat);
         }
         if(mStatIcon != null)
         {
            (mUIRoot : ASAny).icon.removeChild(mStatIcon);
            mStatIconRenderer.destroy();
         }
         _loc2_ = param1.getClass(mStatIconName);
         if(_loc2_ != null)
         {
            mStatIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            mStatIconRenderer = new MovieClipRenderController(mDBFacade,mStatIcon);
            mStatIconRenderer.play((0 : UInt),true);
            (mUIRoot : ASAny).icon.addChild(mStatIcon);
         }
      }
      
      public function updateUI() 
      {
         var _loc5_= 0;
         var _loc4_= (25 : UInt);
         var _loc3_= (50 : UInt);
         var _loc2_= (75 : UInt);
         var _loc6_= 0;
         if(mStatAmount == _loc2_)
         {
            _loc6_ = 3;
         }
         else if(mStatAmount >= _loc3_)
         {
            _loc6_ = 2;
         }
         else if(mStatAmount >= _loc4_)
         {
            _loc6_ = 1;
         }
         else
         {
            _loc6_ = 0;
         }
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            mStatBars[_loc5_].completed = false;
            mStatBars[_loc5_].value = 0;
            _loc5_++;
         }
         var _loc1_= (mStatAmount % 25 : Int);
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            if(_loc5_ < _loc6_)
            {
               mStatBars[_loc5_].completed = true;
            }
            else if(_loc5_ == _loc6_)
            {
               mStatBars[_loc5_].value = _loc1_ / 25 * 0.995;
            }
            _loc5_++;
         }
         ASCompat.setProperty((mUIRoot : ASAny).barTooltip, "text", Std.string(mStatAmount) + " / " + Std.string((25 * 3)));
      }
   }


