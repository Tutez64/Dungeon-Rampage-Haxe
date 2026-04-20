package steamInput
;
   
    class KeyboardEventsSpoofMap
   {
      
      var mActionNamesToKeyCodes:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mActionNames:Vector<String> = new Vector();
      
      public function new()
      {
         
         mActionNamesToKeyCodes["revive_ally"] = 32;
         mActionNamesToKeyCodes["toggle_menu"] = 27;
         var _loc1_:ASAny;
         final __ax4_iter_88 = mActionNamesToKeyCodes;
         if (checkNullIteratee(__ax4_iter_88)) for(_tmp_ in __ax4_iter_88.keys())
         {
            _loc1_ = _tmp_;
            mActionNames.push(_loc1_);
         }
      }
      
      @:isVar public var actionNames(get,never):Vector<String>;
public function  get_actionNames() : Vector<String>
      {
         return mActionNames;
      }
      
      public function getKeyCode(param1:String) : Int
      {
         return ASCompat.toInt(mActionNamesToKeyCodes[param1]);
      }
   }


