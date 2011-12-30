package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class DataTablesEvents extends Event
	{
		public static var CHANGE : String = "change";
		public static var UPDATE_DATA : String = "updateData";
		public static var UPDATE_STRUCTURE : String = "updateSrtucture";
		public static var SELECT_CONTEXT_ITEM_NEW : String = "selectContextItemNew";
		
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