package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	public class EventsPanelEvent extends Event
	{
		public static var CREATE_SERVER_ACTION_CLICK : String = "createServerActionClick";
		public static var RENDERER_CLICK : String = "rendererClick";
		public static var RENDERER_DOUBLE_CLICK : String = "rendererDoubleClick";
		
		public function EventsPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new EventsPanelEvent( type, bubbles, cancelable );
		}
	}
}