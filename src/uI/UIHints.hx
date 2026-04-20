package uI
;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMHints;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIHints
   {
      
      var mDBFacade:DBFacade;
      
      var mHintBox:MovieClip;
      
      var mHintTitle:TextField;
      
      var mHintText:TextField;
      
      public function new(param1:DBFacade, param2:MovieClip)
      {
         
         mDBFacade = param1;
         mHintBox = param2;
         mHintText = ASCompat.dynamicAs((param2 : ASAny).hint_text, flash.text.TextField);
         mHintTitle = ASCompat.dynamicAs((param2 : ASAny).hint_title, flash.text.TextField);
         mHintTitle.text = Locale.getString("HINT_TITLE");
         getNewHint();
      }
      
      function getNewHint() 
      {
         var _loc2_= new Vector<GMHints>();
         var _loc5_= mDBFacade.dbAccountInfo.activeAvatarInfo.level;
         var _loc4_:GMHints;
         final __ax4_iter_133 = mDBFacade.gameMaster.Hints;
         if (checkNullIteratee(__ax4_iter_133)) for (_tmp_ in __ax4_iter_133)
         {
            _loc4_ = _tmp_;
            if(ASCompat.toNumberField(_loc4_, "MinLevel") <= _loc5_ && ASCompat.toNumberField(_loc4_, "MaxLevel") >= _loc5_)
            {
               _loc2_.push(_loc4_);
            }
         }
         if(_loc2_.length == 0)
         {
            return;
         }
         var _loc1_= (Math.floor(Math.random() * _loc2_.length) : UInt);
         var _loc3_= _loc2_[(_loc1_ : Int)];
         if(_loc3_ == null)
         {
            return;
         }
         mHintText.text = GameMasterLocale.getGameMasterSubString("HINTS",_loc3_.Constant);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mHintBox = null;
         mHintTitle = null;
         mHintText = null;
      }
   }


