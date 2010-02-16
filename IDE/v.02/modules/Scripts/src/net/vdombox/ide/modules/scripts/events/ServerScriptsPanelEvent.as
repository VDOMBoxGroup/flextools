package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class ServerScriptsPanelEvent extends Event
	{
		public static var SELECTED_SERVER_ACTION_CHANGED : String = "selectedServerActionChanged";
		public static var CREATE_ACTION : String = "createAction";
		public static var DELETE_ACTION : String = "deleteAction";
		
		public function ServerScriptsPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ServerScriptsPanelEvent( type, bubbles, cancelable );
		}
	}
}