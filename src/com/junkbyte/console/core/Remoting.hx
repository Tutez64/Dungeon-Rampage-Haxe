package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.net.Socket;
   import flash.system.Security;
   import flash.utils.ByteArray;
   
    class Remoting extends ConsoleCore
   {
      
      public static inline final NONE= (0 : UInt);
      
      public static inline final SENDER= (1 : UInt);
      
      public static inline final RECIEVER= (2 : UInt);
      
      var _callbacks:ASObject;
      
      var _mode:UInt = 0;
      
      var _local:LocalConnection;
      
      var _socket:Socket;
      
      var _sendBuffer:ByteArray;
      
      var _recBuffers:ASObject;
      
      var _senders:ASDictionary<ASAny,ASAny>;
      
      var _lastLogin:String = "";
      
      var _loggedIn:Bool = false;
      
      var _sendID:String;
      
      var _lastReciever:String;
      
      public function new(param1:Console)
      {
         var m= param1;
         this._callbacks = new ASObject();
         this._sendBuffer = new ByteArray();
         this._recBuffers = new ASObject();
         this._senders = new ASDictionary<ASAny,ASAny>();
         super(m);
         this.registerCallback("login",function(param1:ByteArray)
         {
            login(param1.readUTF());
         });
         this.registerCallback("requestLogin",this.requestLogin);
         this.registerCallback("loginFail",this.loginFail);
         this.registerCallback("loginSuccess",this.loginSuccess);
      }
      
      public function update() 
      {
         var _loc1_:String = null;
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         var _loc4_:ByteArray = null;
         if(this._sendBuffer.length != 0)
         {
            if(ASCompat.toBool(this._socket) && this._socket.connected)
            {
               this._socket.writeBytes(this._sendBuffer);
               this._sendBuffer = new ByteArray();
            }
            else if(this._local != null)
            {
               this._sendBuffer.position = (0 : UInt);
               if(this._sendBuffer.bytesAvailable < 38000)
               {
                  _loc2_ = this._sendBuffer;
                  this._sendBuffer = new ByteArray();
               }
               else
               {
                  _loc2_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc2_,(0 : UInt),(Std.int(Math.min(38000,this._sendBuffer.bytesAvailable)) : UInt));
                  _loc4_ = new ByteArray();
                  this._sendBuffer.readBytes(_loc4_);
                  this._sendBuffer = _loc4_;
               }
               _loc3_ = config.remotingConnectionName + (this.remoting == Remoting.RECIEVER ? SENDER : RECIEVER);
               this._local.send(_loc3_,"synchronize",this._sendID,_loc2_);
            }
            else
            {
               this._sendBuffer = new ByteArray();
            }
         }
         final __ax4_iter_89:ASObject = this._recBuffers;
         if (checkNullIteratee(__ax4_iter_89)) for(_tmp_ in __ax4_iter_89.___keys())
         {
            _loc1_  = _tmp_;
            this.processRecBuffer(_loc1_);
         }
      }
      
      function processRecBuffer(param1:String) 
      {
         var buffer:ByteArray;
         var pointer= (0 : UInt);
         var cmd:String = null;
         var arg:ByteArray = null;
         var callbackData:ASObject = null;
         var blen= (0 : UInt);
         var recbuffer:ByteArray = null;
         var id= param1;
         if(!ASCompat.toBool(this._senders[id]))
         {
            this._senders[id] = true;
            if(ASCompat.stringAsBool(this._lastReciever))
            {
               report("Remote switched to new sender [" + id + "] as primary.",-2);
            }
            this._lastReciever = id;
         }
         buffer = ASCompat.asByteArray(this._recBuffers[id]);
         try
         {
            pointer = (buffer.position = (0 : UInt) : UInt);
            while(buffer.bytesAvailable != 0)
            {
               cmd = buffer.readUTF();
               arg = null;
               if(buffer.bytesAvailable == 0)
               {
                  break;
               }
               if(buffer.readBoolean())
               {
                  if(buffer.bytesAvailable == 0)
                  {
                     break;
                  }
                  blen = buffer.readUnsignedInt();
                  if(buffer.bytesAvailable < blen)
                  {
                     break;
                  }
                  arg = new ByteArray();
                  buffer.readBytes(arg,(0 : UInt),blen);
               }
               callbackData = this._callbacks[cmd];
               if(!ASCompat.toBool(callbackData.latest) || id == this._lastReciever)
               {
                  if(arg != null)
                  {
                     callbackData.fun(arg);
                  }
                  else
                  {
                     callbackData.fun();
                  }
               }
               pointer = buffer.position;
            }
            if(pointer < buffer.length)
            {
               recbuffer = new ByteArray();
               recbuffer.writeBytes(buffer,pointer);
               this._recBuffers[id] = buffer = recbuffer;
            }
            else
            {
               ASCompat.deleteProperty(this._recBuffers, id);
            }
         }
         catch(err:Dynamic)
         {
            report("Remoting sync error: " + err,9);
         }
      }
      
      function synchronize(param1:String, param2:ASObject) 
      {
         if(!ASCompat.isByteArray(param2 ))
         {
            report("Remoting sync error. Recieved non-ByteArray:" + Std.string(param2),9);
            return;
         }
         var _loc3_= (param2 : ByteArray) ;
         var _loc4_= ASCompat.asByteArray(this._recBuffers[param1]);
         if(_loc4_ != null)
         {
            _loc4_.position = _loc4_.length;
            _loc4_.writeBytes(_loc3_);
         }
         else
         {
            this._recBuffers[param1] = _loc3_;
         }
      }
      
      public function send(param1:String, param2:ByteArray = null) : Bool
      {
         if(this._mode == NONE)
         {
            return false;
         }
         this._sendBuffer.position = this._sendBuffer.length;
         this._sendBuffer.writeUTF(param1);
         if(param2 != null)
         {
            this._sendBuffer.writeBoolean(true);
            this._sendBuffer.writeUnsignedInt(param2.length);
            this._sendBuffer.writeBytes(param2);
         }
         else
         {
            this._sendBuffer.writeBoolean(false);
         }
         return true;
      }
      
            
      @:isVar public var remoting(get,set):UInt;
