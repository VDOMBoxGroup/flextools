package net.vdombox.ide.core.view.components
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.ide.core.view.skins.ComboBoxLoginSkin;
	
	import spark.components.ComboBox;

	public class ComboBoxLogin extends ComboBox
	{
		[Bindable]
		private var _editable : Boolean;
		
		[Bindable]
		private var _selecteble : Boolean;
		
		public function ComboBoxLogin()
		{ 
			super();
			_editable = true;
			_selecteble = true;
			
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ComboBoxLoginSkin );
		}
		
		public function set editable( value : Boolean ) : void
		{
			_editable = value; 
		}
		
		public function set selecteble( value : Boolean ) : void
		{
			_selecteble = value;
		}
		
		public function setEditable () : void
		{
			if (skin is ComboBoxLoginSkin)
			{
				(skin as ComboBoxLoginSkin).textInput.editable = _editable;
				(skin as ComboBoxLoginSkin).textInput.selectable = _selecteble;
			}
		}
		
		/*override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			super.item_mouseDownHandler(event);
			//event.stopImmediatePropagation();
		}*/
		
		override protected function capture_keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.END ||
				event.keyCode == Keyboard.HOME) 
				return;
			
			super.capture_keyDownHandler(event);
		}
	}
}