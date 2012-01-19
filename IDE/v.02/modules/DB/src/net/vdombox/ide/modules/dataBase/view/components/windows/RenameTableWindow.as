package net.vdombox.ide.modules.dataBase.view.components.windows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.ide.modules.dataBase.events.PopUpWindowEvent;
	import net.vdombox.ide.modules.dataBase.view.skins.RenameTableWindowSkin;
	
	import spark.components.TextInput;
	import spark.components.Window;

	public class RenameTableWindow extends Window
	{
		private var _nameTable : String;
		
		[SkinPart( required="true" )]
		public var tableName : TextInput;
		
		public function RenameTableWindow( __nameTable : String )
		{
			super();
			
			width = 400;
			height = 95;
			
			minWidth = 400;
			minHeight = 95;
			
			_nameTable = __nameTable;
			title = resourceManager.getString( "DataBase_General", "renaem_table_window_title" );
			
			addEventListener( KeyboardEvent.KEY_DOWN, keyDownEnterEscHandler, true, 0 , true );
			
			this.setFocus();
		}
		
		[Bindable]
		public function get nameTable():String
		{
			return _nameTable;
		}

		public function set nameTable(value:String):void
		{
			_nameTable = value;
		}
		
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", RenameTableWindowSkin );
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
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, tableName.text ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );
			
		}

	}
}