public function  get_remoting() : UInt
      {
         return this._mode;
      }
      
      @:isVar public var canSend(get,never):Bool;
public function  get_canSend() : Bool
      {
         return this._mode == SENDER && this._loggedIn;
      }
function  set_remoting(param1:UInt) :UInt      {
         var _loc2_:String = null;
         if(param1 == this._mode)
         {
            return param1;
         }
         this._sendID = this.generateId();
         if(param1 == SENDER)
         {
            if(!this.startSharedConnection(SENDER))
            {
               report("Could not create remoting client service. You will not be able to control this console with remote.",10);
            }
            this._sendBuffer = new ByteArray();
            this._local.addEventListener(StatusEvent.STATUS,this.onSenderStatus,false,0,true);
            report("<b>Remoting started.</b> " + this.getInfo(),-1);
            this._loggedIn = this.checkLogin("");
            if(this._loggedIn)
            {
               this.sendLoginSuccess();
            }
            else
            {
               this.send("requestLogin");
            }
         }
         else if(param1 == RECIEVER)
         {
            if(this.startSharedConnection(RECIEVER))
            {
               this._sendBuffer = new ByteArray();
               this._local.addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onRemoteAsyncError,false,0,true);
               this._local.addEventListener(StatusEvent.STATUS,this.onRecieverStatus,false,0,true);
               report("<b>Remote started.</b> " + this.getInfo(),-1);
               _loc2_ = Security.sandboxType;
               if(_loc2_ == Security.LOCAL_WITH_FILE || _loc2_ == Security.LOCAL_WITH_NETWORK)
               {
                  report("Untrusted local sandbox. You may not be able to listen for logs properly.",10);
                  this.printHowToGlobalSetting();
               }
               this.login(this._lastLogin);
            }
            else
            {
               report("Could not create remote service. You might have a console remote already running.",10);
            }
         }
         else
         {
            this.close();
         }
         console.panels.updateMenu();
