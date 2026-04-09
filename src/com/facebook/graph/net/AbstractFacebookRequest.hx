package com.facebook.graph.net
;
   import com.adobe.images.PNGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
    class AbstractFacebookRequest
   {
      
      var urlLoader:URLLoader;
      
      var urlRequest:URLRequest;
      
      var _rawResult:String;
      
      var _data:ASObject;
      
      var _success:Bool = false;
      
      var _url:String;
      
      var _requestMethod:String;
      
      var _callback:ASFunction;
      
      public function new()
      {
         
      }
      
      @:isVar public var rawResult(get,never):String;
public function  get_rawResult() : String
      {
         return this._rawResult;
      }
      
      @:isVar public var success(get,never):Bool;
public function  get_success() : Bool
      {
         return this._success;
      }
      
      @:isVar public var data(get,never):ASObject;
public function  get_data() : ASObject
      {
         return this._data;
      }
      
      public function callURL(param1:ASFunction, param2:String = "", param3:String = null) 
      {
         var _loc4_:URLVariables = null;
         this._callback = param1;
         this.urlRequest = new URLRequest(param2.length != 0 ? param2 : this._url);
         if(ASCompat.stringAsBool(param3))
         {
            _loc4_ = new URLVariables();
            ASCompat.setProperty(_loc4_, "locale", param3);
            this.urlRequest.data = _loc4_;
         }
         this.loadURLLoader();
      }
      
      @:isVar public var successCallback(never,set):ASFunction;
public function  set_successCallback(param1:ASFunction) :ASFunction      {
         return this._callback = param1;
      }
      
      function isValueFile(param1:ASObject) : Bool
      {
         return Std.isOfType(param1 , FileReference) || Std.isOfType(param1 , Bitmap) || Std.isOfType(param1 , BitmapData) || ASCompat.isByteArray(param1 );
      }
      
      function objectToURLVariables(param1:ASObject) : URLVariables
      {
         var _loc3_:String = null;
         var _loc2_= new URLVariables();
         if(param1 == null)
         {
            return _loc2_;
         }
         if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
         {
            _loc3_  = _tmp_;
            (_loc2_ : ASAny)[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public function close() 
      {
         if(this.urlLoader != null)
         {
            this.urlLoader.removeEventListener(Event.COMPLETE,this.handleURLLoaderComplete);
            this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError);
            this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError);
            try
            {
               this.urlLoader.close();
            }
            catch(e:ASAny)
            {
            }
            this.urlLoader = null;
         }
      }
      
      function loadURLLoader() 
      {
         this.urlLoader = new URLLoader();
         this.urlLoader.addEventListener(Event.COMPLETE,this.handleURLLoaderComplete,false,0,false);
         this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.handleURLLoaderIOError,false,0,true);
         this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleURLLoaderSecurityError,false,0,true);
         this.urlLoader.load(this.urlRequest);
      }
      
      function handleURLLoaderComplete(param1:Event) 
      {
         this.handleDataLoad(this.urlLoader.data);
      }
      
      function handleDataLoad(param1:ASObject, param2:Bool = true) 
      {
         var result:ASObject = param1;
         var dispatchCompleteEvent= param2;
         this._rawResult = ASCompat.asString(result );
         this._success = true;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
         }
         catch(e:ASAny)
         {
            _data = _rawResult;
            _success = false;
         }
         this.handleDataReady();
         if(dispatchCompleteEvent)
         {
            this.dispatchComplete();
         }
      }
      
      function handleDataReady() 
      {
      }
      
      function dispatchComplete() 
      {
         if(this._callback != null)
         {
            this._callback(this);
         }
         this.close();
      }
      
      function handleURLLoaderIOError(param1:IOErrorEvent) 
      {
         var event= param1;
         this._success = false;
         this._rawResult = ASCompat.dynamicAs(event.target , URLLoader).data;
         if(this._rawResult != "")
         {
            try
            {
               this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
            }
            catch(e:ASAny)
            {
               _data = {
                  "type":"Exception",
                  "message":_rawResult
               };
            }
         }
         else
         {
            this._data = event;
         }
         this.dispatchComplete();
      }
      
      function handleURLLoaderSecurityError(param1:SecurityErrorEvent) 
      {
         var event= param1;
         this._success = false;
         this._rawResult = ASCompat.dynamicAs(event.target , URLLoader).data;
         try
         {
            this._data = com.adobe.serialization.json.JSON.decode(ASCompat.dynamicAs(event.target , URLLoader).data);
         }
         catch(e:ASAny)
         {
            _data = event;
         }
         this.dispatchComplete();
      }
      
      function extractFileData(param1:ASObject) : ASObject
      {
         var _loc2_:ASObject = null;
         var _loc3_:String = null;
         if(param1 == null)
         {
            return null;
         }
         if(this.isValueFile(param1))
         {
            _loc2_ = param1;
         }
         else if(param1 != null)
         {
            if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
            {
               _loc3_  = _tmp_;
               if(this.isValueFile(param1[_loc3_]))
               {
                  _loc2_ = param1[_loc3_];
                  ASCompat.deleteProperty(param1, _loc3_);
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      function createUploadFileRequest(param1:ASObject, param2:ASObject = null) : PostRequest
      {
         var _loc4_:String = null;
         var _loc5_:ByteArray = null;
         var _loc3_= new PostRequest();
         if(ASCompat.toBool(param2))
         {
            if (checkNullIteratee(param2)) for(_tmp_ in param2.___keys())
            {
               _loc4_  = _tmp_;
               _loc3_.writePostData(_loc4_,param2[_loc4_]);
            }
         }
         if(Std.isOfType(param1 , Bitmap))
         {
            param1 = ASCompat.dynamicAs(param1 , Bitmap).bitmapData;
         }
         if(ASCompat.isByteArray(param1 ))
         {
            _loc3_.writeFileData(param2.fileName,(param1 : ByteArray) ,param2.contentType);
         }
         else if(Std.isOfType(param1 , BitmapData))
         {
            _loc5_ = PNGEncoder.encode(ASCompat.dynamicAs(param1 , BitmapData));
            _loc3_.writeFileData(param2.fileName,_loc5_,"image/png");
         }
         _loc3_.close();
         this.urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         return _loc3_;
      }
      
      public function toString() : String
      {
         return this.urlRequest.url + (this.urlRequest.data == null ? "" : "?" + ASCompat.unescape(Std.string(this.urlRequest.data)));
      }
   }


