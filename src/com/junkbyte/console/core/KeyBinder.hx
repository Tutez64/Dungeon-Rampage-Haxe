package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   
    class KeyBinder extends ConsoleCore
   {
      
      var _passInd:Int = 0;
      
      var _binds:ASObject = {};
      
      var _warns:UInt = 0;
      
      public function new(param1:Console)
      {
         super(param1);
         param1.cl.addCLCmd("keybinds",this.printBinds,"List all keybinds used");
      }
      
      public function bindKey(param1:KeyBind, param2:ASFunction, param3:Array<ASAny> = null) 
      {
         if(ASCompat.toBool(config.keystrokePassword) && (!param1.useKeyCode && param1.key.charAt(0) == config.keystrokePassword.charAt(0)))
         {
            report("Error: KeyBind [" + param1.key + "] is conflicting with Console password.",9);
            return;
         }
         if(param2 == null)
         {
            ASCompat.deleteProperty(this._binds, param1.key);
         }
         else
         {
            this._binds[param1.key] = ([param2,param3] : Array<ASAny>);
         }
      }
      
      public function keyDownHandler(param1:KeyboardEvent) 
      {
         this.handleKeyEvent(param1,false);
      }
      
      public function keyUpHandler(param1:KeyboardEvent) 
      {
         this.handleKeyEvent(param1,true);
      }
      
      function handleKeyEvent(param1:KeyboardEvent, param2:Bool) 
      {
         var _loc4_:KeyBind = null;
         var _loc3_= String.fromCharCode((param1.charCode : Int));
         if(param2 && config.keystrokePassword != null && ASCompat.stringAsBool(_loc3_) && _loc3_ == config.keystrokePassword.substring(this._passInd,this._passInd + 1))
         {
            ++this._passInd;
            if(this._passInd >= config.keystrokePassword.length)
            {
               this._passInd = 0;
               if(this.canTrigger())
               {
                  if(console.visible && !console.panels.mainPanel.visible)
                  {
                     console.panels.mainPanel.visible = true;
                  }
                  else
                  {
                     console.visible = !console.visible;
                  }
                  if(console.visible && console.panels.mainPanel.visible)
                  {
                     console.panels.mainPanel.visible = true;
                     console.panels.mainPanel.moveBackSafePosition();
                  }
               }
               else if(this._warns < 3)
               {
                  ++this._warns;
                  report("Password did not trigger because you have focus on an input TextField.",8);
               }
            }
         }
         else
         {
            if(param2)
            {
               this._passInd = 0;
            }
            _loc4_ = new KeyBind(param1.keyCode,param1.shiftKey,param1.ctrlKey,param1.altKey,param2);
            this.tryRunKey(_loc4_.key);
            if(ASCompat.stringAsBool(_loc3_))
            {
               _loc4_ = new KeyBind(_loc3_,param1.shiftKey,param1.ctrlKey,param1.altKey,param2);
               this.tryRunKey(_loc4_.key);
            }
         }
      }
      
      function printBinds(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc3_:String = null;
         report("Key binds:",-2);
         var _loc2_= (0 : UInt);
         final __ax4_iter_87:ASObject = this._binds;
         if (checkNullIteratee(__ax4_iter_87)) for(_tmp_ in __ax4_iter_87.___keys())
         {
            _loc3_  = _tmp_;
            _loc2_++;
            report(_loc3_,-2);
         }
         report("--- Found " + _loc2_,-2);
      }
      
      function tryRunKey(param1:String) 
      {
         var _loc2_:Array<ASAny> = ASCompat.dynamicAs(this._binds[param1], Array);
         if(config.keyBindsEnabled && ASCompat.toBool(_loc2_))
         {
            if(this.canTrigger())
            {
               ASCompatMacro.applyClosure(ASCompat.asFunction(_loc2_[0] ), _loc2_[1]);
            }
            else if(this._warns < 3)
            {
               ++this._warns;
               report("Key bind [" + param1 + "] did not trigger because you have focus on an input TextField.",8);
            }
         }
      }
      
      function canTrigger() : Bool
      {
         var txt:TextField = null;
         try
         {
            if(ASCompat.toBool(console.stage) && Std.isOfType(console.stage.focus , TextField))
            {
               txt = ASCompat.reinterpretAs(console.stage.focus , TextField);
               if(txt.type == TextFieldType.INPUT)
               {
                  return false;
               }
            }
         }
         catch(err:Dynamic)
         {
         }
         return true;
      }
   }