return param1;
      }
      
      public function remotingSocket(param1:String, param2:Int = 0) 
      {
         if(ASCompat.toBool(this._socket) && this._socket.connected)
         {
            this._socket.close();
            this._socket = null;
         }
         if(ASCompat.toBool(param1) && ASCompat.toBool(param2))
         {
            this.remoting = SENDER;
            report("Connecting to socket " + param1 + ":" + param2);
            this._socket = new Socket();
            this._socket.addEventListener(Event.CLOSE,this.socketCloseHandler);
            this._socket.addEventListener(Event.CONNECT,this.socketConnectHandler);
            this._socket.addEventListener(IOErrorEvent.IO_ERROR,this.socketIOErrorHandler);
            this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.socketSecurityErrorHandler);
            this._socket.addEventListener(ProgressEvent.SOCKET_DATA,this.socketDataHandler);
            this._socket.connect(param1,param2);
         }
      }
      
      function socketCloseHandler(param1:Event) 
      {
         if(param1.currentTarget == this._socket)
         {
            this._socket = null;
         }
      }
      
      function socketConnectHandler(param1:Event) 
      {
         report("Remoting socket connected.",-1);
         this._sendBuffer = new ByteArray();
         if(this._loggedIn || this.checkLogin(""))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("requestLogin");
         }
      }
      
      function socketIOErrorHandler(param1:Event) 
      {
         report("Remoting socket error." + param1,9);
         this.remotingSocket(null);
      }
      
      function socketSecurityErrorHandler(param1:Event) 
      {
         report("Remoting security error." + param1,9);
         this.remotingSocket(null);
      }
      
      function socketDataHandler(param1:Event) 
      {
         this.handleSocket(ASCompat.dynamicAs(param1.currentTarget , Socket));
      }
      
      public function handleSocket(param1:Socket) 
      {
         if(!ASCompat.toBool(this._senders[param1]))
         {
            this._senders[param1] = this.generateId();
            this._socket = param1;
         }
         var _loc2_= new ByteArray();
         param1.readBytes(_loc2_);
         this.synchronize(this._senders[param1],_loc2_);
      }
      
      function onSenderStatus(param1:StatusEvent) 
      {
         if(param1.level == "error" && !(this._socket != null && this._socket.connected))
         {
            this._loggedIn = false;
         }
      }
      
      function onRecieverStatus(param1:StatusEvent) 
      {
         if(this.remoting == Remoting.RECIEVER && param1.level == "error")
         {
            report("Problem communicating to client.",10);
         }
      }
      
      function onRemotingSecurityError(param1:SecurityErrorEvent) 
      {
         report("Remoting security error.",9);
         this.printHowToGlobalSetting();
      }
      
      function onRemoteAsyncError(param1:AsyncErrorEvent) 
      {
         report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.",10);
         this.remoting = NONE;
      }
      
      function getInfo() : String
      {
         return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
      }
      
      function printHowToGlobalSetting() 
      {
         report("Make sure your flash file is \'trusted\' in Global Security Settings.",-2);
         report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",-2);
      }
      
      function generateId() : String
      {
         return Date.now().getTime() + "." + Math.ffloor(Math.random() * 100000);
      }
      
      function startSharedConnection(param1:UInt) : Bool
      {
         var targetmode= param1;
         this.close();
         this._mode = targetmode;
         this._local = new LocalConnection();
         this._local.client = {"synchronize":this.synchronize};
         if(ASCompat.stringAsBool(config.allowedRemoteDomain))
         {
            this._local.allowDomain(config.allowedRemoteDomain);
            this._local.allowInsecureDomain(config.allowedRemoteDomain);
         }
         this._local.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onRemotingSecurityError,false,0,true);
         try
         {
            this._local.connect(config.remotingConnectionName + this._mode);
         }
         catch(err:Dynamic)
         {
            return false;
         }
         return true;
      }
      
      public function registerCallback(param1:String, param2:ASFunction, param3:Bool = false) 
      {
         this._callbacks[param1] = {
            "fun":param2,
            "latest":param3
         };
      }
      
      function loginFail() 
      {
         if(this.remoting != Remoting.RECIEVER)
         {
            return;
         }
         report("Login Failed",10);
         console.panels.mainPanel.requestLogin();
      }
      
      function sendLoginSuccess() 
      {
         this._loggedIn = true;
         this.send("loginSuccess");
         dispatchEvent(new Event(Event.CONNECT));
      }
      
      function loginSuccess() 
      {
         console.setViewingChannels();
         report("Login Successful",-1);
      }
      
      function requestLogin() 
      {
         if(this.remoting != Remoting.RECIEVER)
         {
            return;
         }
         this._sendBuffer = new ByteArray();
         if(ASCompat.stringAsBool(this._lastLogin))
         {
            this.login(this._lastLogin);
         }
         else
         {
            console.panels.mainPanel.requestLogin();
         }
      }
      
      public function login(param1:String = "") 
      {
         var _loc2_:ByteArray = null;
         if(this.remoting == Remoting.RECIEVER)
         {
            this._lastLogin = param1;
            report("Attempting to login...",-1);
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(param1);
            this.send("login",_loc2_);
         }
         else if(this._loggedIn || this.checkLogin(param1))
         {
            this.sendLoginSuccess();
         }
         else
         {
            this.send("loginFail");
         }
      }
      
      function checkLogin(param1:String) : Bool
      {
         return config.remotingPassword == null && config.keystrokePassword == param1 || config.remotingPassword == "" || config.remotingPassword == param1;
      }
      
      public function close() 
      {
         if(this._local != null)
         {
            try
            {
               this._local.close();
            }
            catch(error:Dynamic)
            {
               report("Remote.close: " + error,10);
            }
         }
         this._mode = NONE;
         this._sendBuffer = new ByteArray();
         this._local = null;
      }
   }


