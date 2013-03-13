package net.vdombox.ide.common.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.view.skins.windows.GenerateGetterSetterWindowSkin;
	
	import spark.components.Window;

	public class GenerateGettesSetterWindow extends Window
	{
		private var _variable : String;
		private var _getSet : String;
		
		private var _getter : Boolean = true;
		private var _setter : Boolean = true;
		
		public function GenerateGettesSetterWindow( variable : String )
		{
			this.variable = variable;
			
			var index : int = variable.indexOf('self.');
			
			if ( index != -1 )
				getSet = variable.substring(0, index) + variable.substring(index + 5, variable.length);
			else
				getSet = variable;
			
			super();
			
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			
			width = 400;
			height = 170;
			
			minWidth = 400;
			minHeight = 170;
			
			maxWidth = 400;
			maxHeight = 170;
			
			addEventListener( KeyboardEvent.KEY_DOWN, keyDownEnterEscHandler, true, 0 , true );
			
			this.setFocus();
		}
		
		[Bindable]
		public function get setter():Boolean
		{
			return _setter;
		}

		public function set setter(value:Boolean):void
		{
			_setter = value;
		}

		[Bindable]
		public function get getter():Boolean
		{
			return _getter;
		}

		public function set getter(value:Boolean):void
		{
			_getter = value;
		}

		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", GenerateGetterSetterWindowSkin );
		}
		
		[Bindable]
		public function get getSet():String
		{
			return _getSet;
		}

		public function set getSet(value:String):void
		{
			_getSet = value;
		}

		[Bindable]
		public function get variable():String
		{
			return _variable;
		}

		public function set variable(value:String):void
		{
			_variable = value;
		}

		private function keyDownEnterEscHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == Keyboard.ENTER )
				ok_close_window();
			else if ( event.keyCode == Keyboard.ESCAPE )
				no_close_window();
		}
		
		public function ok_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, variable, getSet ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );
		}
	}
}