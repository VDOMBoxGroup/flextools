package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;

	public class ObjectTreePanelEvent extends Event
	{
		public static var NAME_CHANGE : String = "nameChangeTable";

		public static var DELETE : String = "deleteTable";

		public var value : Object;

		public function ObjectTreePanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			var newEvent : ObjectTreePanelEvent = new ObjectTreePanelEvent( type, bubbles, cancelable );
			newEvent.value = value;
			return newEvent;
		}
	}
}
