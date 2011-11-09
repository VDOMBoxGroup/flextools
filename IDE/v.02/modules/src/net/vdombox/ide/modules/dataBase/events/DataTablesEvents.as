package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class DataTablesEvents extends Event
	{
		public static var CHANGE : String = "change";
		
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