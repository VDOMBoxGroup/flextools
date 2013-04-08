package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class ToolBoxPanelEvent extends Event
	{
		public static var SORT_ELEMENT_CHANGE : String = "sortElementChange";

		public static var SORT_CHANGE : String = "sortChange";

		public static var UP_QUERY_SIMPLE : String = "upQuerySimple";

		public static var DOWN_QUERY_SIMPLE : String = "downQuerySimple";

		public static var REMOVE_QUERY_SIMPLE : String = "removeQuerySimple";

		public static var SEND_QUERY_SIMPLE_CLICK : String = "sendQuerySimpleClick";

		public static var QUERY_SIMPLE_CHANGE : String = "querySimpleChange";

		public var value : String;

		public function ToolBoxPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			var cloneEvent : ToolBoxPanelEvent = new ToolBoxPanelEvent( type, bubbles, cancelable );
			cloneEvent.value = value;
			return cloneEvent;
		}
	}
}
