package com.junkbyte.console.view
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
    class ConsolePanel extends Sprite
   {
      
      public static inline final DRAGGING_STARTED= "draggingStarted";
      
      public static inline final DRAGGING_ENDED= "draggingEnded";
      
      public static inline final SCALING_STARTED= "scalingStarted";
      
      public static inline final SCALING_ENDED= "scalingEnded";
      
      public static inline final VISIBLITY_CHANGED= "visibilityChanged";
      
      static inline final TEXT_ROLL= "TEXT_ROLL";
      
      var _snaps:Array<ASAny>;
      
      var _dragOffset:Point;
      
      var _resizeTxt:TextField;
      
      var console:Console;
      
      var bg:Sprite;
      
      var scaler:Sprite;
      
      var txtField:TextField;
      
      var minWidth:Int = 18;
      
      var minHeight:Int = 18;
      
      var _movedFrom:Point;
      
      public var moveable:Bool = true;
      
      public function new(param1:Console)
      {
         super();
         this.console = param1;
         this.bg = new Sprite();
         this.bg.name = "background";
         addChild(this.bg);
      }
      
      static function onTextFieldMouseOut(param1:MouseEvent) 
      {
         cast(param1.currentTarget, TextField).dispatchEvent(new TextEvent(TEXT_ROLL));
      }
      
      static function onTextFieldMouseMove(param1:MouseEvent) 
      {
         var url:String;
         var index= 0;
         var scrollH= Math.NaN;
         var w= Math.NaN;
         var X:compat.XML = null;
         var txtformat:compat.XML = null;
         var e= param1;
         var field= ASCompat.dynamicAs(e.currentTarget , TextField);
         if(field.scrollH > 0)
         {
            scrollH = field.scrollH;
            w = field.width;
            field.width = w + scrollH;
            index = field.getCharIndexAtPoint(field.mouseX + scrollH,field.mouseY);
            field.width = w;
            field.scrollH = Std.int(scrollH);
         }
         else
         {
            index = field.getCharIndexAtPoint(field.mouseX,field.mouseY);
         }
         url = null;
         if(index > 0)
         {
            try
            {
               X = new compat.XML(ASCompat.textFieldGetXMLText(field, index,index + 1));
               if(X.hasOwnProperty("textformat"))
               {
                  txtformat = ASCompat.asXML(ASCompat.dynGetIndex((X : ASAny)["textformat"], 0) );
                  if(txtformat != null)
                  {
                     url = txtformat.attribute("url");
                  }
               }
            }
            catch(err:Dynamic)
            {
               url = null;
            }
         }
         field.dispatchEvent(new TextEvent(TEXT_ROLL,false,false,url));
      }
      
      @:isVar var config(get,never):ConsoleConfig;
function  get_config() : ConsoleConfig
      {
         return this.console.config;
      }
      
      @:isVar var style(get,never):ConsoleStyle;
function  get_style() : ConsoleStyle
      {
         return this.console.config.style;
      }
      
      function init(param1:Float, param2:Float, param3:Bool = false, param4:Float = -1, param5:Float = -1, param6:Int = -1) 
      {
         this.bg.graphics.clear();
         this.bg.graphics.beginFill((ASCompat.toInt(param4 >= 0 ? (Std.int(param4) : UInt) : this.style.backgroundColor) : UInt),param5 >= 0 ? param5 : this.style.backgroundAlpha);
         if(param6 < 0)
         {
            param6 = this.style.roundBorder;
         }
         if(param6 <= 0)
         {
            this.bg.graphics.drawRect(0,0,100,100);
         }
         else
         {
            this.bg.graphics.drawRoundRect(0,0,param6 + 10,param6 + 10,param6,param6);
            this.bg.scale9Grid = new Rectangle(param6 * 0.5,param6 * 0.5,10,10);
         }
         this.scalable = param3;
         this.width = param1;
         this.height = param2;
      }
      
      public function close() 
      {
         this.stopDragging();
         this.console.panels.tooltip();
         if(parent != null)
         {
            parent.removeChild(this);
         }
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      override public function  set_visible(param1:Bool)       {
         super.visible = param1;
         dispatchEvent(new Event(VISIBLITY_CHANGED));
return param1;
      }
      
      override public function  set_width(param1:Float)       {
         if(param1 < this.minWidth)
         {
            param1 = this.minWidth;
         }
         if(this.scaler != null)
         {
            this.scaler.x = param1;
         }
         return this.bg.width = param1;
      }
      
      override public function  set_height(param1:Float)       {
         if(param1 < this.minHeight)
         {
            param1 = this.minHeight;
         }
         if(this.scaler != null)
         {
            this.scaler.y = param1;
         }
         return this.bg.height = param1;
      }
      
      override public function  get_width() : Float
      {
         return this.bg.width;
      }
      
      override public function  get_height() : Float
      {
         return this.bg.height;
      }
      
      public function registerSnaps(param1:Array<ASAny>, param2:Array<ASAny>) 
      {
         this._snaps = [param1,param2];
      }
      
      function registerDragger(param1:DisplayObject, param2:Bool = false) 
      {
         if(param2)
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown);
         }
         else
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onDraggerMouseDown,false,0,true);
         }
      }
      
      function onDraggerMouseDown(param1:MouseEvent) 
      {
         if(stage == null || !this.moveable)
         {
            return;
         }
         this._resizeTxt = this.makeTF("positioningField",true);
         this._resizeTxt.mouseEnabled = false;
         this._resizeTxt.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._resizeTxt);
         this.updateDragText();
         this._movedFrom = new Point(x,y);
         this._dragOffset = new Point(mouseX,mouseY);
         this._snaps = [[],[]];
         dispatchEvent(new Event(DRAGGING_STARTED));
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove,false,0,true);
      }
      
      function onDraggerMouseMove(param1:MouseEvent = null) 
      {
         if(this.style.panelSnapping == 0)
         {
            return;
         }
         var _loc2_= this.returnSnappedFor(parent.mouseX - this._dragOffset.x,parent.mouseY - this._dragOffset.y);
         x = _loc2_.x;
         y = _loc2_.y;
         this.updateDragText();
      }
      
      function updateDragText() 
      {
         this._resizeTxt.text = "<low>" + x + "," + y + "</low>";
      }
      
      function onDraggerMouseUp(param1:MouseEvent) 
      {
         this.stopDragging();
      }
      
      function stopDragging() 
      {
         this._snaps = null;
         if(stage != null)
         {
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.onDraggerMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onDraggerMouseMove);
         }
         if(ASCompat.toBool(this._resizeTxt) && ASCompat.toBool(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
         dispatchEvent(new Event(DRAGGING_ENDED));
      }
      
      public function moveBackSafePosition() 
      {
         if(this._movedFrom != null)
         {
            if(x + this.width < 10 || stage != null && stage.stageWidth < x + 10 || y + this.height < 10 || stage != null && stage.stageHeight < y + 20)
            {
               x = this._movedFrom.x;
               y = this._movedFrom.y;
            }
            this._movedFrom = null;
         }
      }
      
            
      @:isVar public var scalable(get,set):Bool;
public function  get_scalable() : Bool
      {
         return this.scaler != null ? true : false;
      }
function  set_scalable(param1:Bool) :Bool      {
         var _loc2_= (0 : UInt);
         if(param1 && this.scaler == null)
         {
            _loc2_ = (Std.int(8 + this.style.controlSize * 0.5) : UInt);
            this.scaler = new Sprite();
            this.scaler.name = "scaler";
            this.scaler.graphics.beginFill((0 : UInt),0);
            this.scaler.graphics.drawRect(-_loc2_ * 1.5,-_loc2_ * 1.5,_loc2_ * 1.5,_loc2_ * 1.5);
            this.scaler.graphics.endFill();
            this.scaler.graphics.beginFill(this.style.controlColor,this.style.backgroundAlpha);
            this.scaler.graphics.moveTo(0,0);
            this.scaler.graphics.lineTo(-_loc2_,0);
            this.scaler.graphics.lineTo(0,-_loc2_);
            this.scaler.graphics.endFill();
            this.scaler.buttonMode = true;
            this.scaler.doubleClickEnabled = true;
            this.scaler.addEventListener(MouseEvent.MOUSE_DOWN,this.onScalerMouseDown,false,0,true);
            addChildAt(this.scaler,getChildIndex(this.bg) + 1);
         }
         else if(!param1 && ASCompat.toBool(this.scaler))
         {
            if(contains(this.scaler))
            {
               removeChild(this.scaler);
            }
            this.scaler = null;
         }
return param1;
      }
      
      function onScalerMouseDown(param1:Event) 
      {
         this._resizeTxt = this.makeTF("resizingField",true);
         this._resizeTxt.mouseEnabled = false;
         this._resizeTxt.autoSize = TextFieldAutoSize.RIGHT;
         this._resizeTxt.x = -4;
         this._resizeTxt.y = -17;
         this.scaler.addChild(this._resizeTxt);
         this.updateScaleText();
         this._dragOffset = new Point(this.scaler.mouseX,this.scaler.mouseY);
         this._snaps = [[],[]];
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp,false,0,true);
         this.scaler.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.updateScale,false,0,true);
         dispatchEvent(new Event(SCALING_STARTED));
      }
      
      function updateScale(param1:Event = null) 
      {
         var _loc2_= this.returnSnappedFor(x + mouseX - this._dragOffset.x,y + mouseY - this._dragOffset.x);
         _loc2_.x -= x;
         _loc2_.y -= y;
         this.width = _loc2_.x < this.minWidth ? this.minWidth : _loc2_.x;
         this.height = _loc2_.y < this.minHeight ? this.minHeight : _loc2_.y;
         this.updateScaleText();
      }
      
      function updateScaleText() 
      {
         this._resizeTxt.text = "<low>" + this.width + "," + this.height + "</low>";
      }
      
      public function stopScaling() 
      {
         this.onScalerMouseUp(null);
      }
      
      function onScalerMouseUp(param1:Event) 
      {
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScalerMouseUp);
         this.scaler.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.updateScale);
         this.updateScale();
         this._snaps = null;
         if(ASCompat.toBool(this._resizeTxt) && ASCompat.toBool(this._resizeTxt.parent))
         {
            this._resizeTxt.parent.removeChild(this._resizeTxt);
         }
         this._resizeTxt = null;
         dispatchEvent(new Event(SCALING_ENDED));
      }
      
      public function makeTF(param1:String, param2:Bool = false) : TextField
      {
         var _loc3_= new TextField();
         _loc3_.name = param1;
         _loc3_.styleSheet = this.style.styleSheet;
         if(param2)
         {
            _loc3_.background = true;
            _loc3_.backgroundColor = this.style.backgroundColor;
         }
         return _loc3_;
      }
      
      function returnSnappedFor(param1:Float, param2:Float) : Point
      {
         return new Point(this.getSnapOf(param1,true),this.getSnapOf(param2,false));
      }
      
      function getSnapOf(param1:Float, param2:Bool) : Float
      {
         var _loc6_= Math.NaN;
         var _loc3_= param1 + this.width;
         var _loc4_:Array<ASAny> = ASCompat.dynamicAs(this._snaps[param2 ? 0 : 1], Array);
         var _loc5_= this.style.panelSnapping;
         if (checkNullIteratee(_loc4_)) for (_tmp_ in _loc4_)
         {
            _loc6_  = ASCompat.toNumber(_tmp_);
            if(Math.abs(_loc6_ - param1) < _loc5_)
            {
               return _loc6_;
            }
            if(Math.abs(_loc6_ - _loc3_) < _loc5_)
            {
               return _loc6_ - this.width;
            }
         }
         return param1;
      }
      
      function registerTFRoller(param1:TextField, param2:ASFunction, param3:ASFunction = null) 
      {
         param1.addEventListener(MouseEvent.MOUSE_MOVE,onTextFieldMouseMove,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,onTextFieldMouseOut,false,0,true);
         param1.addEventListener(TEXT_ROLL,param2,false,0,true);
         if(param3 != null)
         {
            param1.addEventListener(TextEvent.LINK,param3,false,0,true);
         }
      }
   }


