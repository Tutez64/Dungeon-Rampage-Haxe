package brain.jsonRPC
;

import brain.logger.Logger;
import brain.utils.HttpStatusEventUtils;
import brain.jsonRPC.JSONRPCPendingInvokation;
import com.maccherone.json.JSON;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
    /*dynamic*/ class JSONRPCService
   {
      
      public static var GLobalcounter:Int = 0;
      
      public static var accountId:String = null;
      
      public static var validationToken:String = null;
      
      public static var initialLoginTraceId:String = null;
      
      public function new()
      {
         
      }
      
      public static function getFunction(param1:String, param2:String) : ASFunction
      {
         return getMethod(param1,param2);
      }
   }


function sanitizeForLog(param1:String, param2:String = null):String
{
   if(ASCompat.stringAsBool(brain.jsonRPC.JSONRPCService.validationToken) && brain.jsonRPC.JSONRPCService.validationToken.length > 0)
   {
      param1 = param1.split(brain.jsonRPC.JSONRPCService.validationToken).join("[Redacted]");
   }
   if(ASCompat.stringAsBool(param2) && param2.toLowerCase().indexOf("token") >= 0)
   {
      param1 = "[Redacted]";
   }
   return param1;
}
function getMethod(param1:String, param2:String):ASFunction
{
   var name= param1;
   var url= param2;
   var fn= Reflect.makeVarArgs(function( _rest:Array<ASAny>):ASAny
   {
      var rest = ASCompat.restToArray(_rest);
      var counter:Int;
      var req:URLRequest;
      var resp:flash.net.URLLoader;
      var inv:JSONRPCPendingInvokation;
      var traceInfo:String;
      var responseStatusCode:Int;
      var args= rest;
      var cbResult:ASFunction = null;
      var cbError:ASFunction = null;
      brain.jsonRPC.JSONRPCService.GLobalcounter++;
      counter = brain.jsonRPC.JSONRPCService.GLobalcounter;
      if(args.length == 1 && Std.isOfType(args[0] , Array))
      {
         args = ASCompat.dynamicAs(args[0], Array);
      }
      if(args.length != 0 && Reflect.isFunction(args[args.length - 1] ))
      {
         cbResult = ASCompat.asFunction(args.pop());
         if(args.length != 0 && Reflect.isFunction(args[args.length - 1] ))
         {
            cbError = cbResult;
            cbResult = ASCompat.asFunction(args.pop());
         }
      }
      req = new URLRequest(url + "/" + name);
      req.contentType = "application/json";
      req.method = "POST";
      if(ASCompat.stringAsBool(brain.jsonRPC.JSONRPCService.accountId) && ASCompat.stringAsBool(brain.jsonRPC.JSONRPCService.validationToken))
      {
         req.requestHeaders = [];
         req.requestHeaders.push(new URLRequestHeader("X-Account-Id",brain.jsonRPC.JSONRPCService.accountId));
         req.requestHeaders.push(new URLRequestHeader("X-Validation-Token",brain.jsonRPC.JSONRPCService.validationToken));
         if(ASCompat.stringAsBool(brain.jsonRPC.JSONRPCService.initialLoginTraceId))
         {
            req.requestHeaders.push(new URLRequestHeader("X-Session-Initial-Trace",brain.jsonRPC.JSONRPCService.initialLoginTraceId));
         }
      }
      else
      {
         Logger.warn("Attempting to make an RPC call to " + url + " but there are no authentication headers available yet. Proceeding without authentication headers, but the request may fail.");
      }
      resp = new flash.net.URLLoader();
      inv = new JSONRPCPendingInvokation(resp);
      if(cbError != null)
      {
         inv.addListener("fault",function(param1:FaultEvent)
         {
            cbError(param1.fault);
         });
      }
      if(cbResult != null)
      {
         inv.addListener("result",function(param1:ResultEvent)
         {
            cbResult(param1.result);
         });
      }
      try
      {
         req.data = com.maccherone.json.JSON.encode({
            "jsonrpc":"2.0",
            "method":name,
            "params":args,
            "id":1
         },false,7000);
         Logger.debugch("HTTP",Std.string(counter) + " Request=" + url + " data=" + sanitizeForLog(Std.string(req.data)));
      }
      catch(e:Dynamic)
      {
         inv.handleError(e);
         return inv;
      }
      resp.addEventListener("ioError",function(param1:flash.events.IOErrorEvent)
      {
         Logger.error(Std.string(counter) + " IOErrorEvent: " + param1.toString() + " Data:" + sanitizeForLog(Std.string(req.data)) + " URL:" + url.toString());
         inv.handleError(new Error(param1.text));
      });
      resp.addEventListener("securityError",function(param1:flash.events.SecurityErrorEvent)
      {
         Logger.error(Std.string(counter) + " SecurityErrorEvent: " + param1.toString() + " Data:" + sanitizeForLog(Std.string(req.data)) + " URL:" + url.toString());
         inv.handleError(new Error(param1.text));
      });
      responseStatusCode = 0;
      resp.addEventListener("httpResponseStatus",function(param1:flash.events.HTTPStatusEvent)
      {
         responseStatusCode = param1.status;
         traceInfo = HttpStatusEventUtils.getTraceId(param1);
      });
      resp.addEventListener("complete",function(param1:flash.events.Event)
      {
         var _loc2_:String = null;
         var _loc3_:ASObject = null;
         try
         {
            _loc2_ = ASCompat.urlLoaderReadUTFBytes(resp, ASCompat.urlLoaderBytesAvailable(resp));
            Logger.debugch("HTTP",Std.string(counter) + " [" + responseStatusCode + "] " + name + " Response=" + sanitizeForLog(_loc2_,name) + " trace:" + traceInfo);
            if(responseStatusCode < 200 || responseStatusCode >= 400)
            {
               inv.handleError(new Error("Unexpected HTTP response: " + responseStatusCode,-1));
               return;
            }
            _loc3_ = com.maccherone.json.JSON.decode(_loc2_);
         }
         catch(e:Dynamic)
         {
            Logger.warn(Std.string(counter) + " JSONRPCService error parsing JSON: " + sanitizeForLog(_loc2_,name));
            inv.handleError(e);
            return;
         }
         if(_loc3_.error == null)
         {
            if(false && _loc3_.result == null)
            {
               inv.handleError(new Error("result is missing in json",-1));
            }
            else
            {
               inv.handleResult(_loc3_.result);
            }
         }
         else if(_loc3_.error.message != null)
         {
            if(_loc3_.error.code != null)
            {
               inv.handleError(new Error(_loc3_.error.message,ASCompat.toInt(_loc3_.error.code)));
            }
            else
            {
               inv.handleError(new Error(_loc3_.error.message,-1));
            }
         }
         else
         {
            inv.handleError(new Error(_loc2_,-1));
         }
      });
      resp.load(req);
      return inv;
   });
   return fn;
}
var e_32700:ASObject = {
   "code":-32700,
   "message":"Parse error.",
   "data":"Invalid JSON. An error occurred on the server while parsing the JSON text."
};

var e_32600:ASObject = {
   "code":-32700,
   "message":"Invalid Request.",
   "data":"The received JSON is not a valid JSON-RPC Request."
};

var e_32601:ASObject = {
   "code":-32601,
   "message":"Method not found.",
   "data":"The requested remote-procedure does not exist / is not available."
};

var e_32602:ASObject = {
   "code":-32700,
   "message":"Invalid params.",
   "data":"Invalid method parameters."
};

var e_32603:ASObject = {
   "code":-32700,
   "message":"Internal error.",
   "data":"Internal JSON-RPC error."
};

