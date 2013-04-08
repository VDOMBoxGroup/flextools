package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class GlobalScriptsPanelEvent extends Event
	{

		public static var GET_SCRIPTS : String = "getScripts";

		public static var SCRIPTS_CHANGE : String = "scriptsChange";

		public function GlobalScriptsPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new GlobalScriptsPanelEvent( type, bubbles, cancelable );
		}
	}
}
