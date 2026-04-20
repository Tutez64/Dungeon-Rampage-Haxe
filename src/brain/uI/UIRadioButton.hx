package brain.uI
;
   import brain.facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
    class UIRadioButton extends UIButton
   {
      
      static var mAllRadioButtons:Vector<UIRadioButton> = new Vector();
      
      var mGroup:String;
      
      public function new(param1:Facade, param2:MovieClip, param3:String)
      {
         super(param1,param2);
         mGroup = param3;
         mAllRadioButtons.push(this);
      }
      
      static function deselectAllInGroup(param1:UIRadioButton) 
      {
         var _loc2_:UIRadioButton;
         final __ax4_iter_161 = mAllRadioButtons;
         if (checkNullIteratee(__ax4_iter_161)) for (_tmp_ in __ax4_iter_161)
         {
            _loc2_ = _tmp_;
            if(_loc2_ != param1 && _loc2_.group == param1.group)
            {
               ASCompat.setProperty(_loc2_, "selected", false);
               ASCompat.setProperty(_loc2_, "enabled", _loc2_.enabled);
            }
         }
      }
      
      override public function destroy() 
      {
         mAllRadioButtons.splice(mAllRadioButtons.indexOf(this),(1 : UInt));
         super.destroy();
      }
      
      override public function  set_selected(param1:Bool) :Bool      {
         super.selected = param1;
         mRoot.buttonMode = !param1;
         mRoot.tabEnabled = !param1;
         if(mSelected)
         {
            deselectAllInGroup(this);
         }
return param1;
      }
      
            
      @:isVar public var group(get,set):String;
public function  get_group() : String
      {
         return mGroup;
      }
function  set_group(param1:String) :String      {
         return mGroup = param1;
      }
      
      override function onRelease(param1:MouseEvent) 
      {
         this.selected = true;
         super.onRelease(param1);
      }
   }


