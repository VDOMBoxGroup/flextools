package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class TableElementEvent extends Event
	{
		public static var CHANGE : String = "changeTable";

		public static var CREATION_COMPLETE : String = "creationCompleteTable";

		public static var SAVE : String = "saveTable";

		public static var NAME_CHANGE : String = "nameChangeTable";

		public static var GO_TO_TABLE : String = "goToTable";

		public static var DELETE : String = "deleteTable";

		public var value : Object;

		public function TableElementEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			var newEvent : TableElementEvent = new TableElementEvent( type, bubbles, cancelable );
			newEvent.value = value;
			return newEvent;
		}
	}
}
