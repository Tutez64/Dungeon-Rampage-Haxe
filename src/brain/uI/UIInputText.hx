package brain.uI
;
   import brain.facade.Facade;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
    class UIInputText extends UIObject
   {
      
      var mTextField:TextField;
      
      var mDefaultText:String;
      
      var mDefaultTextColor:UInt = (8947848 : UInt);
      
      var mNormalTextColor:UInt = (0 : UInt);
      
      var mShowingDefaultText:Bool = false;
      
      var mChangeCallback:ASFunction;
      
      var mEnterCallback:ASFunction;
      
      var mCancelCallback:ASFunction;
      
      public function new(param1:Facade, param2:MovieClip)
      {
         mTextField = ASCompat.dynamicAs((param2 : ASAny).textField, flash.text.TextField);
         super(param1,param2);
         mTextField.addEventListener("mouseDown",onPress);
         mTextField.addEventListener("change",onChange);
         mTextField.addEventListener("keyDown",onKeyDown);
         mTextField.addEventListener("keyUp",onKeyUp);
         mTextField.addEventListener("focusIn",onFocusIn);
         mTextField.addEventListener("focusOut",onFocusOut);
      }
      
      function onPress(param1:MouseEvent) 
      {
         param1.stopImmediatePropagation();
         mTextField.addEventListener("mouseUp",onRelease);
      }
      
      function onRelease(param1:MouseEvent) 
      {
         param1.stopImmediatePropagation();
         mTextField.removeEventListener("mouseUp",onRelease);
      }
      
      @:isVar public var defaultTextColor(never,set):UInt;
public function  set_defaultTextColor(param1:UInt) :UInt      {
         mDefaultTextColor = param1;
         if(mShowingDefaultText)
         {
            mTextField.textColor = mDefaultTextColor;
         }
return param1;
      }
      
      @:isVar public var normalTextColor(never,set):UInt;
public function  set_normalTextColor(param1:UInt) :UInt      {
         mNormalTextColor = param1;
         if(!mShowingDefaultText)
         {
            mTextField.textColor = mNormalTextColor;
         }
return param1;
      }
      
      @:isVar public var defaultText(never,set):String;
public function  set_defaultText(param1:String) :String      {
         mDefaultText = param1;
         mTextField.text = mDefaultText;
         mTextField.textColor = mDefaultTextColor;
         mShowingDefaultText = true;
return param1;
      }
      
            
      @:isVar public var text(get,set):String;
public function  get_text() : String
      {
         if(mShowingDefaultText)
         {
            return "";
         }
         return mTextField.text;
      }
function  set_text(param1:String) :String      {
         return mTextField.text = param1;
      }
      
      function onFocusIn(param1:FocusEvent) 
      {
         if(mShowingDefaultText)
         {
            this.clear();
            mShowingDefaultText = false;
            mTextField.textColor = mNormalTextColor;
         }
      }
      
      function onFocusOut(param1:FocusEvent) 
      {
      }
      
      @:isVar public var textField(get,never):TextField;
public function  get_textField() : TextField
      {
         return mTextField;
      }
      
      function onKeyDown(param1:KeyboardEvent) 
      {
         if(param1.keyCode == 13 && mEnterCallback != null && !mShowingDefaultText)
         {
            if(mTextField != null)
            {
               mEnterCallback(mTextField.text);
            }
            param1.stopPropagation();
         }
         else if(param1.keyCode == 27 && mCancelCallback != null)
         {
            mCancelCallback();
            param1.stopPropagation();
         }
         else if(!(param1.ctrlKey && (param1.keyCode == 86 || param1.keyCode == 67 || param1.keyCode == 88)))
         {
            param1.stopPropagation();
         }
      }
      
      function onKeyUp(param1:KeyboardEvent) 
      {
         if(!(param1.ctrlKey && (param1.keyCode == 86 || param1.keyCode == 67 || param1.keyCode == 88)))
         {
            param1.stopPropagation();
         }
      }
      
      function onChange(param1:Event) 
      {
         if(mChangeCallback != null)
         {
            mChangeCallback(mTextField.text);
         }
      }
      
      public function clear() 
      {
         mTextField.text = "";
         if(mChangeCallback != null)
         {
            mChangeCallback("");
         }
      }
      
      @:isVar public var changeCallback(never,set):ASFunction;
public function  set_changeCallback(param1:ASFunction) :ASFunction      {
         return mChangeCallback = param1;
      }
      
      @:isVar public var enterCallback(never,set):ASFunction;
public function  set_enterCallback(param1:ASFunction) :ASFunction      {
         return mEnterCallback = param1;
      }
      
      @:isVar public var cancelCallback(never,set):ASFunction;
public function  set_cancelCallback(param1:ASFunction) :ASFunction      {
         return mCancelCallback = param1;
      }
      
      override public function  set_enabled(param1:Bool) :Bool      {
         super.enabled = param1;
         return mTextField.tabEnabled = param1;
      }
      
      override public function destroy() 
      {
         super.destroy();
         mTextField.removeEventListener("mouseDown",onPress);
         mTextField.removeEventListener("mouseUp",onRelease);
         mTextField.removeEventListener("change",onChange);
         mTextField.removeEventListener("keyDown",onKeyDown);
         mTextField.removeEventListener("keyUp",onKeyUp);
         mTextField.removeEventListener("focusIn",onFocusIn);
         mTextField.removeEventListener("focusOut",onFocusOut);
         mTextField = null;
         mChangeCallback = null;
         mEnterCallback = null;
         mCancelCallback = null;
      }
   }


