package metrics
;
   import brain.logger.Logger;
   import facade.DBFacade;
   import com.maccherone.json.JSON;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   
    class MetricsLogger
   {
      
      var mMetricsURL:String;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:String)
      {
         
         mDBFacade = param1;
         mMetricsURL = param2;
         if(!ASCompat.stringAsBool(mMetricsURL) || mMetricsURL.length == 0)
         {
            Logger.info("Empty metrics URL. Cannot log metrics.");
         }
      }
      
      public function log(param1:String, param2:ASObject = null) 
      {
         if(!ASCompat.stringAsBool(mMetricsURL))
         {
            return;
         }
         var _loc3_= new URLRequest(mMetricsURL);
         if(param2 == null)
         {
            param2 = {};
         }
         var _loc6_:String;
         final __ax4_iter_99:ASObject = mDBFacade.demographics;
         if (checkNullIteratee(__ax4_iter_99)) for(_tmp_ in __ax4_iter_99.___keys())
         {
            _loc6_ = _tmp_;
            if(param2.hasOwnProperty(_loc6_))
            {
               Logger.warn("Duplicate metric property: " + _loc6_ + " in event: " + param1);
            }
            param2[_loc6_] = mDBFacade.demographics[_loc6_];
         }
         var _loc4_= com.maccherone.json.JSON.encode(param2);
         var _loc7_= new URLVariables();
         ASCompat.setProperty(_loc7_, "e", param1);
         ASCompat.setProperty(_loc7_, "parameters", _loc4_);
         _loc3_.data = _loc7_;
         _loc3_.method = "POST";
         var _loc5_= new URLLoader(_loc3_);
         _loc5_.addEventListener("complete",completeHandler);
         _loc5_.addEventListener("securityError",securityErrorHandler);
         _loc5_.addEventListener("ioError",ioErrorHandler);
         _loc5_.load(_loc3_);
      }
      
      function completeHandler(param1:Event) 
      {
      }
      
      function securityErrorHandler(param1:Event) 
      {
         Logger.warn("SecurityError on metrics logging: " + param1.toString());
      }
      
      function ioErrorHandler(param1:Event) 
      {
         Logger.warn("IOError on metrics logging: " + param1.toString());
      }
   }


