package account
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facebookAPI.DBFacebookAPIController;
   import gameMasterDictionary.GMCashDeal;
   import gameMasterDictionary.GMOffer;
   import metrics.PixelTracker;
   import com.facebook.graph.Facebook;
   import com.maccherone.json.JSON;
   import flash.external.ExternalInterface;
   import org.as3commons.collections.Map;
   
    class StoreServices
   {
      
      static var mLimitedOffers:Map = new Map();
      
      public function new()
      {
         
      }
      
      public static function createCashDealOrder(param1:DBFacade, param2:UInt, param3:Float, param4:ASFunction, param5:ASFunction) 
      {
         if(param1.isFacebookPlayer)
         {
            createCashDealOrderFB(param1,param2,param3,param4,param5);
         }
         else if(param1.isKongregatePlayer)
         {
            createCashDealOrderKongregate(param1,param2,param3,param4,param5);
         }
         else
         {
            createCashDealOrderCashbox(param1,param2,param3,param4,param5);
         }
      }
      
      public static function createCashDealOrderCashbox(param1:DBFacade, param2:UInt, param3:Float, param4:ASFunction, param5:ASFunction) 
      {
         var createCashDealOrderCBFunc:ASFunction;
         var dbFacade= param1;
         var dealId= param2;
         var dealMultiplier= param3;
         var successCallback= param4;
         var errorCallback= param5;
         Logger.debug("createCashDealOrderCashbox " + Std.string(dbFacade.dbAccountInfo.id) + " dealId: " + Std.string(dealId));
         createCashDealOrderCBFunc = JSONRPCService.getFunction("CreateOrderCB",dbFacade.rpcRoot + "store");
         createCashDealOrderCBFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,function(param1:ASAny)
         {
            var error:Error;
            var orderId:UInt;
            var details:ASAny = param1;
            dbFacade.metrics.log("CreateCashDealOrderCB");
            if(details == null)
            {
               Logger.debug("createCashDealOrderCB success: but detail null, possibly a local build");
               error = new Error("dev box");
               errorCallback(error);
               return;
            }
            if(!ExternalInterface.available)
            {
               Logger.warn("GBS: ExternalInterface unavailable");
               return;
            }
            Logger.debug("createCashDealOrderCB success: " + Std.string(details));
            orderId = (ASCompat.toInt(details.id) : UInt);
            ExternalInterface.addCallback("cashboxOrderResult",function(param1:Int, param2:String)
            {
               var _loc3_:GMCashDeal = null;
               if(param1 != 0)
               {
                  dbFacade.metrics.log("CashboxPaySuccess");
                  _loc3_ = ASCompat.dynamicAs(dbFacade.gameMaster.cashDealById.itemFor(dealId), gameMasterDictionary.GMCashDeal);
                  if(_loc3_ != null)
                  {
                     PixelTracker.purchaseEvent(dbFacade,(Std.int(_loc3_.Price * dealMultiplier) : UInt));
                  }
                  Logger.debug("CashboxPaySuccess: " + param2);
                  StoreServices.orderCompleteCallback(dbFacade,"success",orderId);
                  if(successCallback != null)
                  {
                     successCallback(details);
                  }
               }
               else
               {
                  dbFacade.metrics.log("CashboxPayFail");
                  Logger.debug("CashboxPayFail: " + param2);
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("FBCashboxPayFail",701));
                  }
               }
            });
            ExternalInterface.call("payinit",details.id,details.deal_id);
         },errorCallback);
      }
      
      public static function createCashDealOrderFB(param1:DBFacade, param2:UInt, param3:Float, param4:ASFunction, param5:ASFunction) 
      {
         var createCashDealOrderFunc:ASFunction;
         var dbFacade= param1;
         var dealId= param2;
         var dealMultiplier= param3;
         var successCallback= param4;
         var errorCallback= param5;
         Logger.debug("createCashDealOrder: " + Std.string(dbFacade.dbAccountInfo.id) + " dealId: " + Std.string(dealId));
         createCashDealOrderFunc = JSONRPCService.getFunction("CreateOrder",dbFacade.rpcRoot + "store");
         createCashDealOrderFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,1,function(param1:ASAny)
         {
            var orderId:UInt;
            var og_url:String;
            var params:ASObject;
            var details:ASAny = param1;
            dbFacade.metrics.log("CreateCashDealOrder");
            Logger.debug("createCashDealOrder success id: " + Std.string(details.id) + "; details: " + Std.string(details));
            orderId = (ASCompat.toInt(details.id) : UInt);
            og_url = dbFacade.downloadRoot + "general/gem-" + Std.string(details.price) + ".html";
            params = {
               "action":"purchaseitem",
               "request_id":orderId,
               "product":og_url,
               "quantity":1
            };
            Facebook.ui("pay",params,function(param1:ASObject)
            {
               var fulfillOrderFBFunc:ASFunction;
               var gmCashDeal:GMCashDeal;
               var response:ASObject = param1;
               var responseJson= com.maccherone.json.JSON.encode(response);
               if(response.status == "completed" && ASCompat.toBool(response.payment_id))
               {
                  fulfillOrderFBFunc = JSONRPCService.getFunction("FulfillOrderFB",dbFacade.rpcRoot + "store");
                  fulfillOrderFBFunc(dbFacade.dbAccountInfo.id,response.request_id,response.payment_id,response.status,response.currency,response.amount,dbFacade.validationToken,function(param1:ASAny)
                  {
                     dbFacade.metrics.log("FacebookUIPaySuccess");
                     StoreServices.orderCompleteCallback(dbFacade,"success",(ASCompat.toInt(param1.reference_id) : UInt));
                  });
                  gmCashDeal = ASCompat.dynamicAs(dbFacade.gameMaster.cashDealById.itemFor(dealId), gameMasterDictionary.GMCashDeal);
                  if(gmCashDeal != null)
                  {
                     PixelTracker.purchaseEvent(dbFacade,(Std.int(gmCashDeal.Price * dealMultiplier) : UInt));
                  }
                  Logger.debug("FB UI success: " + responseJson);
                  if(successCallback != null)
                  {
                     successCallback(details);
                  }
               }
               else
               {
                  dbFacade.metrics.log("FacebookUIPayFail");
                  Logger.debug("FB UI fail: " + responseJson);
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("FB UI Fail",701));
                  }
               }
            });
         },errorCallback);
      }
      
      public static function createCashDealOrderKongregate(param1:DBFacade, param2:UInt, param3:Float, param4:ASFunction, param5:ASFunction) 
      {
         var createCashDealOrderFunc:ASFunction;
         var dbFacade= param1;
         var dealId= param2;
         var dealMultiplier= param3;
         var successCallback= param4;
         var errorCallback= param5;
         Logger.debug("createCashDealOrderKong: " + Std.string(dbFacade.dbAccountInfo.id) + " dealId: " + Std.string(dealId));
         createCashDealOrderFunc = JSONRPCService.getFunction("CreateOrder",dbFacade.rpcRoot + "store");
         createCashDealOrderFunc(dbFacade.dbAccountInfo.id,dealId,dbFacade.demographics,2,function(param1:ASAny)
         {
            var orderId:UInt;
            var details:ASAny = param1;
            dbFacade.metrics.log("CreateCashDealOrderKongregate");
            orderId = (ASCompat.toInt(details.id) : UInt);
            Logger.debug("createCashDealOrderKongregate success: " + orderId);
            dbFacade.kongregateAPI.mtx.purchaseItems([Std.string(dealId)],function(param1:ASObject)
            {
               var gmCashDeal:GMCashDeal;
               var settleCashDealOrderFunc:ASFunction;
               var response:ASObject = param1;
               if(ASCompat.toBool(response.success))
               {
                  dbFacade.metrics.log("KongregateUIPaySuccess");
                  gmCashDeal = ASCompat.dynamicAs(dbFacade.gameMaster.cashDealById.itemFor(dealId), gameMasterDictionary.GMCashDeal);
                  if(gmCashDeal != null)
                  {
                     PixelTracker.purchaseEvent(dbFacade,(Std.int(gmCashDeal.Price * dealMultiplier) : UInt));
                  }
                  Logger.debug("Kongregate Pay success");
                  settleCashDealOrderFunc = JSONRPCService.getFunction("purchase",dbFacade.rpcRoot + "kongregate");
                  settleCashDealOrderFunc(dbFacade.dbAccountInfo.id,orderId,function(param1:ASAny)
                  {
                     Logger.debug("Kongregate order settled");
                     StoreServices.orderCompleteCallback(dbFacade,"success",orderId);
                     Logger.debug("Kongregate Pay called orderCompleteCallback");
                     if(successCallback != null)
                     {
                        successCallback(param1);
                     }
                  },function(param1:ASAny)
                  {
                     Logger.debug("Kongregate order settle failed");
                  });
               }
               else
               {
                  dbFacade.metrics.log("KongregateUIPayFail");
                  Logger.debug("Kongregate Pay fail");
                  StoreServices.orderCompleteCallback(dbFacade,"failure",orderId);
                  if(errorCallback != null)
                  {
                     errorCallback(new Error("Kongregate Pay Fail",701));
                  }
               }
            });
         },errorCallback);
      }
      
      public static function orderCompleteCallback(param1:DBFacade, param2:String, param3:UInt) 
      {
         Logger.debug("orderCompleteCallback: orderId: " + Std.string(param3) + " result: " + param2);
         if(param2 == "success")
         {
            Logger.debug("Refreshing currency");
            param1.dbAccountInfo.getUsersFullAccountInfo();
         }
      }
      
      public static function earnCredits(param1:DBFacade, param2:ASFunction) 
      {
         if(!param1.isFacebookPlayer)
         {
            return;
         }
         DBFacebookAPIController.earnCredits(param1,param2);
      }
      
      static function callJSEarnCurrency(param1:DBFacade, param2:String) 
      {
         ExternalInterface.call("earnCredits",param2);
      }
      
      public static function purchaseOffer(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction, param5:UInt = (0 : UInt), param6:Bool = true) 
      {
         var purchaseFunc:ASFunction;
         var dbFacade= param1;
         var offerId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         var heroId= param5;
         var callRefreshOnceDone= param6;
         var currentAvatarId= (ASCompat.toInt(dbFacade.dbAccountInfo.activeAvatarInfo != null ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0) : UInt);
         Logger.debug("purchaseOffer: " + Std.string(offerId));
         purchaseFunc = JSONRPCService.getFunction("PurchaseOffer",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,heroId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function purchaseAndOpenChest(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction, param5:UInt, param6:Bool = true) 
      {
         var purchaseFunc:ASFunction;
         var dbFacade= param1;
         var offerId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         var forHero= param5;
         var callRefreshOnceDone= param6;
         var currentAvatarId= (ASCompat.toInt(dbFacade.dbAccountInfo.activeAvatarInfo != null ? dbFacade.dbAccountInfo.activeAvatarInfo.id : 0) : UInt);
         Logger.debug("purchaseChest: " + Std.string(offerId));
         purchaseFunc = JSONRPCService.getFunction("PurchaseChest",dbFacade.rpcRoot + "store");
         purchaseFunc(dbFacade.dbAccountInfo.id,currentAvatarId,offerId,dbFacade.validationToken,dbFacade.demographics,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1,callRefreshOnceDone);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellWeapon(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction) 
      {
         var dbFacade= param1;
         var weaponInstanceId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         var sellItemFunc= JSONRPCService.getFunction("SellWeapon",dbFacade.rpcRoot + "store");
         sellItemFunc(dbFacade.dbAccountInfo.id,weaponInstanceId,dbFacade.validationToken,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellStackable(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction) 
      {
         var dbFacade= param1;
         var stackableInstanceId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         var sellItemFunc= JSONRPCService.getFunction("SellStackable",dbFacade.rpcRoot + "store");
         sellItemFunc(dbFacade.dbAccountInfo.id,stackableInstanceId,dbFacade.validationToken,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function sellPet(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction) 
      {
         var dbFacade= param1;
         var petInstanceId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         var sellPetFunc= JSONRPCService.getFunction("SellPet",dbFacade.rpcRoot + "store");
         sellPetFunc(dbFacade.dbAccountInfo.id,petInstanceId,dbFacade.validationToken,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },errorCallback);
      }
      
      public static function useAccountBooster(param1:DBFacade, param2:UInt, param3:ASFunction, param4:ASFunction) 
      {
         var dbFacade= param1;
         var stackableId= param2;
         var successCallback= param3;
         var errorCallback= param4;
         errorCallback = function()
         {
         };
         var useAccountBoosterFunc= JSONRPCService.getFunction("UseAccountBooster",dbFacade.rpcRoot + "store");
         useAccountBoosterFunc(dbFacade.dbAccountInfo.id,stackableId,dbFacade.validationToken,dbFacade.demographics,function(param1:ASAny)
         {
            dbFacade.dbAccountInfo.parseResponse(param1);
            if(successCallback != null)
            {
               successCallback();
            }
         },errorCallback);
      }
      
      public static function getWebServerTimestamp(param1:DBFacade, param2:ASFunction, param3:ASFunction) 
      {
         var dbFacade= param1;
         var successCallback= param2;
         var errorCallback= param3;
         errorCallback = function()
         {
         };
         var getWebServerTimestampFunc= JSONRPCService.getFunction("getWebServerTimestamp",dbFacade.rpcRoot + "storeGetWebServerTimestamp");
         getWebServerTimestampFunc(function(param1:Array<ASAny>)
         {
            GameClock.finishSetWebServerTime(param1);
            dbFacade.regenerateGameMaster();
            if(successCallback != null)
            {
               successCallback();
            }
         },errorCallback);
      }
      
      static function parseLimitedOfferUsage(param1:Array<ASAny>) 
      {
         var _loc2_:ASObject = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = param1[_loc3_];
            if(mLimitedOffers.hasKey(_loc2_.id))
            {
               mLimitedOffers.replaceFor(_loc2_.id,_loc2_.usage_count);
            }
            else
            {
               mLimitedOffers.add(_loc2_.id,_loc2_.usage_count);
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      public static function getOfferQuantitySold(param1:GMOffer) : UInt
      {
         var _loc2_:ASAny = mLimitedOffers.itemFor(param1.Id);
         return (ASCompat.toInt(_loc2_ == null ? (0 : UInt) : (ASCompat.toInt(_loc2_) : UInt)) : UInt);
      }
      
      public static function getLimitedOfferUsage(param1:DBFacade, param2:ASAny, param3:ASFunction, param4:ASFunction) 
      {
         var limitedOfferUsageFunc:ASFunction;
         var dbFacade= param1;
         var details:ASAny = param2;
         var successCallback= param3;
         var errorCallback= param4;
         Logger.debug("getLimitedOfferUsage");
         limitedOfferUsageFunc = JSONRPCService.getFunction("GetLimitedOfferStatus",dbFacade.rpcRoot + "store");
         limitedOfferUsageFunc(dbFacade.dbAccountInfo.id,function(param1:ASAny)
         {
            parseLimitedOfferUsage(ASCompat.dynamicAs(param1, Array));
            if(successCallback != null)
            {
               successCallback(param1);
            }
         },function(param1:Error)
         {
            if(errorCallback != null)
            {
               errorCallback(param1);
            }
         });
      }
   }


