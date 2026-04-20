package config
;
   import brain.logger.Logger;
   import flash.events.*;
   import flash.net.*;
   
    class ServiceDiscoveryLoader
   {
      
      var mOnComplete:ASFunction;
      
      var mLoader:URLLoader;
      
      var mHttpStatus:Int = 0;
      
      var mUrl:String;
      
      public function new(param1:String, param2:ASFunction)
      {
         
         mOnComplete = param2;
         mUrl = param1 + "/game-status/service-discovery";
         mLoader = new URLLoader();
         mLoader.addEventListener("httpResponseStatus",onResponseStatus);
         mLoader.addEventListener("complete",onCompleted);
         mLoader.addEventListener("ioError",onError);
         mLoader.addEventListener("securityError",onError);
         mLoader.addEventListener("certificateError",onError);
         mLoader.load(new URLRequest(mUrl));
      }
      
      function onResponseStatus(param1:HTTPStatusEvent) 
      {
         mHttpStatus = param1.status;
      }
      
      function onCompleted(param1:Event) 
      {
         var _loc3_:ASObject = null;
         var _loc2_:String = ASCompat.toBool(param1.target) && ASCompat.toBool(ASCompat.dynamicAs(param1.target , URLLoader).data) ? ASCompat.asString(ASCompat.dynamicAs(param1.target , URLLoader).data ) : null;
         Logger.debugch("HTTP","Service discovery response (HTTP " + mHttpStatus + ") from " + mUrl + ": " + _loc2_);
         if(mHttpStatus < 100 || mHttpStatus >= 400)
         {
            Logger.warn("Service discovery returned HTTP " + mHttpStatus + " from " + mUrl);
            cleanup();
            mOnComplete(null,1500,Std.string(mHttpStatus));
            return;
         }
         try
         {
            _loc3_ = haxe.Json.parse(_loc2_);
            if(ASCompat.toBool(_loc3_) && ASCompat.toBool(_loc3_.webServicesUrl) && ASCompat.toBool(_loc3_.gameSocketAddress) && ASCompat.toBool(_loc3_.gameSocketPort))
            {
               Logger.info("Service discovery resolved from " + mUrl);
               cleanup();
               mOnComplete(_loc3_,0,"");
               return;
            }
         }
         catch(e:Dynamic)
         {
            Logger.fatal("Service discovery returned unparseable response from " + mUrl + ": " + Std.string(e.message));
            cleanup();
            return;
         }
         Logger.fatal("Service discovery response missing required fields from " + mUrl + ": " + _loc2_);
         cleanup();
      }
      
      function onError(param1:Event) 
      {
         Logger.warn("Service discovery request failed (HTTP " + mHttpStatus + ") from " + mUrl);
         cleanup();
         mOnComplete(null,1503,"");
      }
      
      function cleanup() 
      {
         mLoader.removeEventListener("httpResponseStatus",onResponseStatus);
         mLoader.removeEventListener("complete",onCompleted);
         mLoader.removeEventListener("ioError",onError);
         mLoader.removeEventListener("securityError",onError);
         mLoader.removeEventListener("certificateError",onError);
         mLoader = null;
      }
   }


