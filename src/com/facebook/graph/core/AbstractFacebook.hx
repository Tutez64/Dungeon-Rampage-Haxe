package com.facebook.graph.core
;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookAuthResponse;
   import com.facebook.graph.data.FacebookSession;
   import com.facebook.graph.net.FacebookBatchRequest;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.FQLMultiQueryParser;
   import com.facebook.graph.utils.IResultParser;
   import flash.net.URLRequestMethod;
   
    class AbstractFacebook
   {
      
      var session:FacebookSession;
      
      var authResponse:FacebookAuthResponse;
      
      var oauth2:Bool = false;
      
      var openRequests:ASDictionary<ASAny,ASAny>;
      
      var resultHash:ASDictionary<ASAny,ASAny>;
      
      var _locale/*renamed*/:String;
      
      var parserHash:ASDictionary<ASAny,ASAny>;
      
      public function new()
      {
         
         this.openRequests = new ASDictionary<ASAny,ASAny>();
         this.resultHash = new ASDictionary<ASAny,ASAny>(true);
         this.parserHash = new ASDictionary<ASAny,ASAny>();
      }
      
      @:isVar var accessToken(get,never):String;
function  get_accessToken() : String
      {
         if(this.oauth2 && this.authResponse != null || this.session != null)
         {
            return this.oauth2 ? this.authResponse.accessToken : this.session.accessToken;
         }
         return null;
      }
      
      function _api/*renamed*/(param1:String, param2:ASFunction = null, param3:ASAny = null, param4:String = "GET") 
      {
         param1 = param1.indexOf("/") != 0 ? "/" + param1 : param1;
         if(ASCompat.stringAsBool(this.accessToken))
         {
            if(param3 == null)
            {
               param3 = {};
            }
            if(param3.access_token == null)
            {
               ASCompat.setProperty(param3, "access_token", this.accessToken);
            }
         }
         var _loc5_= new FacebookRequest();
         if(ASCompat.stringAsBool(this._locale))
         {
            ASCompat.setProperty(param3, "locale", this._locale);
         }
         this.openRequests[_loc5_] = param2;
         _loc5_.call(FacebookURLDefaults.GRAPH_URL + param1,param4,this.handleRequestLoad,param3);
      }
      
      function _uploadVideo/*renamed*/(param1:String, param2:ASFunction = null, param3:ASAny = null) 
      {
         param1 = param1.indexOf("/") != 0 ? "/" + param1 : param1;
         if(ASCompat.stringAsBool(this.accessToken))
         {
            if(param3 == null)
            {
               param3 = {};
            }
            if(param3.access_token == null)
            {
               ASCompat.setProperty(param3, "access_token", this.accessToken);
            }
         }
         var _loc4_= new FacebookRequest();
         if(ASCompat.stringAsBool(this._locale))
         {
            ASCompat.setProperty(param3, "locale", this._locale);
         }
         this.openRequests[_loc4_] = param2;
         _loc4_.call(FacebookURLDefaults.VIDEO_URL + param1,"POST",this.handleRequestLoad,param3);
      }
      
      function pagingCall(param1:String, param2:ASFunction) : FacebookRequest
      {
         var _loc3_= new FacebookRequest();
         this.openRequests[_loc3_] = param2;
         _loc3_.callURL(this.handleRequestLoad,param1,this._locale);
         return _loc3_;
      }
      
      function _getRawResult/*renamed*/(param1:ASObject) : ASObject
      {
         return this.resultHash[param1];
      }
      
      function _nextPage/*renamed*/(param1:ASObject, param2:ASFunction = null) : FacebookRequest
      {
         var _loc3_:FacebookRequest = null;
         var _loc4_:ASObject = this._getRawResult(param1);
         if(ASCompat.toBool(_loc4_) && ASCompat.toBool(_loc4_.paging) && ASCompat.toBool(_loc4_.paging.next))
         {
            _loc3_ = this.pagingCall(_loc4_.paging.next,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
         return _loc3_;
      }
      
      function _previousPage/*renamed*/(param1:ASObject, param2:ASFunction = null) : FacebookRequest
      {
         var _loc3_:FacebookRequest = null;
         var _loc4_:ASObject = this._getRawResult(param1);
         if(ASCompat.toBool(_loc4_) && ASCompat.toBool(_loc4_.paging) && ASCompat.toBool(_loc4_.paging.previous))
         {
            _loc3_ = this.pagingCall(_loc4_.paging.previous,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
         return _loc3_;
      }
      
      function handleRequestLoad(param1:FacebookRequest) 
      {
         var _loc3_:ASObject = null;
         var _loc4_:IResultParser = null;
         var _loc2_= ASCompat.asFunction(this.openRequests[param1]);
         if(_loc2_ == null)
         {
            this.openRequests.remove(param1);
         }
         if(param1.success)
         {
            _loc3_ = param1.data.hasOwnProperty("data" ) ? param1.data.data : param1.data;
            this.resultHash[_loc3_] = param1.data;
            if(_loc3_.hasOwnProperty("error_code"))
            {
               _loc2_(null,_loc3_);
            }
            else
            {
               if(Std.isOfType(this.parserHash[param1] , IResultParser))
               {
                  _loc4_ = ASCompat.dynamicAs(this.parserHash[param1] , IResultParser);
                  _loc3_ = _loc4_.parse(_loc3_);
                  this.parserHash[param1] = null;
                  this.parserHash.remove(param1);
               }
               _loc2_(_loc3_,null);
            }
         }
         else
         {
            _loc2_(null,param1.data);
         }
         this.openRequests.remove(param1);
      }
      
      function _callRestAPI/*renamed*/(param1:String, param2:ASFunction = null, param3:ASAny = null, param4:String = "GET") 
      {
         var _loc6_:IResultParser = null;
         if(param3 == null)
         {
            param3 = {};
         }
         ASCompat.setProperty(param3, "format", "json");
         if(ASCompat.stringAsBool(this.accessToken))
         {
            ASCompat.setProperty(param3, "access_token", this.accessToken);
         }
         if(ASCompat.stringAsBool(this._locale))
         {
            ASCompat.setProperty(param3, "locale", this._locale);
         }
         var _loc5_= new FacebookRequest();
         this.openRequests[_loc5_] = param2;
         if(Std.isOfType(this.parserHash[param3["queries"]] , IResultParser))
         {
            _loc6_ = ASCompat.dynamicAs(this.parserHash[param3["queries"]] , IResultParser);
            this.parserHash[param3["queries"]] = null;
            this.parserHash.remove(param3["queries"]);
            this.parserHash[_loc5_] = _loc6_;
         }
         _loc5_.call(FacebookURLDefaults.API_URL + "/method/" + param1,param4,this.handleRequestLoad,param3);
      }
      
      function _fqlQuery/*renamed*/(param1:String, param2:ASFunction = null, param3:ASObject = null) 
      {
         var _loc4_:String = null;
         if (checkNullIteratee(param3)) for(_tmp_ in param3.___keys())
         {
            _loc4_  = _tmp_;
            param1 = new compat.RegExp("\\{" + _loc4_ + "\\}","g").replace(param1,param3[_loc4_]);
         }
         this._callRestAPI("fql.query",param2,{"query":param1});
      }
      
      function _fqlMultiQuery/*renamed*/(param1:FQLMultiQuery, param2:ASFunction = null, param3:IResultParser = null) 
      {
         this.parserHash[param1.toString()] = param3 != null ? param3 : new FQLMultiQueryParser();
         this._callRestAPI("fql.multiquery",param2,{"queries":param1.toString()});
      }
      
      function _batchRequest/*renamed*/(param1:Batch, param2:ASFunction = null) 
      {
         var _loc3_:FacebookBatchRequest = null;
         if(ASCompat.stringAsBool(this.accessToken))
         {
            _loc3_ = new FacebookBatchRequest(param1,param2);
            this.resultHash[_loc3_] = true;
            _loc3_.call(this.accessToken);
         }
      }
      
      function _deleteObject/*renamed*/(param1:String, param2:ASFunction = null) 
      {
         var _loc3_:ASObject = {"method":"delete"};
         this._api(param1,param2,_loc3_,URLRequestMethod.POST);
      }
      
      function _getImageUrl/*renamed*/(param1:String, param2:String = null) : String
      {
         return FacebookURLDefaults.GRAPH_URL + "/" + param1 + "/picture" + (param2 != null ? "?type=" + param2 : "");
      }
   }


