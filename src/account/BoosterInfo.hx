package account
;
   import brain.clock.GameClock;
   import brain.utils.TimeSpan;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMBuff;
   import gameMasterDictionary.GMStackable;
   
    class BoosterInfo extends InventoryBaseInfo
   {
      
      var mTimestampEnd:String;
      
      var mGMStackable:GMStackable;
      
      var mBuff:GMBuff;
      
      public function new(param1:DBFacade, param2:ASObject)
      {
         super(param1,param2);
         mGMStackable = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(mGMId), gameMasterDictionary.GMStackable);
         mBuff = ASCompat.dynamicAs(mDBFacade.gameMaster.buffByConstant.itemFor(mGMStackable.Buff), gameMasterDictionary.GMBuff);
      }
      
      public function timeStamp() : String
      {
         return mTimestampEnd;
      }
      
      @:isVar public var StackInfo(get,never):GMStackable;
public function  get_StackInfo() : GMStackable
      {
         return mGMStackable;
      }
      
      @:isVar public var BuffInfo(get,never):GMBuff;
public function  get_BuffInfo() : GMBuff
      {
         return mBuff;
      }
      
      public function getDisplayTimeLeft() : String
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_= _loc2_.dateBooster((this.gmId : Int));
         if(_loc1_ == null)
         {
            return Locale.getString("EXPIRED");
         }
         var _loc3_= new TimeSpan(_loc1_.getTime());
         return _loc3_.getTimeBetweenTimeSpanAndNow(true);
      }
      
      public function getEndDate() : Date
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo;
         return _loc2_.dateBooster((this.gmId : Int));
      }
      
      public function getTimeLeft() : Float
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_= _loc2_.dateBooster((this.gmId : Int));
         if(_loc1_ == null)
         {
            return 0;
         }
         return _loc1_.getTime()- GameClock.getWebServerTime();
      }
      
      override function parseJson(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mGMId = ASCompat.asUint(param1.stack_id );
         mAccountId = ASCompat.asUint(param1.account_id );
         mDatabaseId = ASCompat.asUint(param1.id );
         mTimestampEnd = ASCompat.asString(param1.timestamp_end );
         mIsNew = false;
      }
   }


