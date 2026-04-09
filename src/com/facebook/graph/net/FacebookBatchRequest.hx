package com.facebook.graph.net
;
   import com.adobe.images.PNGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.BatchItem;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
    class FacebookBatchRequest extends AbstractFacebookRequest
   {
      
      var _params:ASObject;
      
      var _relativeURL:String;
      
      var _fileData:ASObject;
      
      var _accessToken:String;
      
      var _batch:Batch;
      
      public function new(param1:Batch, param2:ASFunction = null)
      {
         super();
         this._batch = param1;
         _callback = param2;
      }
      
      public function call(param1:String) 
      {
         var __tmpAssignObj13:ASObject;
         var _loc8_:BatchItem = null;
         var _loc9_:ASObject = null;
         var _loc10_:ASObject = null;
         var _loc11_:String = null;
         var _loc12_:URLVariables = null;
         this._accessToken = param1;
         urlRequest = new URLRequest(FacebookURLDefaults.GRAPH_URL);
         urlRequest.method = URLRequestMethod.POST;
         var _loc2_:Array<ASAny> = [];
         var _loc3_:Array<ASAny> = [];
         var _loc4_= false;
         var _loc5_= this._batch.requests;
         var _loc6_= (_loc5_.length : UInt);
         var _loc7_= (0 : UInt);
         while(_loc7_ < _loc6_)
         {
            _loc8_ = ASCompat.dynamicAs(_loc5_[(_loc7_ : Int)], com.facebook.graph.data.BatchItem);
            _loc9_ = this.extractFileData(_loc8_.params);
            _loc10_ = {
               "method":_loc8_.requestMethod,
               "relative_url":_loc8_.relativeURL
            };
            if(ASCompat.toBool(_loc8_.params))
            {
               if(_loc8_.params["contentType"] != /*undefined*/null)
               {
                  ASCompat.setProperty(_loc10_, "contentType", _loc8_.params["contentType"]);
               }
               _loc11_ = this.objectToURLVariables(_loc8_.params).toString();
               if(_loc8_.requestMethod == URLRequestMethod.GET || _loc8_.requestMethod.toUpperCase() == "DELETE")
               {
                  __tmpAssignObj13 = _loc10_;
                  ASCompat.setProperty(__tmpAssignObj13, "relative_url", Std.string(__tmpAssignObj13.relative_url) + "?" + _loc11_);
               }
               else
               {
                  ASCompat.setProperty(_loc10_, "body", _loc11_);
               }
            }
            _loc2_.push(_loc10_);
            if(ASCompat.toBool(_loc9_))
            {
               _loc3_.push(_loc9_);
               ASCompat.setProperty(_loc10_, "attached_files", _loc8_.params.fileName == null ? "file" + _loc7_ : _loc8_.params.fileName);
               _loc4_ = true;
            }
            else
            {
               _loc3_.push(null);
            }
            _loc7_++;
         }
         if(!_loc4_)
         {
            _loc12_ = new URLVariables();
            ASCompat.setProperty(_loc12_, "access_token", param1);
            ASCompat.setProperty(_loc12_, "batch", com.adobe.serialization.json.JSON.encode(_loc2_));
            urlRequest.data = _loc12_;
            loadURLLoader();
         }
         else
         {
            this.sendPostRequest(_loc2_,_loc3_);
         }
      }
      
      function sendPostRequest(param1:Array<ASAny>, param2:Array<ASAny>) 
      {
         var _loc6_:ASObject = null;
         var _loc7_:ASObject = null;
         var _loc8_:ByteArray = null;
         var _loc3_= new PostRequest();
         _loc3_.writePostData("access_token",this._accessToken);
         _loc3_.writePostData("batch",com.adobe.serialization.json.JSON.encode(param1));
         var _loc4_= (param1.length : UInt);
         var _loc5_= (0 : UInt);
         while(_loc5_ < _loc4_)
         {
            _loc6_ = param1[(_loc5_ : Int)];
            _loc7_ = param2[(_loc5_ : Int)];
            if(ASCompat.toBool(_loc7_))
            {
               if(Std.isOfType(_loc7_ , Bitmap))
               {
                  _loc7_ = ASCompat.dynamicAs(_loc7_ , Bitmap).bitmapData;
               }
               if(ASCompat.isByteArray(_loc7_ ))
               {
                  _loc3_.writeFileData(_loc6_.attached_files,(_loc7_ : ByteArray) ,_loc6_.contentType);
               }
               else if(Std.isOfType(_loc7_ , BitmapData))
               {
                  _loc8_ = PNGEncoder.encode(ASCompat.dynamicAs(_loc7_ , BitmapData));
                  _loc3_.writeFileData(_loc6_.attached_files,_loc8_,"image/png");
               }
            }
            _loc5_++;
         }
         _loc3_.close();
         urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         urlRequest.data = _loc3_.getPostData();
         loadURLLoader();
      }
      
      override function handleDataReady() 
      {
         var _loc4_:ASObject = null;
         var _loc1_:Array<ASAny> = ASCompat.dynamicAs(_data , Array);
         var _loc2_= (_loc1_.length : UInt);
         var _loc3_= (0 : UInt);
         while(_loc3_ < _loc2_)
         {
            _loc4_ = com.adobe.serialization.json.JSON.decode(_data[Std.string(_loc3_)].body);
            ASCompat.setProperty(_data[Std.string(_loc3_)], "body", _loc4_);
            if(ASCompat.dynamicAs(this._batch.requests[(_loc3_ : Int)] , BatchItem).callback != null)
            {
               ASCompat.dynamicAs(this._batch.requests[(_loc3_ : Int)] , BatchItem).callback(_data[Std.string(_loc3_)]);
            }
            _loc3_++;
         }
      }
   }


