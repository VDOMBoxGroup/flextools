package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class LevelsFilterPanelEvent extends Event
	{
		public static var CURRENT_LEVEL_CHANGED : String = "currentLevelChanged";
		
		public function LevelsFilterPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new LevelsFilterPanelEvent( type, bubbles, cancelable );
		}
	}
}