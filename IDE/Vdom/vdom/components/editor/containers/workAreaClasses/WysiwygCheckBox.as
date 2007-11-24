package vdom.components.editor.containers.workAreaClasses {
	
import flash.events.MouseEvent;

import mx.controls.CheckBox;
import flash.events.FocusEvent;
import mx.managers.IFocusManager;

public class WysiwygCheckBox extends CheckBox {
	
	public function WysiwygCheckBox() {
		
		super();
	}
	
	override protected function clickHandler(event:MouseEvent):void {
		
		if (!enabled || selected)
			return; // prevent a selected button from dispatching "click"
	}
	
	override protected function focusInHandler(event:FocusEvent):void
    {
        //if (event.target == this)
           // systemManager.stage.focus = textField;

        var fm:IFocusManager = focusManager;

        if (fm)
        {
            fm.showFocusIndicator = true;
            
        }
		fm.showFocus();
        super.focusInHandler(event);
    }
	
}
}