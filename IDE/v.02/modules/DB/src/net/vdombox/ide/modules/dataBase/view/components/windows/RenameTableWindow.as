package net.vdombox.ide.modules.dataBase.view.components.windows
{
	import flash.events.KeyboardEvent;
	
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