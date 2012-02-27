package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class DataTablesEvents extends Event
	{
		public static var CHANGE : String = "change";
		public static var UPDATE_DATA : String = "updateData";
		public static var UPDATE_STRUCTURE : String = "updateSrtucture";
		public static var NEW_BASE : String = "newBase";
		public static var NEW_TABLE : String = "newTable";
		public static var GO_TO_BASE : String = "goToBase";
		
		public static var CHANGE_ROWS_IN_PAGE : String = "changeRowsInPage";
		
		public var content : Object;
		
		public function DataTablesEvents( type : String, bubbles : Boolean = false,
										  cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ToolsetEvent( type, bubbles, cancelable );
		}
	}
}